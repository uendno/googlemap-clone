//
//  PolylineDrawer.swift
//  googlemap-clone
//
//  Created by Tran Viet Thang on 6/30/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import Foundation
import GoogleMaps
import Polyline

class PolylineDrawer {
	
	private var polylines: [GMSPolyline]? = []
	private var startCircle: GMSCircle? = GMSCircle()
	private var endCircle: GMSCircle? = GMSCircle()
	
	func draw(route: RouteResponse, map: GMSMapView) {
		
		for leg in route.legs! {
			for step in leg.steps! {
				
				let coordinates = Polyline.init(encodedPolyline: step.encodedPolyline!).coordinates
				let path = GMSMutablePath()
				for coordinate in coordinates! {
					path.addCoordinate(coordinate)
				}
				let polyline = GMSPolyline.init(path: path)
				polyline.strokeWidth = 5
				
				polyline.map = map
				
				polylines?.append(polyline)
				
			}
			
		}
		
		let startCoordinate = polylines?.first?.path?.coordinateAtIndex(0)
		
		let path = polylines?[(polylines?.count)! - 1].path
		let endCoordinate = path?.coordinateAtIndex((path?.count())! - 1)
		
		startCircle = GMSCircle.init(position: startCoordinate!, radius: 20)
		startCircle?.fillColor = UIColor.whiteColor()
		startCircle?.map = map
		endCircle = GMSCircle.init(position: endCoordinate!, radius: 20)
		endCircle?.fillColor = UIColor.whiteColor()
		endCircle?.map = map
		
	}
	
	func clear() {
		for polyline in polylines! {
			polyline.map = nil
		}
		
		startCircle?.map = nil
		endCircle?.map = nil
		
	}
}
