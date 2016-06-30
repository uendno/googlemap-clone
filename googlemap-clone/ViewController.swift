//
//  ViewController.swift
//  googlemap-clone
//
//  Created by Thang Tran on 6/13/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import UIKit
import GoogleMaps
import TNImageSliderViewController
import Kingfisher

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// MARK: Outlets
	@IBOutlet var tableView: UITableView!
	@IBOutlet var imageBottomContraint: NSLayoutConstraint!
	@IBOutlet var floatingLabelBottomContraint: NSLayoutConstraint!
	
	@IBOutlet var numOfReviewsLabel: UILabel!
	@IBOutlet var placeNameLabel: UILabel!
	@IBOutlet var floatingLabel: UIView!
	@IBOutlet var image: UIView!
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var btnNavigate: UIButton!
	@IBOutlet var btnMyLocation: UIButton!
	
	// MARK: Actions
	
	@IBAction func showPhotos(sender: AnyObject) {
		
		self.performSegueWithIdentifier("showPhotos", sender: self)
		
	}
	
	@IBAction func showMyLocation(sender: AnyObject) {
		
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.translucent = true
		self.navigationController?.view.backgroundColor = UIColor.clearColor()
		self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
		
		btnNavigate.enabled = false
		
		placeClient.currentPlaceWithCallback({
			(placeLikelihoods, error) -> Void in
			
			guard error == nil else {
				print("Current Place error: \(error!.localizedDescription)")
				return
			}
			
			if let placeLikelihoods = placeLikelihoods {
				let place = placeLikelihoods.likelihoods[0].place
				self.selectedPlace = place
				
				self.mapView.animateToLocation(CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
				
				self.btnNavigate.enabled = true
				
			}
			
		})
	}
	
	private var resultsViewController: GMSAutocompleteResultsViewController?
	private var searchController: UISearchController?
	private var resultView: UITextView?
	private var placeClient: GMSPlacesClient!
	private var selectedPlace: GMSPlace?
	private var photos: [UIImage]? = []
	private var reviews: [PlaceReviewResponse]? = []
	private var nearbyPlaces: [NearbyPlaceResponse]? = []
	private var infos: [String: String]? = [:]
	
	var imageSliderVC: TNImageSliderViewController!
	
	// MARK: - Lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// set image and floatingLabel starting location
		floatingLabel?.hidden = true
		imageSliderVC.view.hidden = true
		imageBottomContraint.constant = image.frame.height - floatingLabel.frame.height
		floatingLabelBottomContraint.constant = 0
		
		btnNavigate.enabled = false
		
		// Map
		let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 15)
		self.mapView.camera = camera
		self.mapView.myLocationEnabled = true
		self.mapView.settings.compassButton = true
		placeClient = GMSPlacesClient.sharedClient();
		
		placeClient.currentPlaceWithCallback({
			(placeLikelihoods, error) -> Void in
			
			guard error == nil else {
				print("Current Place error: \(error!.localizedDescription)")
				return
			}
			
			if let placeLikelihoods = placeLikelihoods {
				let place = placeLikelihoods.likelihoods[0].place
				self.selectedPlace = place
				
				self.mapView.animateToLocation(CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
				
				self.btnNavigate.enabled = true
				
			}
			
		})
		
		//
		resultsViewController = GMSAutocompleteResultsViewController()
		resultsViewController?.delegate = self
		
		searchController = UISearchController(searchResultsController: resultsViewController)
		searchController?.searchResultsUpdater = resultsViewController
		
		// Put the search bar in the navigation bar.
		searchController?.searchBar.sizeToFit()
		self.navigationItem.titleView = searchController?.searchBar
		
		searchController?.hidesNavigationBarDuringPresentation = false
		
		// When UISearchController presents the results view, present it in
		// this view controller, not one further up the chain.
		self.definesPresentationContext = true
		
		// Prevent the navigation bar from being hidden when searching.
		searchController?.hidesNavigationBarDuringPresentation = false
		
		// table view
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 160.0
		
		// imageSlider
		// imageSliderVC.images = [UIImage()]
		
		var options = TNImageSliderViewOptions()
		options.pageControlHidden = false
		options.scrollDirection = .Horizontal
		options.pageControlCurrentIndicatorTintColor = UIColor.whiteColor()
		// options.autoSlideIntervalInSeconds = 2
		// options.shouldStartFromBeginning = true
		options.imageContentMode = .ScaleAspectFill
		imageSliderVC.options = options
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		print("[ViewController] Prepare for segue")
		
		if (segue.identifier == "seg_imageSlider") {
			
			imageSliderVC = segue.destinationViewController as! TNImageSliderViewController
			
		} else if (segue.identifier == "showPhotos") {
			(segue.destinationViewController as! PhotosViewController).photos = imageSliderVC.images
			(segue.destinationViewController as! PhotosViewController).collectionView?.reloadData()
			
		}
		
	}
	
	// MARK: Touch and Scroll controll functions
	
	// touch coordinate
	private var oldY: CGFloat = CGFloat.max
	private var startY: CGFloat = CGFloat.max
	
	// screen status
	private var isDragging: Bool = false // user is dragging floatingNameLabel
	private var screenStatus: Int = ON_STOP
	private static let ON_MAP: Int = 100 // map is on screen
	private static let ON_SLIDE_BAR: Int = 101 // place info screen with slideBar
	private static let ON_FULLSCREEN_INFO: Int = 102 // place info full screen
	private static let ON_STOP: Int = 103
	
	// touch functions
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = event?.allTouches()?.first
		let touchLocation = touch?.locationInView(self.view)
		
		// if map is on screen and user drags floatingNameLabel up
		if screenStatus == ViewController.ON_MAP {
			if CGRectContainsPoint(floatingLabel.frame, touchLocation!) {
				
				isDragging = true
				oldY = (touchLocation?.y)!
				startY = oldY
				
			}
		}
		
		// if slide bar is on screen and user touch on anything, make navigation item be default style
		if screenStatus == ViewController.ON_SLIDE_BAR {
			
			self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
			
			isDragging = true
			
			oldY = (touchLocation?.y)!
			startY = oldY
			
		}
		
		// if user is on full screen info
		if screenStatus == ViewController.ON_FULLSCREEN_INFO {
			
			// if 1st cell is on screen
			if (tableView.indexPathForCell(tableView.visibleCells.first!)?.row == 0) {
				
				print("ROW 0 IS ON SCREEN")
				
				isDragging = true
				oldY = (touchLocation?.y)!
				startY = oldY
			}
		}
		
		if screenStatus == ViewController.ON_STOP {
			if CGRectContainsPoint(floatingLabel.frame, touchLocation!) {
				
				isDragging = true
				oldY = (touchLocation?.y)!
				startY = oldY
				
			}
		}
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = event?.allTouches()?.first
		let touchLocation = touch?.locationInView(self.view)
		
		if isDragging {
			
			// DEBUG
			var upDown: String
			var screen: String = String()
			
			if touchLocation?.y >= oldY {
				upDown = "DOWN"
			} else {
				upDown = "UP"
			}
			
			if screenStatus == ViewController.ON_MAP {
				screen = "MAP"
			} else if screenStatus == ViewController.ON_SLIDE_BAR {
				screen = "SLIDE BAR"
			} else if screenStatus == ViewController.ON_FULLSCREEN_INFO {
				screen = "FULL SCREEN INFO"
			} else if screenStatus == ViewController.ON_STOP {
				screen = "STOP"
			}
			
			print("dragging \(upDown) from \(screen): \(oldY) -> \(touchLocation!.y)")
			
			if screenStatus == ViewController.ON_STOP {
				if touchLocation?.y <= oldY {
					// if user's dragging up floatingNameLabel when on stop
					
					screenStatus = ViewController.ON_MAP
				}
			}
			
			if screenStatus == ViewController.ON_MAP {
				
				// Stop conditions
				
				if floatingLabelBottomContraint.constant >= 0 {
					screenStatus = ViewController.ON_STOP
				}
				
				if floatingLabelBottomContraint.constant <= -(self.view.frame.height - image.frame.height - floatingLabel.frame.height) {
					screenStatus = ViewController.ON_SLIDE_BAR
				}
				
				// if user's dragging up/down floatingNameLabel when map is onscreen
				
				floatingLabelBottomContraint.constant = floatingLabelBottomContraint.constant + (touchLocation?.y)! - oldY
				imageBottomContraint.constant = ((self.view.frame.height - floatingLabel.frame.height) / (self.view.frame.height - floatingLabel.frame.height - image.frame.height)) * floatingLabelBottomContraint.constant + image.frame.height - floatingLabel.frame.height
				
			}
			
			if screenStatus == ViewController.ON_SLIDE_BAR {
				
				// stop condition
				if floatingLabelBottomContraint.constant >= -(self.view.frame.height - image.frame.height - floatingLabel.frame.height) {
					
					screenStatus = ViewController.ON_MAP
					self.navigationItem.title = nil
					self.navigationItem.titleView = searchController?.searchBar
				} else {
					// if user's dragging up/down floatingNameLabel when slideBar is onscreen
					floatingLabelBottomContraint.constant = floatingLabelBottomContraint.constant + (touchLocation?.y)! - oldY
					imageBottomContraint.constant = -(self.view.frame.height - image.frame.height)
					
					self.navigationItem.titleView = nil
					self.navigationItem.title = selectedPlace?.name
					
				}
				
			}
			
		}
		
		oldY = (touchLocation?.y)!
		
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = event?.allTouches()?.first
		let touchLocation = touch?.locationInView(self.view)
		
		print("ENDED")
		
		isDragging = false
		
		if screenStatus == ViewController.ON_MAP {
			if touchLocation?.y <= startY {
				// if user's dragging up floatingNameLabel when map is onscreen
				
				print("1")
				
				floatingLabelBottomContraint.constant = -(self.view.frame.height - image.frame.height - floatingLabel.frame.height)
				imageBottomContraint.constant = -(self.view.frame.height - image.frame.height)
				screenStatus = ViewController.ON_SLIDE_BAR
				
				UIView.animateWithDuration(0.5, animations: {
					self.view.layoutIfNeeded()
					}, completion: { (result) in
					
					self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
					self.navigationController?.navigationBar.shadowImage = UIImage()
					self.navigationController?.navigationBar.translucent = true
					self.navigationController?.view.backgroundColor = UIColor.clearColor()
					self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
					self.navigationItem.titleView = nil
				})
			} else {
				
				print("2")
				// if user's dragging down floatingNameLabel when map is onscreen
				
				floatingLabelBottomContraint.constant = 0
				imageBottomContraint.constant = image.frame.height - floatingLabel.frame.height
				screenStatus = ViewController.ON_STOP
				
				UIView.animateWithDuration(0.5, animations: {
					self.view.layoutIfNeeded()
					}, completion: nil)
			}
		} else if screenStatus == ViewController.ON_SLIDE_BAR {
			if touchLocation?.y >= startY {
				// if user's dragging down floatingNameLabel when slideBar is onscreen
				floatingLabelBottomContraint.constant = 0
				imageBottomContraint.constant = image.frame.height - floatingLabel.frame.height
				screenStatus = ViewController.ON_MAP
				
				UIView.animateWithDuration(0.5) {
					self.view.layoutIfNeeded()
				}
			} else {
				// if user's dragging up floatingNameLabel when slideBar is onscreen
				floatingLabelBottomContraint.constant = -self.view.frame.height + floatingLabel.frame.height
				
				screenStatus = ViewController.ON_FULLSCREEN_INFO
				
				UIView.animateWithDuration(0.5) {
					self.view.layoutIfNeeded()
				}
			}
		}
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		touchesEnded(touches!, withEvent: event)
	}
	
	private var lastOffset: CGFloat!
	
	// Start scolling
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		
		isDragging = true
		
		// if slide bar is on screen and user touch on anything, make navigation item be default style
		if screenStatus == ViewController.ON_SLIDE_BAR {
			
			self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
			
		}
	}
	
	// Scrolling
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		print(scrollView.contentOffset.y)
		if screenStatus == ViewController.ON_SLIDE_BAR {
			
			// stop conditions
			if floatingLabelBottomContraint.constant > -(self.view.frame.height - image.frame.height - floatingLabel.frame.height) {
				
				self.navigationItem.titleView = searchController?.searchBar
				screenStatus = ViewController.ON_MAP
			}
			
			if floatingLabelBottomContraint.constant < -(self.view.frame.height - image.frame.height - floatingLabel.frame.height) {
				self.navigationItem.titleView = nil
				self.navigationItem.title = selectedPlace?.name
				
			}
			
			if floatingLabelBottomContraint.constant < -(self.view.frame.height - floatingLabel.frame.height) {
				
				screenStatus = ViewController.ON_FULLSCREEN_INFO
			}
			
			let isInBound = floatingLabelBottomContraint.constant - scrollView.contentOffset.y >= -(self.view.frame.height - floatingLabel.frame.height)
			if isInBound {
				floatingLabelBottomContraint.constant = floatingLabelBottomContraint.constant - scrollView.contentOffset.y
				imageBottomContraint.constant = -(self.view.frame.height - image.frame.height)
				
			}
			
			if scrollView.contentOffset.y != 0 {
				lastOffset = scrollView.contentOffset.y
				scrollView.contentOffset.y = 0
			}
			
		}
		
		if screenStatus == ViewController.ON_MAP {
			
			// stop condition
			if floatingLabelBottomContraint.constant >= 0 {
				screenStatus = ViewController.ON_STOP
			}
			
			if floatingLabelBottomContraint.constant <= -(self.view.frame.height - image.frame.height - floatingLabel.frame.height) {
				screenStatus = ViewController.ON_SLIDE_BAR
			}
			
			// if user's dragging up/down floatingNameLabel when map is onscreen
			
			floatingLabelBottomContraint.constant = floatingLabelBottomContraint.constant - scrollView.contentOffset.y
			imageBottomContraint.constant = ((self.view.frame.height - floatingLabel.frame.height) / (self.view.frame.height - floatingLabel.frame.height - image.frame.height)) * floatingLabelBottomContraint.constant + image.frame.height - floatingLabel.frame.height
			
			if scrollView.contentOffset.y != 0 {
				lastOffset = scrollView.contentOffset.y
				scrollView.contentOffset.y = 0
			}
			
		}
		
		if screenStatus == ViewController.ON_FULLSCREEN_INFO {
			if scrollView.contentOffset.y < 0 {
				screenStatus = ViewController.ON_SLIDE_BAR
			}
		}
		
		scrollView.scrollEnabled = true
	}
	
	// End scroll
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		print("END SCROLL. lastOffset = \(lastOffset)")
		
		if screenStatus == ViewController.ON_SLIDE_BAR {
			if lastOffset < 0 {
				// if user's dragging down floatingNameLabel when slideBar is onscreen
				
				floatingLabelBottomContraint.constant = -(self.view.frame.height - image.frame.height - floatingLabel.frame.height)
				imageBottomContraint.constant = -(self.view.frame.height - image.frame.height)
				
				UIView.animateWithDuration(0.5, animations: {
					self.view.layoutIfNeeded()
					}, completion: { (result) in
					
					self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
					self.navigationController?.navigationBar.shadowImage = UIImage()
					self.navigationController?.navigationBar.translucent = true
					self.navigationController?.view.backgroundColor = UIColor.clearColor()
					self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
					self.navigationItem.titleView = nil
					self.navigationItem.title = nil
				})
			} else {
				// if user's dragging up floatingNameLabel when slideBar is onscreen
				floatingLabelBottomContraint.constant = -self.view.frame.height + floatingLabel.frame.height
				
				screenStatus = ViewController.ON_FULLSCREEN_INFO
				
				UIView.animateWithDuration(0.5) {
					self.view.layoutIfNeeded()
				}
			}
		}
		
		if screenStatus == ViewController.ON_MAP {
			
			if lastOffset < 0 {
				// if user's dragging down floatingNameLabel when map is onscreen
				
				floatingLabelBottomContraint.constant = 0
				imageBottomContraint.constant = image.frame.height - floatingLabel.frame.height
				screenStatus = ViewController.ON_STOP
				
				UIView.animateWithDuration(0.5, animations: {
					self.view.layoutIfNeeded()
					}, completion: nil)
				
			} else {
				
				// if user's dragging up floatingNameLabel when map is onscreen
				floatingLabelBottomContraint.constant = -(self.view.frame.height - image.frame.height - floatingLabel.frame.height)
				imageBottomContraint.constant = -(self.view.frame.height - image.frame.height)
				
				screenStatus == ViewController.ON_SLIDE_BAR
				
				UIView.animateWithDuration(0.5) {
					self.view.layoutIfNeeded()
				}
			}
		}
	}
	
	// MARK: TableView controll functions
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return (infos?.count)!
		case 2:
			
			if self.imageSliderVC.images?.first != nil {
				return 1
			} else {
				return 0
			}
		case 3:
			if self.reviews != nil {
				return (self.reviews?.count)!
			} else {
				return 0
			}
		case 4:
			return 1
		default:
			return 0
		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 3 {
			
			if reviews?.count > 0 {
				return "Reviews"
			} else {
				return nil
			}
			
		} else if section == 4 {
			
			if self.nearbyPlaces?.count > 0 {
				return "Nearby Places"
			} else {
				return nil
			}
			
		} else {
			return nil
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell: UITableViewCell
		
		switch indexPath.section {
		case 0:
			// action cell
			cell = tableView.dequeueReusableCellWithIdentifier("ActionCell", forIndexPath: indexPath)
			break
		case 1:
			// info cell
			cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath)
			if let infos = self.infos {
				
				let key = infos.keys[infos.startIndex.advancedBy(indexPath.row)]
				
				switch key {
				case "address":
					(cell as! InfoCell).icon.image = UIImage.init(named: "location")
					break
				case "phone":
					(cell as! InfoCell).icon.image = UIImage.init(named: "phone")
					break
				case "web":
					(cell as! InfoCell).icon.image = UIImage.init(named: "earth")
					break
				default:
					break
					
				}
				(cell as! InfoCell).info.text = infos[key]
			}
			break
		case 2:
			
			cell = tableView.dequeueReusableCellWithIdentifier("PhotosCell", forIndexPath: indexPath)
			if let images = self.imageSliderVC.images {
				(cell as! PhotosCell).firstPhoto.image = images.first
				(cell as! PhotosCell).numOfPhoto.text = "\(imageSliderVC.images.count) photos"
				
			} else {
				(cell as! PhotosCell).numOfPhoto.text = "No photo"
			}
			break
			
		case 3:
			
			cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath)
			let review = self.reviews![indexPath.row]
			
			let date = NSDate.init(timeIntervalSince1970: review.time)
			let formatter = NSDateFormatter();
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			formatter.timeZone = NSTimeZone.systemTimeZone()
			(cell as! ReviewCell).userNameLabel.text = review.authorName
			(cell as! ReviewCell).timeLabel.text = "\(formatter.stringFromDate(date))"
			(cell as! ReviewCell).descriptionLabel.text = "                     \(review.text!)"
			(cell as! ReviewCell).rateView.rating = Double(review.rating)
			
			if let avatarURL = review.avatarURL {
				(cell as! ReviewCell).avatar.kf_setImageWithURL(NSURL(string: "http:\(avatarURL)")!, placeholderImage: UIImage.init(named: "avatar"))
			} else {
				(cell as! ReviewCell).avatar.image = UIImage.init(named: "avatar")
			}
			(cell as! ReviewCell).avatar.layer.cornerRadius = (cell as! ReviewCell).avatar.frame.size.width / 2;
			(cell as! ReviewCell).avatar.clipsToBounds = true;
			
			break
			
		case 4:
			cell = tableView.dequeueReusableCellWithIdentifier("NearByPlacesCell", forIndexPath: indexPath)
			(cell as! NearByPlacesCell).nearbyPlaces = self.nearbyPlaces
			(cell as! NearByPlacesCell).collectionView.reloadData()
			
			print("NUMBER OF NEARBY PLACES:\(self.nearbyPlaces?.count)")
			
			break
		default:
			cell = UITableViewCell.init(style: .Default, reuseIdentifier: "")
		}
		
		return cell
	}
	
}

// MARK: Handle the user's selection.
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
	func resultsController(resultsController: GMSAutocompleteResultsViewController,
		didAutocompleteWithPlace place: GMSPlace) {
			searchController?.active = false
			
			// Do something with the selected place.
			self.selectedPlace = place
			
			self.btnNavigate.enabled = true
			
			// set info for floatingLabel
			floatingLabel.hidden = false
			imageSliderVC.view.hidden = false
			
			placeNameLabel.text = place.name
			numOfReviewsLabel.text = "Loading..."
			
			// move map to place
			self.mapView.animateToLocation(CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
			
			// get reviews and nearby places
			
			self.reviews = []
			self.nearbyPlaces = []
			
			let client = APIClient(baseURLString: "http://128.199.151.182:3000/places/")
			client.getPlaceDetails(place.placeID, completionHandler: { (response, error) in
				self.reviews = response?.reviews
				self.nearbyPlaces = response?.nearbyPlaces
				
				if self.reviews != nil {
					self.numOfReviewsLabel.text = "\(self.reviews!.count) reviews"
				} else {
					self.numOfReviewsLabel.text = "No reviews"
				}
				
				self.tableView.reloadData()
				
			})
			
			// load photos
			
			imageSliderVC.images = []
			placeClient.lookUpPhotosForPlaceID(place.placeID) { (photos, error) -> Void in
				if let error = error {
					// TODO: handle the error.
					print("Error: \(error.description)")
				} else {
					for photoData in (photos?.results)! {
						
						self.placeClient.loadPlacePhoto(photoData, constrainedToSize: self.imageSliderVC.view.bounds.size, scale: self.imageSliderVC.view.window!.screen.scale, callback: { (photo, error) -> Void in
							if let error = error {
								// TODO: handle the error.
								print("Error: \(error.description)")
							} else {
								let image: UIImage = photo!;
								self.imageSliderVC.images.append(image)
								
								self.tableView.reloadData()
							}
						})
						
					}
				}
				
				// load info
				print("opend now: \(place.openNowStatus.rawValue)")
				for type: String in place.types {
					print("type: \(type)")
				}
				
				self.infos = [:]
				
				if let address = place.formattedAddress {
					self.infos?["address"] = address
				}
				
				if let phone = place.phoneNumber {
					self.infos?["phone"] = phone
				}
				
				if let web = place.website {
					self.infos?["web"] = web.URLString
				}
				
				self.tableView.reloadData()
			}
	}
	
	func resultsController(resultsController: GMSAutocompleteResultsViewController,
		didFailAutocompleteWithError error: NSError) {
			// TODO: handle the error.`
			print("Error: ", error.description)
	}
	
	// Turn the network activity indicator on and off again.
	func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	}
	
	func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
	
}

