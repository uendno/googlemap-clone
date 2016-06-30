//
//  Response.swift
//  googlemap-clone
//
//  Created by Thang Tran on 6/15/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import Foundation
import ObjectMapper

enum ResponseStatus: String {
	case Success = "success"
	case Error = "error"
}

class BaseResponse: Mappable {
	var status: ResponseStatus!
	
	required init?(_ map: Map) {
		
	}
	// Mappable
	func mapping(map: Map) {
		status <- map["status"]
	}
}

class PlaceDetailsResponse: BaseResponse {
	
	var id: String?
	var placeId: String?
	var name: String?
	var address: String?
	var phone: String?
	var website: String?
	var isOpenNow: Bool?
	
	override func mapping(map: Map) {
		super.mapping(map)
		
		id <- map["data.result.id"]
		placeId <- map["data.result.place_id"]
		name <- map["data.result.name"]
		address <- map["data.result.formatted_address"]
		phone <- map["data.result.international_phone_number"]
		website <- map["data.result.website"]
		isOpenNow <- map["data.opening_hours.open_now"]
		
	}
}

class PlaceReviewListResponse: BaseResponse {
	var reviews: [PlaceReviewResponse]?
	var nearbyPlaces: [NearbyPlaceResponse]?
	
	override func mapping(map: Map) {
		super.mapping(map)
		reviews <- map["data.reviews"]
		nearbyPlaces <- map["data.nearby_places"]
	}
}

class PlaceReviewResponse: BaseResponse {
	var rating: Int!
	var authorName: String!
	var text: String?
	var time: Double!
	var avatarURL: String?
	
	override func mapping(map: Map) {
		super.mapping(map)
		
		rating <- map["rating"]
		authorName <- map["author_name"]
		text <- map["text"]
		time <- map["time"]
		avatarURL <- map["profile_photo_url"]
	}
}

class NearbyPlaceResponse: BaseResponse {
	
	var id: String!
	var name: String?
	var photoRef: String?
	
	override func mapping(map: Map) {
		super.mapping(map)
		
		id <- map["id"]
		name <- map["name"]
		photoRef <- map["photos.0.photo_reference"]
	}
	
}

class DirectionResponse: BaseResponse {
	
	var routes: [RouteResponse]?
	
	override func mapping(map: Map) {
		super.mapping(map)
		
		routes <- map["data.routes"]
	}
	
}


class RouteResponse: BaseResponse {
	var legs: [LegResponse]?
	
	override func mapping(map: Map) {
		super.mapping(map)
		
		legs <- map["legs"]
	}
}

class LegResponse: BaseResponse {
    var steps: [StepResponse]?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        steps <- map["steps"]
    }
}

class StepResponse: BaseResponse {
	
	var encodedPolyline: String?

	override func mapping(map: Map) {
		super.mapping(map)
		
		encodedPolyline <- map["polyline.points"]
	}
}

