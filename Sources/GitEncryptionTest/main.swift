import Foundation

import SwiftToolbox

do {
    let configOne = try ConfigHandler<EmailConfig>(configFile: "./../OtherConfig.json", relativeFrom: #file).load()
    let configTwo = try ConfigHandler<EmailConfig>(configFile: "./../Config.json", relativeFrom: #file).load()
    print("Success")
    print(configOne)
    print(configTwo)
} catch {
    print("This did not work")
    print(error)
}
