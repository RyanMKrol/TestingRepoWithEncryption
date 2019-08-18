[![Build Status](https://travis-ci.org/RyanMKrol/TestingRepoWithEncryption.svg?branch=master)](https://travis-ci.org/RyanMKrol/TestingRepoWithEncryption)

# GitEncryptionTest

I made this package to test storing sensitive data, and deploying changes that will create a new docker image from the new code.

The code in the main project will read from a config file storing "sensitive" data, and then print the result, pretty simple.

## Problems
 - How do you store sensitive data in a git repo?
 - How do you update docker via Travis CI?

### Storing Sensitive Data
The simplest way to get this going was to use symmetric key encryption via OpenSSL. I can develop locally with the actual sensitive files, while pushing the encrypted files to my git repo. Travis CI then stores the AES password in it's encrypted environment variables, which allows me to decrypt the sensitive files that my code relies on during runtime.

### Updating Docker Images During Deployment
The problem here is that Travis CI doesn't allow docker when running against the macOS operating system, which the majority of my swift projects will be using. To get around this, I have a bash script stored on an EC2 instance, which will then handle updating the docker images. This script looks like:

    #!/bin/bash

    AES_PASS=$1

    ENCRYPT_DIR=Sources/GitEncryptionTest

    git clone --branch=master https://github.com/RyanMKrol/TestingRepoWithEncryption.git

    cd TestingRepoWithEncryption

    openssl enc -aes-256-cbc -d -in $ENCRYPT_DIR/Config.json.enc -out $ENCRYPT_DIR/Config.json -k $AES_PASS
    openssl enc -aes-256-cbc -d -in $ENCRYPT_DIR/OtherConfig.json.enc -out $ENCRYPT_DIR/OtherConfig.json -k $AES_PASS

    cat ./../dockerPassword.txt | docker login -u ryankrol --password-stdin

    docker build -t ryankrol/secure-image:1.0 .

    docker push ryankrol/secure-image:1.0

    cd ..

    rm -rf TestingRepoWithEncryption

This script pulls out the sensitive files, logs you into docker, builds the new image, and then pushes it to a public registry. Once we're done we can delete the code so we're not taking up space on the box.

The deploy step in Travis CI then looks like:

    language: swift
    ...
    before_install:
    - openssl enc -aes-256-cbc -d -in Sources/GitEncryptionTest/Config.json.enc -out Sources/GitEncryptionTest/Config.json -k $AES_PASS
    - openssl enc -aes-256-cbc -d -in Sources/GitEncryptionTest/OtherConfig.json.enc -out Sources/GitEncryptionTest/OtherConfig.json -k $AES_PASS
    - swift package generate-xcodeproj
    deploy:
      provider: script
      script: bash .docker_push $AES_PASS
      on:
        branch: master

This config will decrypt the files using an environment variable stored in the Travis CI tool, and run the deployment script assuming the code is solid, and being pushed to the master branch only.

The deployment step involves running this script, which pulls out the aws credentials, updates the permission (AWS doesn't allow loose permissions on it's key pairs), and calls the deployment script on my EC2 host:

    #!/bin/bash

    AES_PASS=$1

    openssl enc -aes-256-cbc -d -in Sources/GitEncryptionTest/awsKeypair.pem.enc -out Sources/GitEncryptionTest/awsKeypair.pem -k $AES_PASS

    chmod 400 Sources/GitEncryptionTest/awsKeypair.pem

    ssh -o "StrictHostKeyChecking no" -i Sources/GitEncryptionTest/awsKeypair.pem  ec2-user@ec2-3-16-81-16.us-east-2.compute.amazonaws.com "bash ~/deploy-secure-image.sh $AES_PASS"

### FAQ
Q. Why do you need to update the docker image remotely?
A. Travis CI doesn't support docker commands specifically on macOS volumes, so for any other projects I could use the Travis tools, but not for Swift based project.
