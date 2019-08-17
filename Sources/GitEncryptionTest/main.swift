import Foundation

import SwiftToolbox

do {
    let _ = try ConfigHandler<EmailConfig>(configFile: "./../OtherConfig.json", relativeFrom: #file).load()
    let _ = try ConfigHandler<EmailConfig>(configFile: "./../Config.json", relativeFrom: #file).load()
    print("Success")
} catch {
    print("This did not work")
    print(error)
}
