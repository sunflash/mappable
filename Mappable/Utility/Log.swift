import Foundation

public class LogGlobalConfig {

    public static var showWarningLog = false
    public static var showErrorLog = false
    public static var showDebugLog = false
    public static var showInfoLog = false
    public static var showVerboseLog = false

    public static var showAPILog = false
    public static var showCoderLog = false
}

public enum LogType {

    case WARNING

    case ERROR

    case DEBUG

    case INFO

    case VERBOSE

    case API
}

public protocol Log {

    var showWarningLog: Bool {get}
    var showErrorLog: Bool {get}
    var showDebugLog: Bool {get}
    var showInfoLog: Bool {get}
    var showVerboseLog: Bool {get}

    func log(_ type: LogType, _ message: String)
}

extension Log {

    public var showWarningLog: Bool {
        return LogGlobalConfig.showWarningLog
    }

    public var showErrorLog: Bool {
        return LogGlobalConfig.showErrorLog
    }

    public var showDebugLog: Bool {
        return LogGlobalConfig.showDebugLog
    }

    public var showInfoLog: Bool {
        return LogGlobalConfig.showInfoLog
    }

    public var showVerboseLog: Bool {
        return LogGlobalConfig.showVerboseLog
    }

    public func log(_ type: LogType, _ message: String) {

        switch type {
        case .WARNING where (showWarningLog == true || showVerboseLog == true):
            print("WARNING:", message)
        case .ERROR where (showErrorLog == true || showVerboseLog == true):
            print("ERROR:", message)
        case .DEBUG where (showDebugLog == true || showVerboseLog == true):
            print("DEBUG:", message)
        case .INFO where (showInfoLog == true || showVerboseLog == true):
            print("INFO:", message)
        case .VERBOSE where (showVerboseLog == true):
            print("VERBOSE:", message)
        default:
            break
        }
    }
}

public enum CoderType {
    case JSONEncode
    case JSONDecode
}

public func logCoder(_ type: CoderType, _ message: String) {

    guard LogGlobalConfig.showCoderLog == true else {return}

    switch type {
    case .JSONEncode:
        print("JSONEncode:", message)
    case .JSONDecode:
        print("JSONDecode:", message)
    }
}

public enum APIType {
    case request
    case response
}

public func logAPI(_ type: APIType, _ url: URL, output: Any) {

    guard LogGlobalConfig.showAPILog == true else {return}

    printSeparatorLine()

    switch type {
    case .request:
        print("API-Request:", url)
    default:
        print("API-Response", url)
    }

    printSeparatorLine()
    print(output)
    printSeparatorLine()
}

public func printSeparatorLine(_ pattern: String = "-", _ length: Int = 100) {
    let separatorLine = String(repeating: pattern, count: length)
    print(separatorLine)
}

public func separatorWithNewLine(_ pattern: String = "*", _ length: Int = 100) -> String {
    return  "\n" + String(repeating: pattern, count: length) + "\n"
}
