import Foundation

import SwiftToolbox

do {
    let config: EmailConfig = try ConfigHandler<EmailConfig>(configFile: "./../Config.json", relativeFrom: #file).load()
    print("Hello, world!")
    print("Have some sensitive data!")
    print(config)
} catch {
    print("This did not work")
    print(error)
}
