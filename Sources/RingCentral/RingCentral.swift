import Alamofire

public struct RingCentralOptions {
    public let clientId: String?
    public let clientSecret: String?
    public let server: String?
    public init(clientId: String?, clientSecret: String?, server: String?) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.server = server
    }
}

public class RingCentral {
    public let options: RingCentralOptions
    public var tokenInfo: [String: Any]?
    public init(options: RingCentralOptions) {
        self.options = options
    }
    public func authorize(username: String, ext: String?, password: String, callback: (() -> Void)? = nil) {
        let parameters: Parameters = [
            "username": username,
            "extension": ext ?? "",
            "password": password,
            "grant_type": "password"
        ]
        let base64Token = "\(self.options.clientId!):\(self.options.clientSecret!)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64Token)"
        ]
        AF.request("\(self.options.server!)/restapi/oauth/token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            debugPrint(response)
            self.tokenInfo = response.value as? [String: Any]
            callback?()
        }
    }
    public func request(_ endpoint: String, method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      encoding: ParameterEncoding = JSONEncoding.default) -> DataRequest {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(self.tokenInfo!["access_token"]!)"
        ]
        return AF.request(self.options.server! + endpoint, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
}
