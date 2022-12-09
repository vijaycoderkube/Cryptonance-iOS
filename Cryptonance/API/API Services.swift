//
//  API Services.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 21/10/22.
//

import Foundation
import UIKit
import Alamofire
import CRNotifications
import SwiftyJSON

///THIS IS JSON Dictionary format
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONStringDictionary = Dictionary<String, String>

///THIS IS JSON array format
typealias JSONArray = Array<AnyObject>
typealias json = JSON

#if DEBUG
func dLog(message: Any, filename: String = #file, function: String = #function, line: Int = #line) {
    NSLog("%@","[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
}
#else
func dLog(message: Any, filename: String = #file, function: String = #function, line: Int = #line) {
}
#endif

let Currency = "$"

/// Configaration for base url
class Config : NSObject{
    static let BaseUrl = "http://44.234.205.222/eventapp/api/"
    var access_token = "Bearer \(UserDefaults.standard.value(forKey: "access_tokens") ?? "")"
    static var fcmToken : String = "\(UserDefaults.standard.value(forKey: "FcmToken") ?? "")"
   
    func saveUserData(Object:[AnyHashable: Any]){
        var userData  = Object
        userData = userData.nullKeyRemoval()
        UserDefaults.standard.set(userData, forKey: "profile")
        UserDefaults.standard.synchronize()
    }
    
    func userData() -> json  {
        let decoded  = UserDefaults.standard.object(forKey: "profile")

        let Object = JSON(decoded as Any)
        return Object
    }
}


//MARK: - Class API
/// All API calls are goes from here so don't write any where else api calling code
class API: NSObject {
    //MARK: - Login API
    /// Login API that will check for user is exist or not
    /// - Parameters:
    ///   - paramters:   var par = Parameters()
    ///                  par["username"] = "9874563213"
    ///                  par["password"] = "123456789"
    ///   - result: provide user data
    ///   - failure: failer will show the error string
    /*public func loginApi(paramters : Parameters ,result : @escaping ((_ responseObj : JSON?) -> Void), failure : @escaping ((_ error : String?) -> Void)){
        
        CallService(serviceName : .login, parameters : paramters, method : .post) { responseObj in
            let Object = JSON(responseObj as Any )
            if Object["statusCode"].intValue == 200 {
                makeToast(type: CRNotifications.success, title: "app_name".localized.capitalized, message: Object.string(key: "message"))
                result(Object)
            } else if Object["statusCode"].intValue == 403 {
                makeToast(type: CRNotifications.info, title:"app_name".localized.capitalized, message: Object.array(key: "errors").first?.string(key: "username") ?? "")
            } else {
                displayErrorMessage(errors: Object["errors"])
                 failure(Object.string(key: "message"))
            }
            
        } failure : { error in
            failure(error)
        }
    }*/
}

func displayErrorMessage(errors:json){
    if  let keys = errors.dictionaryObject?.keys {
        var errorArray : [String] = [String]()
        for key in keys {
            let array = errors.array(key: key)
            if array.count > 0{
                errorArray.append(array.first!.rawValue as! String)
            }
        }
        makeToast(type: CRNotifications.error, title: "app_name".localized.capitalized, message:errorArray.joined(separator: ", "))
    }
}


//MARK: - Call Services
/// Commonfunction that is used to call all the APIs
func CallService(serviceName : APIEndPoint, parameters : Parameters, method : HTTPMethod , isShowloader:Bool = true, withSuccess : @escaping ((_ responseObj : JSONDictionary?) -> Void), failure : @escaping ((_ error : String?) -> Void)) {
    
    let pageUrlStr =  Config.BaseUrl + serviceName.value
    
    let headers : HTTPHeaders = [
        "Accept" : "Application/json",
        "Content-Type" : "application/x-www-form-urlencoded",
        "Authorization": Config().access_token,
        "language" : getLangCode()
    ]
    print("pageUrlStr :- ",pageUrlStr)
    print("Headers :- ",headers)
    print("parameters :- ",parameters)
    if isShowloader{
        showLoader()
    }
    AF.request(pageUrlStr, method : method, parameters : parameters, encoding : URLEncoding.queryString, headers : headers).responseJSON { response in
        switch response.result {
            
        case .success(let JSON):
            if var jsonDictionary = JSON as? JSONDictionary{
                jsonDictionary["statusCode"] = (response.response?.statusCode as AnyObject)
                dLog(message: jsonDictionary)
                withSuccess(jsonDictionary)
                if jsonDictionary["statusCode"]?.intValue == 401 {
                    print("unauthenticated")
                }
            } else {
                failure("Request failed with error")
            }
            if isShowloader {
                hideLoader()
            }
            break
            
        case .failure(let error):
            if error.responseCode == -1001 {
                print("TIME OUR ERROR")
            }
            failure("Request failed with error: \(error)")
            makeToast(type: CRNotifications.success, title: "Please try again".localized, message: error.localizedDescription)
            if isShowloader{
                hideLoader()
            }
            break
        }
    }
}


//MARK: - Call Services
/// Common function that is used to call all the APIs
func CallUploadService(serviceName : APIEndPoint, parameters : Parameters,files:[JSONDictionary], method : HTTPMethod , isShowloader:Bool = true, withSuccess : @escaping ((_ responseObj : JSONDictionary?) -> Void), failure : @escaping ((_ error : String?) -> Void)) {
    
    let pageUrlStr =  Config.BaseUrl + serviceName.value
    
    let headers : HTTPHeaders = [
        "Accept" : "Application/json",
        "Content-type": "multipart/form-data",
        "Authorization": Config().access_token,
        "language" : getLangCode()
    ]
    print("pageUrlStr :- ",pageUrlStr)
    print("Headers :- ",headers)
    print("parameters :- ",parameters)
    if isShowloader{
        showLoader()
    }
 
    AF.upload(multipartFormData: {  (multipartFormData) in
        for (key, value) in parameters {
             if let val = value as? [String] , let dataofarray = stringArrayToData(stringArray: val) {
                multipartFormData.append(dataofarray, withName: key)
            } else  if let val = value as? [Int] , let dataofarray = intArrayToData(stringArray: val) {
                multipartFormData.append(dataofarray, withName: key)
            }else if let val = value as? JSONDictionary , let dataofarray = stringDicToData(dic: val) {
                multipartFormData.append(dataofarray, withName: key)
            }else{
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
        }
        for object in files{
            if let data = object["data"] as? Data{
                multipartFormData.append(data, withName: object.valueForKeyString("key"), fileName: object.valueForKeyString("name"), mimeType: "*/*")
            }
         }
    }, to: pageUrlStr, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON {   response in
 
        switch response.result {
        case .success(let JSON):
            print("Response with JSON : \(JSON)")
            if var jsonDictionary = JSON as? JSONDictionary{
                jsonDictionary["statusCode"] = (response.response?.statusCode as AnyObject)
                withSuccess(jsonDictionary)
                print("JSON Dictionary :- ",jsonDictionary)
                print("ResponseCode :- ",jsonDictionary["statusCode"] ?? "")
                
                if jsonDictionary["statusCode"]?.intValue == 401 {
                    print("unauthenticated")
                }
                
            }else{
                failure("Request failed with error")
            }
            if isShowloader{
                hideLoader()
            }
            break
        case .failure(let error):
            if error.responseCode == -1001 {
                print("TIME OUR ERROR")
            }
            failure("Request failed with error: \(error)")
            makeToast(type: CRNotifications.error, title: "Please try agin".localized, message: error.localizedDescription)
            if isShowloader{
                hideLoader()
            }
            break
        }
    }
}

func stringArrayToData(stringArray: [String]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

func intArrayToData(stringArray: [Int]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

func stringDicToData(dic: JSONDictionary) -> Data? {
    return try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
}

func jsonArrayToData(stringArray: [String]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

//MARK: - Decodable
extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

//MARK: - JSON Class simplify to use faster
extension JSON {
    func string(key:String) -> String{
       return self[key].stringValue
    }
    
    func double(key:String) -> Double{
       return self[key].doubleValue
    }
    
    func array(key:String) -> [JSON]{
       return self[key].arrayValue
    }
    
    func object(key:String) -> JSON{
        return JSON(rawValue: self[key].dictionaryValue) ?? [:]
    }
}
