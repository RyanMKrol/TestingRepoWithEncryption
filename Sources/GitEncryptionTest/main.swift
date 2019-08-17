import Foundation

import SwiftToolbox

do {
    let config: EmailConfig = try ConfigHandler<EmailConfig>(configFile: "./../Config.json", relativeFrom: #file).load()
    let Otherconfig: EmailConfig = try ConfigHandler<EmailConfig>(configFile: "./../OtherConfig.json", relativeFrom: #file).load()
    print("Success")
} catch {
    print("This did not work")
    print(error)
}
