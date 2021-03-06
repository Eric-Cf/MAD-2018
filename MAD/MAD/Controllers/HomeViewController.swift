
//
//  CodeViewController.swift
//  ScalingCarousel
//
//  Created by Pete Smith on 29/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
//import ScalingCarousel
import Koloda
import MapKit
import Popover
import SwiftEntryKit

//class CodeCell: ScalingCarouselCell {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        mainView = UIView(frame: contentView.bounds)
//        contentView.addSubview(mainView)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class HomeViewController: UIViewController, TransactionProtocol, DownloadProtocol {
    
    
    
    
    
    var kolodaView: KolodaView!
//    fileprivate var scalingCarousel: ScalingCarouselView!
    @IBOutlet weak var mapView: MKMapView!
    var timer: Timer = Timer()
    var timeCounter: Int = 0
    let location = CLLocationCoordinate2DMake(37.33712,  -122.04898)
    let regionRadius: CLLocationDistance = 10
    
    @IBOutlet weak var innerScrollView: UIView!
    @IBOutlet weak var hoursView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var hoursButton: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpProfileButton()

    }
    
    var items_received = 0
    var books_received: [BookModel] = []
    
    func itemsDownloaded(items: NSArray, from: String) {
        print(String(describing: items.count) + " items downloaded from " + from)
        for item in items
        {
            if from == "HoldByUserReady"
            {
                self.items_received = items.count
                if let hold = item as? HoldModel
                {
                    print(hold.ISBN!)
                    let bookByISBN = IdSearchBook()
                    bookByISBN.delegate = self
                    let trimmedISBN = hold.ISBN!.replacingOccurrences(of: "-", with: "")
                    bookByISBN.downloadItems(isbn: trimmedISBN)
                }
            }
            else if from == "idSearch"
            {
                if let book = item as? BookModel
                {
                    print("Book received")
                    print(self.items_received)
                    print(self.books_received.count)
                    self.books_received.append(book)
                    if self.books_received.count == self.items_received
                    {
                        print("All books found")
                        for i in self.books_received
                        {
                            print(i.title!)
                        }
                        self.displayReadyHolds()
                    }
//                    print(book.title)
                }
            }
        }
    }
    
    func displayReadyHolds()
    {
        var attributes = EKAttributes.centerFloat
        attributes.entryBackground = .gradient(gradient: .init(colors: [.greenGrass, UIColor.init(red: 0.8, green: 1.0, blue: 0.2, alpha: 1.0)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .light
        attributes.displayDuration = 16
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        
        var titleText = ""
        if self.books_received.count > 1
        {
            titleText = "Your Holds Are Ready!"
        }
        else
        {
            titleText = "Your Hold Is Ready!"
        }
        
        let title = EKProperty.LabelContent(text: titleText, style: EKProperty.LabelStyle.init(font: MainFont.bold.with(size: 22), color: .white, alignment: NSTextAlignment.center, numberOfLines: 1))
        var descriptionText = ""
        for book in self.books_received
        {
            let bookTitle = book.title!
            descriptionText = descriptionText + "- " + bookTitle + "\n"
        }
        descriptionText.removeLast(1)
        let description = EKProperty.LabelContent(text: descriptionText, style: .init(font: MainFont.light.with(size: 19), color: UIColor.white))
        let image = EKPopUpMessage.ThemeImage(image: EKProperty.ImageContent(image: #imageLiteral(resourceName: "book")))
//        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
//        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        var buttonDescription = EKProperty.LabelContent(text: "Got It", style: .init(font: MainFont.light.with(size: 18), color: .gray))
        let buttonContent = EKProperty.ButtonContent(label: buttonDescription, backgroundColor: .white, highlightedBackgroundColor: .white, action: {
            print("Pop Up Dismissed")
            SwiftEntryKit.dismiss()
        })
//        EKPopUpMessage.EKPopUpMessageAction.
//        let popUpMessageAction = EKPopUpMessage.EKPopUpMessageAction -> ()
        let message = EKPopUpMessage(themeImage: image, title: title, description: description, button: buttonContent, action: {
            print("Pop Up Dismissed")
            SwiftEntryKit.dismiss()
        })

        let contentView = EKPopUpMessageView(with: message)
        
//        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func nothing()
    {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var loadFirstBooks = 0
        while loadFirstBooks < 6
        {
        loadFirstBooks = loadFirstBooks + 1
        self.recommendationBookArr.append(BookModel(databaseISBN: self.recommendedISBNs[0]))
        self.recommendedISBNs.remove(at: 0)
        }
        
        self.recommendedISBNs.shuffle()
        self.recommendationBookArr.shuffle()
        //addCarousel()
        addKoloda()
        self.hoursButton.layer.cornerRadius = 4
        self.hoursButton.layer.masksToBounds = true
        mapView.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        hoursView.layer.cornerRadius = 25
        hoursView.layer.masksToBounds = true
        self.mapView.mapType = MKMapType.satellite;
        //kolodaView.dataSource = self
        //kolodaView.delegate = self
        
            navigationController?.navigationBar.prefersLargeTitles = true
        tomorrowLabel.alpha = 0;
        scrollView.delegate = self
        mapView.layer.cornerRadius = 25
        mapView.layer.masksToBounds = true
        //mapView.setRegion(MKCoordinateRegion(), animated: false)
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(HomeViewController.action), userInfo: nil,  repeats: true)
        
        let getReadyHolds = HoldbyUserReady()
        getReadyHolds.delegate = self
        getReadyHolds.downloadItems(inputID: UserDefaults.standard.object(forKey: "userId") as! String)
        
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33712,  -122.04898), MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        
        imageView.setImage(#imageLiteral(resourceName: "user"), for: UIControlState.selected)
        imageView.setImage(#imageLiteral(resourceName: "user"), for: UIControlState.normal)

        
        
        
//        attributes = EKAttributes.centerFloat
//        attributes.entryBackground = .gradient(gradient: .init(colors: [.purple, .cyan], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
//        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
//        attributes.shadow = .active(with: .init(color: .white, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.statusBar = .dark
//        attributes.displayDuration = 9999999999
//        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        
//        formView = EKFormMessageView(with: formDescription, textFieldsContent: [textFieldContent], buttonContent: buttonContent)
//        SwiftEntryKit.display(entry: formView, using: attributes)

    }
    
    lazy var formView: EKFormMessageView = {
        let formDescription = EKProperty.LabelContent(text: "Confirm Your Student ID", style: .init(font: MainFont.bold.with(size: 22), color: UIColor.white))
        let placeholder = EKProperty.LabelContent(text: "Student ID", style: .init(font: MainFont.light.with(size: 20), color: UIColor.white))
        var buttonDescription = EKProperty.LabelContent(text: "Confirm", style: .init(font: MainFont.light.with(size: 18), color: .gray))
        let textFieldContent = EKProperty.TextFieldContent(keyboardType: UIKeyboardType.numberPad, placeholder: placeholder, textStyle: EKProperty.LabelStyle(font: MainFont.light.with(size: 20), color: .white), isSecure: false, leadingImage: #imageLiteral(resourceName: "id-card"), bottomBorderColor: .white)
        let buttonContent = EKProperty.ButtonContent(label: buttonDescription, backgroundColor: .white, highlightedBackgroundColor: .white, action: {
            print("Button pressed")
            let id = textFieldContent.textContent
            if id.count == 7
            {
                let setSchoolID = UserSetSchoolID()
                setSchoolID.delegate = self
                setSchoolID.setSchoolID(id: UserDefaults.standard.object(forKey: "userId") as! String, schoolid: id)
            }
            else if id.count > 0
            {
                buttonDescription.text = "Incorrect Length"
                self.invalidInput()
            }
            print(textFieldContent.textContent)
            
        })
        
        let temp = EKFormMessageView(with: formDescription, textFieldsContent: [textFieldContent], buttonContent: buttonContent)
        return temp
    }()
    
    func invalidInput()
    {
        var attributes = EKAttributes.centerFloat
        attributes.entryBackground = .gradient(gradient: .init(colors: [.greenGrass, UIColor.init(red: 0.8, green: 1.0, blue: 0.2, alpha: 1.0)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(scale: .init(from: 1, to: 0, duration: 1)))
        attributes.shadow = .active(with: .init(color: .white, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
//        attributes.
        attributes.statusBar = .light
        attributes.displayDuration = 9999999999
//        attributes.
//        SwiftEntryKit.display(entry: formView, using: attributes)
        formView.removeFromSuperview()
        let alert = UIAlertController(title: "Incorrect ID Length", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default) {
            UIAlertAction in
            SwiftEntryKit.display(entry: self.formView, using: attributes)
            
        })
        alert.addAction(UIAlertAction(title: "Skip", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Skipped")
            let setSchoolID = UserSetSchoolID()
            setSchoolID.delegate = self
            setSchoolID.setSchoolID(id: UserDefaults.standard.object(forKey: "userId") as! String, schoolid: "1234567")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func transactionProcessed(success: Bool) {
        print("Transaction processed")
        print("Result: " + String(describing: success))
    }
    
    
    
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }

    private func addKoloda() {
        
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        kolodaView = KolodaView(frame: frame)
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        //scalingCarousel.backgroundColor = .white
        //scalingCarousel.register(CodeCell.self, forCellWithReuseIdentifier: "cell")
        
        innerScrollView.addSubview(kolodaView)
        //kolodaView.center = innerScrollView.convert(innerScrollView.center, from:innerScrollView.superview)

        // Constraints
        kolodaView.widthAnchor.constraint(equalTo: innerScrollView.widthAnchor, multiplier: 0.45).isActive = true
        //kolodaView.centerXAnchor.constraint(equalTo: innerScrollView.centerXAnchor)
        kolodaView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        kolodaView.centerXAnchor.constraint(equalTo: innerScrollView.centerXAnchor, constant: 0.5).isActive = true
        kolodaView.topAnchor.constraint(equalTo: innerScrollView.topAnchor, constant: 10).isActive = true
        self.waitForDownload()
    }
    
    @objc func profileButtonClicked()
    {
        
        self.performSegue(withIdentifier: "profileSegue", sender: self)
        
    }
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    var imageView = UIButton()
    
    func setUpProfileButton()
    {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
//        navigationBar.alpha = 0.5
//        navigationBar.isTranslucent = true
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
        imageView.addTarget(self, action: #selector(self.profileButtonClicked), for: .touchUpInside)
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            //print(delta/heightDifferenceBetweenStates)
            return delta / heightDifferenceBetweenStates
            
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale+coeff*0.15, y: scale+coeff*0.15)
            //fix this
            .translatedBy(x: xTranslation-coeff*2, y: yTranslation+coeff*3)
    }
    
    @objc func action()
    {
        timeCounter = timeCounter + 1
        /*
        if(timeCounter == 8)
        {
            scalingCarousel.scrollToItem(at: IndexPath.init(row: 3, section: 0), at: UICollectionViewScrollPosition(rawValue: 2), animated: true)
            //self.innerScrollView.backgroundColor = UIColor(red: 160/255, green: 196/255, blue: 1, alpha: 1)

        }
 */
        if(timeCounter == 10)
        {
            //let duration = NSTimeIntervl
            MKMapView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33708,  -122.04896), MKCoordinateSpanMake(0.0005, 0.0005)), animated: true)
            }, completion: nil)
            
            
            // mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33712,  -122.04898), MKCoordinateSpanMake(0.0004, 0.00045)), animated: true)
        }
        if(timeCounter == 25)
        {
            let fantasyAnnotationCords = CLLocationCoordinate2DMake(37.3372,  -122.04904)
            let fantasyAnnotation = MKPointAnnotation.init()
            fantasyAnnotation.coordinate = fantasyAnnotationCords
            fantasyAnnotation.title = "Fantasy"
            self.mapView.addAnnotation(fantasyAnnotation)
            
            let mysteryAnnotationCords = CLLocationCoordinate2DMake(37.3372,  -122.048819)
            let mysteryAnnotation = MKPointAnnotation.init()
            mysteryAnnotation.coordinate = mysteryAnnotationCords
            mysteryAnnotation.title = "Mystery"
            self.mapView.addAnnotation(mysteryAnnotation)
            
            let scifiAnnotationCords = CLLocationCoordinate2DMake(37.3371,  -122.048796)
            let scifiAnnotation = MKPointAnnotation.init()
            scifiAnnotation.coordinate = scifiAnnotationCords
            scifiAnnotation.title = "Sci-Fi"
            self.mapView.addAnnotation(scifiAnnotation)
            
            let referenceAnnotationCords = CLLocationCoordinate2DMake/*(37.3372,  -122.048796)*/(37.33715,  -122.04892)
            let referenceAnnotation = MKPointAnnotation.init()
            referenceAnnotation.coordinate = referenceAnnotationCords
            referenceAnnotation.title = "Reference"
            self.mapView.addAnnotation(referenceAnnotation)
            
            let computerAnnotationCords = CLLocationCoordinate2DMake/*(37.3372,  -122.048796)*/(37.33704,  -122.04887)
            let computerAnnotation = MKPointAnnotation.init()
            computerAnnotation.coordinate = computerAnnotationCords
            computerAnnotation.title = "Computer"
            self.mapView.addAnnotation(computerAnnotation)
            
            //self.mapView.addAnnotation(annotation)
            
            MKMapView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.mapView.mapType = MKMapType.standard;
                
                
            }, completion: nil)
            
        }
        if(timeCounter == 26)
        {
            let overlay = LibraryOverlay()
            self.mapView.add(overlay)
        }
        if(timeCounter == 35)
        {
            MKMapView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33708,  -122.04896), MKCoordinateSpanMake(0.0005, 0.0005)), animated: true)
            }, completion: nil)
        }
    }
    @IBAction func hoursInfoButtonPressed(_ sender: Any)
    {
        if let url = URL(string: "https://hhs.fuhsd.org/academics/library") {
            UIApplication.shared.open(url, options: [:])
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func rightSwipePressed(_ sender: Any)
    {
        self.kolodaView.swipe(SwipeResultDirection.right)
    }
    
    @IBAction func leftSwipePressed(_ sender: Any)
    {
        self.kolodaView.swipe(SwipeResultDirection.left)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bookToPass = self.recommendationBookArr[bookSwipedID]
        if let destinationViewController = segue.destination as? BookDetailViewController {
            destinationViewController.selectedBook = bookToPass
        }
    }
    
    var bookSwipedID: Int = 0
    
//    private func addCarousel() {
//
//        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//        scalingCarousel = ScalingCarouselView(withFrame: frame, andInset: 100)
//        scalingCarousel.dataSource = self
//        scalingCarousel.delegate = self
//        scalingCarousel.translatesAutoresizingMaskIntoConstraints = false
//        scalingCarousel.backgroundColor = .white
//        scalingCarousel.register(CodeCell.self, forCellWithReuseIdentifier: "cell")
//
//        innerScrollView.addSubview(scalingCarousel)
//
//        // Constraints
//        scalingCarousel.widthAnchor.constraint(equalTo: innerScrollView.widthAnchor, multiplier: 1).isActive = true
//        scalingCarousel.heightAnchor.constraint(equalToConstant: 260).isActive = true
//        scalingCarousel.leadingAnchor.constraint(equalTo: innerScrollView.leadingAnchor).isActive = true
//        scalingCarousel.topAnchor.constraint(equalTo: innerScrollView.topAnchor, constant: 10).isActive = true
//    }
    var coverTimer: Timer = Timer()
    let images = [#imageLiteral(resourceName: "sampleCover2"), #imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2"),#imageLiteral(resourceName: "sampleCover2")]
    
    var recommendationBookArr: [BookModel] = []
    
    var recommendedISBNs = ["978-0-374-53451-6", "0-15-602732-1", "978-0-544-57097-9", "0-316-52613-4", "978-1-55652-976-4", "978-0-06-247250-2", "1-59448-329-9", "978-0-06-233175-5", "978-0-7636-5866-3", "1-56689-011-X", "978-1-42310334-9", "0-525-94527-X", "978-1-25001019-3", "978-0-393-08905-9", "978-0-06-247250-2", "978-1-61695-847-3", "0-345-38421-0", "978-0-7636-7382-6", "978-0-545-20889-5", "0-15-602732-1", "978-0-545-01022-1", "8-47888445-9", "0-486-41434-5", "978-1-62672-315-3", "978-7-50635153-9", "978-1-41971915-8", "978-1-59102-501-6", "978-0-374-53164-5"]
    
    
    var cardsToCheck: [Int] = [0, 1, 2, 3, 4, 5, 6]
    var numCards: Int = 0
    var counter: Int = 0

    @IBOutlet weak var tomorrowLabel: UILabel!
    
}

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

extension HomeViewController: KolodaViewDataSource {
    
    
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return recommendationBookArr.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.moderate
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let image: UIImage? = recommendationBookArr[index].getImage()
        if(image?.isEqual(#imageLiteral(resourceName: "loadingImage")))!
        {
            return UIImageView(image: UIImage())
            //sleep(1)
            /*
            cardsToCheck.append(index)
            print("waiting")
            if let url = URL(string: "http://covers.openlibrary.org/b/isbn/" + recommendationBookArr[index].ISBN! + "-L.jpg")
            {
                print("testPoint3")

                //return UIImageView(image: self.downloadCoverImage(url: url))
            }
 */
        }
       // print("testPoint4")

        return UIImageView(image: recommendationBookArr[index].BookCoverImage.image)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadCoverImage(url: URL) -> UIImage {
        var returnedImage: UIImage = #imageLiteral(resourceName: "loadingImage")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            
            DispatchQueue.main.async() {
                let temp: UIImage? = UIImage(data: data)
                if(temp != nil && Double((temp?.size.height)!)>20.0)
                {
                    
                    returnedImage = temp!
                    print("testPoint1")
                }
                
                
            }
        }
        print("testPoint2")
        return returnedImage
        
    }
    
    func waitForDownload()
    {
        coverTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(HomeViewController.downloadCheck), userInfo: nil,  repeats: true)

    }
    
    @objc func downloadCheck()
    {
        //print("download check")
        if(counter<2)
        {
            let image = recommendationBookArr[counter].getImage()
            if(image.isEqual(#imageLiteral(resourceName: "loadingImage")))
            {
                
            }
            else
            {
                print("found:")
                print(counter)
                //cardsToCheck.remove(at: counter)
                let temp = counter + 1
                counter = temp
                //kolodaView.insertCardAtIndexRange(CountableRange(counter...counter))
                numCards = numCards + 1
            }
        }
        if(counter == 2)
        {
            print("All downloaded")
            self.kolodaView.reloadData()
            coverTimer.invalidate()
        }
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)![0] as? OverlayView
        return OverlayView()
    }
}

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
        UIView.animate(withDuration: 1, animations: {self.tomorrowLabel.alpha = 1;})
        
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        let bookTitleLabel = UILabel.init(frame: CGRect.init(x: 10, y: 10, width: 140, height: 22))
        bookTitleLabel.text = self.recommendationBookArr[index].title
        bookTitleLabel.font = UIFont (name: "HelveticaNeue-Medium", size: 18)
        bookTitleLabel.textAlignment = NSTextAlignment.center
        aView.addSubview(bookTitleLabel)
        let authorTitleLabel = UILabel.init(frame: CGRect.init(x: 10, y: 29, width: 140, height: 18))
        authorTitleLabel.text = self.recommendationBookArr[index].author
        authorTitleLabel.font = UIFont (name: "HelveticaNeue-Medium", size: 12)
        authorTitleLabel.textColor = UIColor.darkGray
        authorTitleLabel.textAlignment = NSTextAlignment.center
        aView.addSubview(authorTitleLabel)
        let options = [
            .type(.down),
            .cornerRadius(8),
            .animationIn(0.2),
            .animationOut(0.1),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.05)),
            .arrowSize(CGSize(width: 16.0, height: 10.0))
            //.border
            ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.show(aView, fromView: self.kolodaView)

    
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if(direction == SwipeResultDirection.right)
        {
            self.bookSwipedID = index
            self.performSegue(withIdentifier: "rightSwipeSegue", sender: self)
            
            //print(self.recommendationBookArr[index].title)
        }
//        else if(direction == SwipeResultDirection.left)
//        {
//
//        }
        self.kolodaView.reloadData()
        print("Reloading Koloda View")
        if self.recommendedISBNs.count > 0
        {
            self.recommendationBookArr.append(BookModel(databaseISBN: self.recommendedISBNs[0]))
            
            self.recommendedISBNs.remove(at: 0)
        }
    }
   
    
}


extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
//        if let scalingCell = cell as? ScalingCarouselCell {
//            scalingCell.mainView.backgroundColor = .blue
//            let imageView = UIImageView(image: #imageLiteral(resourceName: "sampleCover"))
//            imageView.frame = CGRect(x: 8, y: 0, width: scalingCell.mainView.frame.width-16, height: scalingCell.mainView.frame.height)
//            scalingCell.mainView.backgroundColor = UIColor.clear
//            scalingCell.mainView.addSubview(imageView)
//            imageView.layer.cornerRadius = 4;
//            imageView.layer.masksToBounds = true;
//        }
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //scalingCarousel.didScroll()
    }
}
extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }
    
   
}



extension HomeViewController: MKMapViewDelegate
{
    
    
    /*
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
     print("made it here")
     if overlay is LibraryOverlay {
     return LibraryOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "mapOverlay"))
     }
     return MKOverlayRenderer()
     }
     */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = #imageLiteral(resourceName: "xButton")
            let temp = MKMarkerAnnotationView.init(annotation: annotation, reuseIdentifier: "temp")
            //temp.glyphImage = #imageLiteral(resourceName: "xButton")
            if(annotation.title!!.isEqual("Fantasy") == true)
            {
                temp.glyphImage = #imageLiteral(resourceName: "fantasySmall")
                temp.selectedGlyphImage = #imageLiteral(resourceName: "fantasyBig")
                temp.markerTintColor = UIColor.init(red: 0.92, green: 0.63, blue: 1.0, alpha: 1.0)
            }
            else if(annotation.title!!.isEqual("Mystery") == true)
            {
                temp.glyphImage = #imageLiteral(resourceName: "mysterySmall")
                temp.selectedGlyphImage = #imageLiteral(resourceName: "mysteryBig")
                //temp.markerTintColor = UIColor.init(red: 0.92, green: 0.63, blue: 1.0, alpha: 1.0)
                temp.markerTintColor = UIColor.blue
            }
            else if(annotation.title!!.isEqual("Sci-Fi") == true)
            {
                temp.glyphImage = #imageLiteral(resourceName: "scifiSmall")
                temp.selectedGlyphImage = #imageLiteral(resourceName: "scifiBig")
                //temp.markerTintColor = UIColor.init(red: 0.92, green: 0.63, blue: 1.0, alpha: 1.0)
                //temp.markerTintColor = UIColor.blue
            }
            else if(annotation.title!!.isEqual("Reference") == true)
            {
                print("Reference")
                temp.glyphImage = #imageLiteral(resourceName: "referenceSmall")
                temp.selectedGlyphImage = #imageLiteral(resourceName: "referenceBig")
                //temp.markerTintColor = UIColor.init(red: 0.92, green: 0.63, blue: 1.0, alpha: 1.0)
                temp.markerTintColor = UIColor.darkGray
            }
            else if(annotation.title!!.isEqual("Computer") == true)
            {
                temp.glyphImage = #imageLiteral(resourceName: "computerSmall")
                temp.selectedGlyphImage = #imageLiteral(resourceName: "computerBig")
                //temp.markerTintColor = UIColor.init(red: 0.92, green: 0.63, blue: 1.0, alpha: 1.0)
                temp.markerTintColor = UIColor.cyan
            }
            //temp.glyphText = "Fantasy"
            //temp.title
            temp.titleVisibility = .adaptive
            // if you want a disclosure button, you'd might do something like:
            //
            let detailButton = UIButton(type: .infoLight)
            annotationView?.rightCalloutAccessoryView = detailButton
            return temp
            
        } else
        {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue
            circleRenderer.alpha = 0.05
            return circleRenderer
        }
        else if let overlay = overlay as? MKPolygon {
            let circleRenderer = MKPolygonRenderer(polygon: overlay)
            circleRenderer.fillColor = UIColor.red
            circleRenderer.alpha = 0.05
            return circleRenderer
        }
        else {
            if overlay is LibraryOverlay {
                return LibraryOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "mapOverlay2"))
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}



