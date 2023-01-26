/**
 This is a wrapper of Networking library .
 */

import UIKit
import Alamofire

class NetworkingWrapper: NSObject {
    
    static let sharedInstance = NetworkingWrapper()
    static let apiManager = Alamofire.SessionManager.default
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    private override init() {}
    
    /**
     Call this function to check if the internet is active or not.
     */
    
    func isConnectedToInternet() -> Bool {
        return reachabilityManager!.isReachable
    }
    
    
    func selectedServerURL() -> (baseURL: String, socketURL: String, imageURL: String) {
        var url = ""
        var socktURL = ""
        var imgURL = ""
        switch UserDefaults.standard.value(forKey: "Selected_Server") as? String ?? "Live" {
        case "Local":
            url = "https://test.bahrainsalons.com:9052/api/v2/"
            socktURL = "https://test.bahrainsalons.com:9052/api/v2/"
            imgURL = "https://test.bahrainsalons.com:9052/uploads/"
        case "Release":
            url = "https://test.bahrainsalons.com:9052/api/v2/"
            socktURL = "https://test.bahrainsalons.com:9052/api/v2/"
            imgURL = "https://test.bahrainsalons.com:9052/uploads/"
        case "Live":
            url = "https://webservices.bahrainsalons.com:9052/api/v2/"
            socktURL = "https://webservices.bahrainsalons.com:9052/api/v2/"
            imgURL = "https://webservices.bahrainsalons.com:9052/uploads/"
        default:
            url = "https://webservices.bahrainsalons.com:9052/api/v2/"
            socktURL = "https://webservices.bahrainsalons.com:9052/api/v2/"
            imgURL = "https://webservices.bahrainsalons.com:9052/uploads/"
        }
        return (url, socktURL, imgURL)
    }
    
    func connect(urlEndPoint:String, httpMethod:HTTPMethod, headers:HTTPHeaders?, parameters:Dictionary<String,Any>,  apiResponse:@escaping(responseHandler)) {
        
        
        let urlString = "\(Configurator().baseURL)\(urlEndPoint)"
        let validUrlString:String? = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        validUrlString = validUrlString?.lowercased()
        printToConsole(item: parameters as Any)
        printToConsole(item: headers as Any)
        printToConsole(item: validUrlString!)
        
        if reachabilityManager!.isReachable {
            ManageHudder.sharedInstance.startActivityIndicator()
            
            print("URL:-----",validUrlString ?? "Invalid URL")
            print("PARAM:-----",parameters)
            Alamofire.request(validUrlString!, method: httpMethod, parameters: parameters.count == 0 ? nil : parameters, headers: headers).responseJSON { response in
                ManageHudder.sharedInstance.stopActivityIndicator()
                if response.result.isSuccess {
                    if let rawJson = response.result.value as? NSDictionary {
                        
                        printToConsole(item: rawJson)
                        
                        let parsedResponse = self.parseResponse(rawJson: rawJson)
                        apiResponse(parsedResponse)
                        
                    }
                    else {
                        apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kJsonError.rawValue), result: nil))
                    }
                }
                else {
                    apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kServerError.rawValue), result: nil))
                }
            }
        }
        else {
            CustomAlertController.sharedInstance.showErrorAlert(error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kNetworkError.rawValue))
        }
    }
    
    func connectSplash(urlEndPoint:String, httpMethod:HTTPMethod, headers:HTTPHeaders?, parameters:Dictionary<String,Any>,  apiResponse:@escaping(responseHandler)) {
        
        
        //let urlString = "https://test.bahrainsalons.com:9052/api/v2/getAllsplashdata"
       
        let urlString = "\(Configurator().baseURL)\(urlEndPoint)"
        let validUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if reachabilityManager!.isReachable {
            ManageHudder.sharedInstance.startActivityIndicator()
            print("URL:-----",validUrlString)
            
            Alamofire.request(validUrlString!, method: httpMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                ManageHudder.sharedInstance.stopActivityIndicator()
                if response.result.isSuccess {
                    if let rawJson = response.result.value as? NSDictionary {
                        
                        printToConsole(item: rawJson)
                        
                        let parsedResponse = self.parseResponse(rawJson: rawJson)
                        apiResponse(parsedResponse)
                        
                    }
                    else {
                        apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kJsonError.rawValue), result: nil))
                    }
                }
                else {
                    apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kServerError.rawValue), result: nil))
                }
            }
        }
        else {
            CustomAlertController.sharedInstance.showErrorAlert(error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kNetworkError.rawValue))
        }
    }
    
    /**
     Call this function to hit api without headers and with parameters
     */
    
    func connect(urlEndPoint:String, httpMethod:HTTPMethod, parameters:Dictionary<String,Any>,  apiResponse:@escaping(responseHandler)) {
        
        connect(urlEndPoint: urlEndPoint, httpMethod: httpMethod, headers: nil, parameters: parameters) { (response) in
            apiResponse(response)
        }
    }
    
    /**
     Call this function to hit api without headers and with parameters
     */
    
    func connectSp(urlEndPoint:String, httpMethod:HTTPMethod, parameters:Dictionary<String,Any>,  apiResponse:@escaping(responseHandler)) {
        connectSplash(urlEndPoint: urlEndPoint, httpMethod: httpMethod, headers: nil, parameters: parameters) { (response) in
            apiResponse(response)
        }
    }
    
    /**
     Call this function to hit api with headers and without parameters
     */
    
    func connect(urlEndPoint:String, httpMethod:HTTPMethod, headers:HTTPHeaders?,  apiResponse:@escaping(responseHandler)) {
        connect(urlEndPoint: urlEndPoint, httpMethod: httpMethod, headers: headers, parameters: [:]) { (response) in
            apiResponse(response)
        }
    }
    
    /**
     Call this function to hit api without headers and without parameters
     */
    
    func connect(urlEndPoint:String, httpMethod:HTTPMethod,  apiResponse:@escaping(responseHandler)) {
        connect(urlEndPoint: urlEndPoint, httpMethod: httpMethod, headers: nil, parameters: [:]) { (response) in
            apiResponse(response)
        }
    }
    
    /**
     Call this function to hit Multi part api
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, parameters:[String:Any]?, headers:HTTPHeaders?, images:[UIImage]?, imageName:String?,  apiResponse:@escaping(responseHandler)) {
        
        let urlString = "\(Configurator().baseURL)\(urlEndPoint)"
        let validUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        printToConsole(item:parameters as Any)
        printToConsole(item:headers as Any)
        printToConsole(item:validUrlString as Any)
        printToConsole(item:imageName as Any)
        
        let connectionManager = Alamofire.SessionManager.default
        connectionManager.session.configuration.timeoutIntervalForRequest = 240
        connectionManager.session.configuration.timeoutIntervalForResource = 240
        
        
        if reachabilityManager!.isReachable {
            ManageHudder.sharedInstance.startActivityIndicator()
            connectionManager.upload(multipartFormData: { (multipartFormData) in
                
                if let imagesArray = images {
                    for image in imagesArray {
                        multipartFormData.append(image.jpegData(compressionQuality: 0.1)!, withName: "\(imageName!)", fileName: "\(imageName!).jpeg", mimeType: "image/jpeg")
                        
                        printToConsole(item:"\(imageName!).jpeg" as Any)
                    }
                }
                
                if parameters != nil {
                    for (key, value) in parameters! {
                        multipartFormData.append(("\(value)").data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
            }, usingThreshold: UInt64.init(),
               to: validUrlString!,
               method: httpMethod,
               headers: headers)
            { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        printToConsole(item: progress)
                    })
                    
                    upload.responseJSON { response in
                        printToConsole(item: response.result)
                        ManageHudder.sharedInstance.stopActivityIndicator()
                        if let jsonDict = response.result.value as? NSDictionary {
                            printToConsole(item: jsonDict)
                            apiResponse(self.parseResponse(rawJson: jsonDict))
                        }
                        else {
                            apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kJsonError.rawValue), result: nil))
                        }
                    }
                    
                case .failure(let encodingError):
                    ManageHudder.sharedInstance.stopActivityIndicator()
                    printToConsole(item:encodingError.localizedDescription)
                    apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kServerError.rawValue), result: nil))
                }
            }
        }
        else {                                                                                                                                                                                                    
            CustomAlertController.sharedInstance.showErrorAlert(error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kNetworkError.rawValue))
        }
    }
    
    /**
     Call this function to hit Multipart api without image
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, headers:HTTPHeaders?, parameters:[String:Any],  apiResponse:@escaping(responseHandler)) {
        
        connectWithMultiPart(urlEndPoint: urlEndPoint, httpMethod: httpMethod, parameters: parameters, headers: headers, images: nil, imageName: nil) { (response) in
            apiResponse(response)
        }
    }
    
    
    /**
     Call this function to hit Multipart api without image and without headers
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, parameters:[String:Any]?,  apiResponse:@escaping(responseHandler)) {
        
        connectWithMultiPart(urlEndPoint: urlEndPoint, httpMethod: httpMethod, parameters: parameters, headers: nil, images: nil, imageName: nil) { (response) in
            apiResponse(response)
        }
    }
    
    
    /**
     Call this function to hit Multipart api with headers and without parameters
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, headers:HTTPHeaders?, images:[UIImage]?, imageName:String,  apiResponse:@escaping(responseHandler)) {
        
        connectWithMultiPart(urlEndPoint: urlEndPoint, httpMethod: httpMethod, parameters: nil, headers: headers, images: images, imageName: imageName) { (response) in
            apiResponse(response)
        }
    }
    
    
    /**
     Call this function to hit Multipart api without headers and with parameters
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, parameters:[String:Any]?, images:[UIImage]?, imageName:String,  apiResponse:@escaping(responseHandler)) {
        
        connectWithMultiPart(urlEndPoint: urlEndPoint, httpMethod: httpMethod, parameters: parameters, headers: nil, images: images, imageName: imageName) { (response) in
            apiResponse(response)
        }
    }
    
    
    /**
     Call this function to hit Multipart api without headers and without parameters
     */
    
    func connectWithMultiPart(urlEndPoint:String, httpMethod:HTTPMethod, images:[UIImage]?, imageName:String,  apiResponse:@escaping(responseHandler)) {
        
        connectWithMultiPart(urlEndPoint: urlEndPoint, httpMethod: httpMethod, parameters: nil, headers: nil, images: images, imageName: imageName) { (response) in
            apiResponse(response)
        }
    }
    
    /**
     Call this function to hit Multi part api to upload documment
     */
    
    func connectWithMultiPartDocument(urlEndPoint:String, httpMethod:HTTPMethod, parameters:[String:Any]?, headers:HTTPHeaders?, pdfData:URL?, images:[UIImage?]?, imageName:String?,  apiResponse:@escaping(responseHandler)) {
        
        let urlString = "\(Configurator().baseURL)\(urlEndPoint)"
        let validUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        printToConsole(item:parameters as Any)
        printToConsole(item:headers as Any)
        printToConsole(item:validUrlString as Any)
        printToConsole(item:imageName as Any)
        
        let connectionManager = Alamofire.SessionManager.default
        connectionManager.session.configuration.timeoutIntervalForRequest = 240
        connectionManager.session.configuration.timeoutIntervalForResource = 240
        
        
        if reachabilityManager!.isReachable {
            ManageHudder.sharedInstance.startActivityIndicator()
            connectionManager.upload(multipartFormData: { (multipartFormData) in
                
                
                printToConsole(item: images)
                
                
                if let imagesArray = images {
                    for image in imagesArray {
                        multipartFormData.append(image!.jpegData(compressionQuality: 0.1)!, withName: "\(imageName!)", fileName: "\(imageName!).jpeg", mimeType: "image/jpeg")
                        
                        printToConsole(item:"\(imageName!).jpeg" as Any)
                    }
                }
                else {
                    multipartFormData.append(pdfData!, withName: "crNumber", fileName: "\(imageName!).pdf", mimeType:"application/pdf")
                }
                
                
                
                if parameters != nil {
                    for (key, value) in parameters! {
                        multipartFormData.append(("\(value)").data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
            }, usingThreshold: UInt64.init(),
               to: validUrlString!,
               method: httpMethod,
               headers: headers)
            { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        printToConsole(item: progress)
                    })
                    
                    upload.responseJSON { response in
                        printToConsole(item: response.result)
                        ManageHudder.sharedInstance.stopActivityIndicator()
                        if let jsonDict = response.result.value as? NSDictionary {
                            printToConsole(item: jsonDict)
                            apiResponse(self.parseResponse(rawJson: jsonDict))
                        }
                        else {
                            apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kJsonError.rawValue), result: nil))
                        }
                    }
                    
                case .failure(let encodingError):
                    ManageHudder.sharedInstance.stopActivityIndicator()
                    printToConsole(item:encodingError.localizedDescription)
                    apiResponse(ApiResponse(status: 0, code: nil, error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kServerError.rawValue), result: nil))
                }
            }
        }
        else {
            CustomAlertController.sharedInstance.showErrorAlert(error: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.ValidationsText.kNetworkError.rawValue))
        }
    }
    
    func parseResponse(rawJson:NSDictionary) -> ApiResponse {
        let status = rawJson["status"] as? NSNumber ?? 0
        let code = rawJson["code"] as? NSNumber ?? 0
        let error = rawJson["errors"] as? String ?? ""
        let message = rawJson["message"] as? String ?? ""
        let resultObj = rawJson
        if error == "" {
            let response = ApiResponse(status: status, code: code, error: nil, message: message, result: resultObj)
            return response
        }
        else {
            let response = ApiResponse(status: status, code: code, error: error, message: message, result: resultObj)
            return response
        }
    }
}

typealias responseHandler = (_ response: ApiResponse) ->()

struct ApiResponse {
    var status:NSNumber?
    var code:NSNumber?
    var error:String?
    var message:String?
    var result:Any?
}
