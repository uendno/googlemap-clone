//
//  APIClient.swift
//  googlemap-clone
//
//  Created by Thang Tran on 6/15/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator
import AlamofireObjectMapper
import AlamofireImage

public protocol RequestParamsConvertible {
	var params: [String: AnyObject]? { get }
}

extension Dictionary: RequestParamsConvertible {
	public var params: [String: AnyObject]? {
		var object = [String: AnyObject]()
		for (key, value) in self {
			if let key = key as? String, value = value as? AnyObject {
				object[key] = value
			}
		}
		return object
	}
}

extension Request {
	public func debugLog() -> Self {
		#if DEBUG
			debugPrint(self)
		#endif
		return self
	}
}

let APIErrorDomain = "com.common.error";

class APIClient {
	private static var client: APIClient?
	private var baseURLString: String
	
	var accessToken: String?// Set this value for api client sending request after user logged in
	var defaultHeaders: Dictionary<String, String> {
		return ["app-type": "VEND", "device-udid": UIDevice.currentDevice().uniqueDeviceIdentifier]
	}
	
	class func setCurrentClient(aClient: APIClient) {
		client = aClient
	}
	
	class func currentClient() -> APIClient? {
		return client
	}
	
	init(baseURLString: String) {
		self.baseURLString = baseURLString
	}
	
	// MARK: -- Private Methods
	
	private func resolvePath(path: String) -> String {
		return baseURLString + path;
	}
	
	private func request(
		method: Alamofire.Method,
		_ path: String,
		parameters: [String: AnyObject]? = nil,
		encoding: ParameterEncoding = .JSON,
		headers: [String: String]? = nil)
		-> Request
	{
		let requestURL = NSURL(string: resolvePath(path))
		
		var requestHeaders = [String: String]()
		
		for (key, value) in defaultHeaders {
			requestHeaders[key] = value
		}
		
		if let token = accessToken {
			requestHeaders["x-access-token"] = token
		}
		
		if let headers = headers {
			for (key, value) in headers {
				requestHeaders[key] = value
			}
		}
		
		let request = Alamofire.request(method, requestURL!, parameters: parameters, encoding: encoding, headers: requestHeaders)
		
		// print(request.)
		
		#if DEBUG
			request.responseString { [unowned request](response: Response<String, NSError>) in
				LogDebug(request.debugDescription)
				switch response.result {
				case .Success(let value):
					LogDebug("Response:\n===============\n\(value)\n===============")
				case .Failure(let error):
					LogDebug("Response:\n===============\n\(error)\n===============")
				}
				
			}
		#endif
		return request
	}
	
	func getPlaceDetails(placeId: String, completionHandler: (PlaceReviewListResponse?, NSError?) -> Void) -> Request {
		
		return request(.GET, placeId + "/reviews", parameters: nil, encoding: .URL).responseObject(completionHandler: { (response: Response<PlaceReviewListResponse, NSError>) in
			completionHandler(response.result.value, response.result.error)
		})
	}
	
	func getPhoto(photoRef: String, completionHandler: (UIImage?, NSError?) -> Void) -> Request {
		
		return request(.GET, "photo/\(photoRef)", parameters: nil, encoding: .URL).responseImage { response in
			completionHandler(response.result.value, response.result.error)
		}
	}
	
	func getDirection(originId: String, destinationId: String, completionHandler: (DirectionResponse?, NSError?) -> Void) -> Request {
		
		let params = [
			"origin": originId,
			"destination": destinationId
		]
		
		return request(.GET, "direction", parameters: params, encoding: .URL).responseObject(completionHandler: { (response: Response<DirectionResponse, NSError>) in
			completionHandler(response.result.value, response.result.error)
		})
		
//		return request(.GET, "direction", parameters: nil, encoding: .URL).responseString(completionHandler: { response in
//			print(response)
//		})
	}
	
}
