//
//  BookDetailViewController.swift
//  MAD
//
//  Created by NonAdmin Eric on 10/30/17.
//  Copyright © 2017 Eric C. All rights reserved.
//http://covers.openlibrary.org/b/isbn/9780385533225-L.jpg

import Foundation
import UIKit
import MapKit
import Lottie
//import Alamofire //error disappears at build time
//import ObjectMapper


class BookDetailViewController : UIViewController, DownloadProtocol, TransactionProtocol, UIWebViewDelegate{
    
    var myWebView: UIWebView = UIWebView()
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var authorLabel:UILabel?
    @IBOutlet weak var reviewButton: UIButton!
    var holdButtonHidden: Bool = false
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var descBox: UITextView!
    var imageURL: String = ""
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var checkoutButton: UIButton!
    var foundGoogleImage: Bool = false;
    static var ISBN:String = "";
    var rawDescription: String = "[loading description]";
    @IBOutlet weak var TitleView: UIView!
    @IBOutlet weak var reserveButtonImage: UIImageView!
    @IBOutlet weak var BookCoverImage: UIImageView!
//    @IBOutlet weak var genreImage: UIImageView! = UIImageView(image: #imageLiteral(resourceName: "drama"))
//    @IBOutlet weak var statusImage: UIImageView! = UIImageView(image: #imageLiteral(resourceName: "greencheck.png"))
    @IBOutlet weak var descriptionLabel: UILabel!
    var userInteractionCommitted: Bool = false
    var timer: Timer = Timer.init()
    var loadTimer: Timer? = Timer.init()
    var fromScanner: Bool = false
    var smallCoverImageCounter: Int = 0;
    var loadedRating: Bool = false
    @IBAction func DoneButton(_ sender: Any) {
       // _ = popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    //Expands the
    @IBAction func expandDescription(_ sender: Any) {
        print("Uptime: " + String(Int(ProcessInfo.processInfo.systemUptime)))
        //descBox?.attributedText = NSAttributedString(string: rawDescription,  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ])
        //descBox.sizeToFit();
    }
    
    var selectedBook : BookModel?
    
    var fromSB: segues?
    
    enum segues {
        case fromMyBooksViewController
        case fromDiscoverViewController
        case fromCheckoutViewController
    }
    
    @IBAction func reserveButton(_ sender: Any) {
        if(self.checkoutButton.currentTitle! == "Hold")
        {
        self.performSegue(withIdentifier: "reserveSegue", sender: self)
        }
        else if(self.checkoutButton.currentTitle! == "Unavailable")
        {
            let bookInsert = BookInsert.init()
            /*
            print(self.selectedBook!.ISBN!)
            print(self.selectedBook!.title!)
            print(self.selectedBook!.author!)
            print(self.selectedBook!.desc)
            */
            bookInsert.delegate = self
            bookInsert.downloadItems(isbn: self.selectedBook!.ISBN!, title: self.selectedBook!.title!, author: self.selectedBook!.author!, desc: self.selectedBook!.desc)
        }
    }
    
    func transactionProcessed(success: Bool) {
        print("Transaction processed")
        if(success == true)
        {
            print("Book added successfully")
            let alert = UIAlertController(title: "Success", message: "", preferredStyle: .alert)
            //self.present(alert, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            self.present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func itemsDownloaded(items: NSArray, from: String) {
        
        var counter: Int = 0
        for x in items
        {
            print(x)
            counter = counter + 1
        }
        if(items.count > 0)
        {
            self.checkoutButton.setTitle("Hold", for: UIControlState.normal)
            
        }
        else if(checkoutButton.backgroundColor?.isEqual(UIColor.lightGray) == false)
        {
            self.checkoutButton.setTitle("Unavailable", for: UIControlState.normal)
            UIView.animate(withDuration: 1.0) {
                self.checkoutButton.alpha = 0.8
                self.checkoutButton.backgroundColor = UIColor.lightGray
            }
        }
        
        
    }
    
    @objc func load()
    {
        if(selectedBook!.title != "")
        {
            print("Book Model Loaded")
        self.descBox!.attributedText = NSAttributedString(string: selectedBook!.desc!,  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ])
            var heightConstant = CGFloat(160)
            if(self.descBox.contentSize.height<160)
            {
                
                heightConstant = self.descBox.contentSize.height
                

            }
            else
            {
                heightConstant = 160
            }
            let constraintRect = CGSize(width: self.view.frame.width - 36, height: .greatestFiniteMagnitude)
            let boundingBox = descBox.attributedText.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            heightConstant =  boundingBox.height
            print("Height2")
            print(heightConstant)
            //                let heightConstraint = NSLayoutConstraint(item: self.descBox, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 160)
            //                heightConstraint.isActive = true
            ////                self.descBox.layoutIfNeeded()
            //                heightConstraint.isActive = false
            NSLayoutConstraint(item: self.descBox, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: heightConstant + 18).isActive = true
            if(self.descBox.contentSize.height != 36)
            {
//            self.descBox.addConstraints([heightConstraint])
            }
        self.titleLabel?.text = selectedBook!.title
        self.authorLabel?.text = selectedBook!.author
            
            if(loadedRating == false)
            {
                
                var counter: Int = 0
                let x = ratingView.frame

                let ratingAsInt = Int(selectedBook!.rating) + 1
                self.ratingLabel.text = String(describing: (selectedBook?.rating)!) + " out of 5 stars"
                if((selectedBook?.rating)! < 0)
                {
                    self.ratingLabel.text = "No ratings found"

                }
                for view in self.ratingView.subviews {
                    view.removeFromSuperview()
                }
  
                while(counter<ratingAsInt)
                {
                    loadedRating = true

                    counter = counter + 1;
                    let frame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(counter), y: 0, width: x.width/2, height: x.height*1.4)
                    let animationView: LOTAnimationView = LOTAnimationView(name: "starPop");
                    animationView.contentMode = .scaleToFill
                    animationView.frame = frame
                    //animationView.backgroundColor = UIColor.white

                    ratingView.addSubview(animationView)
                    //animationView.loopAnimation = true
                    //animationView.play(fromProgress: 0, toProgress: 5.0, withCompletion: nil)
                    animationView.play()
                }
                
                counter = 0
                
                while(counter<5)
                {
                    counter = counter + 1;
                    
                    let frame = CGRect(x: x.width/4*CGFloat(counter)-x.width/5, y: x.height/2.3, width: x.width/6, height: x.height/2)
                    
                    let emptyStarView = UIImageView(image: #imageLiteral(resourceName: "emptyStar"))
                    emptyStarView.contentMode = .scaleToFill
                    emptyStarView.frame = frame
                    if(counter>ratingAsInt)
                    {
                    ratingView.addSubview(emptyStarView)
                    }
                    
                }
                
            }
        }
        if(selectedBook!.BookCoverImage != nil)
        {
            self.BookCoverImage.image = selectedBook!.BookCoverImage.image
            if self.navigationItem.titleView is UIImageView {
                (self.navigationItem.titleView as! UIImageView).image = self.BookCoverImage.image
                self.navigationItem.titleView?.alpha = 0.05
                
                if(self.titleLabel  != nil && self.titleLabel?.text != nil && self.titleLabel?.text != "Loading" && self.BookCoverImage != nil && self.BookCoverImage.image?.isEqual(#imageLiteral(resourceName: "loadingImage")) == false)
                {
                    if(selectedBook!.rating > -0.1)
                    {
                        self.loadTimer?.invalidate()
                        self.loadTimer = nil
                        self.checkAvailability()
                    }
                    else
                    {
                        self.loadTimer?.invalidate()
                        self.loadTimer = nil
                        self.checkAvailability()

                    }
                    
                }
                else
                {
                }
                
            }
        }
    }
    //Checks the availabilty of a book
    func checkAvailability()
    {
//        let myURLString = "http://google.com"
//        guard let myURL = NSURL(string: myURLString) else {
//            print("Error: \(myURLString) doesn't seem to be a valid URL")
//            return
//        }
//
//        do {
//            let myHTMLString = try String(contentsOf: myURL as URL)
//            print("HTML : \(String(describing: myHTMLString))")
//        } catch let error as NSError {
//            print("Error: \(error)")
//        }
        
//        self.myWebView.delegate = self
//
//        let urlString = "YOUR HTTPS URL"
//        self.myWebView.
//        self.myWebView.load(NSURLRequest(url: NSURL(string: urlString)! as URL) as URLRequest!)
        
//        var tempWebView = UIWebView.init()
        let words = self.selectedBook?.title?.components(separatedBy: " ")
        var argument = ""
        var wordCounter = 0
        for word in words!
        {
            wordCounter = wordCounter + 1
            if(wordCounter > 1)
            {
                argument = argument.lowercased() + "%20"
            }
            let trimmedWord = word.trimmingCharacters(in: .punctuationCharacters)
            argument = argument + trimmedWord
            
        }
        print(argument)
        if let url = URL(string: "http://search.follettsoftware.com/metasearch/ui/27952/search/all?q="+argument) {
            self.myWebView.loadRequest(URLRequest.init(url: url))
            self.myWebView.delegate = self
        }
        
//        if let url = URL(string: "http://search.follettsoftware.com/metasearch/ui/27952/search/books?q=sex%20book") {
//            do {
//                let contents = try String(contentsOf: url)
//                print(contents)
//            } catch {
//                // contents could not be loaded
//            }
//        } else {
//            // the URL was bad!
//        }
        
//        let idSearch = IdSearchBook()
//        idSearch.delegate = self
//        if(self.selectedBook?.ISBN != nil)
//        {
//        idSearch.downloadItems(inputID: (self.selectedBook?.ISBN)!)
//        }
    }
    
    var new = 0
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        new = new + 1

        if(new > 2)
        {
            print("Finished loading")
//            self.myWebView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
//                                       completionHandler: { (html: Any?, error: Error?) in
//                                        print(html)
//            })

//            self.navigationController?.present(, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                #selector(self.checkForFlag), userInfo: nil,  repeats: false)
            
        }
    }
    
    @objc func checkForFlag()
    {
        var html_to_scrape = self.myWebView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        if html_to_scrape?.range(of:"flag") != nil {
            print("Keyword \"flag\" found")
            print(html_to_scrape!)
            
            do
            {
    //            Make ISBN nicer format
                var trimmedISBN = (self.selectedBook?.ISBN!)!.replacingOccurrences(of: "-", with: "")
                let ISBNindex = trimmedISBN.index(before: trimmedISBN.endIndex)
                let tempSubString = trimmedISBN.prefix(upTo: ISBNindex)
                trimmedISBN = String(tempSubString)
                print(trimmedISBN)
            
    //            Generate 800 character chunk to analyze
                let range = html_to_scrape?.range(of: trimmedISBN)
                if let count = range?.upperBound
                {
                    let index = html_to_scrape?.index(count, offsetBy: -800)
                    let mySubstring = html_to_scrape?.suffix(from: index!)
                    html_to_scrape = String(mySubstring!)
                
                    let indexTwo = html_to_scrape?.index(html_to_scrape!.startIndex, offsetBy: 800)
                    let datSubstring = html_to_scrape?.prefix(upTo: indexTwo!)
                    html_to_scrape = String(datSubstring!)
                    print(html_to_scrape!)
                
        //            Changes label on button
                    if html_to_scrape?.range(of:"flag in") != nil
                    {
                        self.checkoutButton.setTitle("Hold", for: UIControlState.normal)
                    }
                    else if html_to_scrape?.range(of:"flag out") != nil
                    {
                        self.checkoutButton.setTitle("Checked Out", for: UIControlState.normal)
                        UIView.animate(withDuration: 1.0) {
                            self.checkoutButton.alpha = 0.8
                            self.checkoutButton.backgroundColor = UIColor.lightGray
                        }
                    }
                }
                else
                {
                    self.checkoutButton.setTitle("Unavailable", for: UIControlState.normal)
                    UIView.animate(withDuration: 1.0) {
                        self.checkoutButton.alpha = 0.8
                        self.checkoutButton.backgroundColor = UIColor.lightGray
                    }
                }
            }
            catch
            {
                print("Keyword \"flag\" not found")
                print(html_to_scrape!)
                
                self.checkoutButton.setTitle("Unavailable", for: UIControlState.normal)
                UIView.animate(withDuration: 1.0) {
                    self.checkoutButton.alpha = 0.8
                    self.checkoutButton.backgroundColor = UIColor.lightGray
                }
            }
            
            
            
            
        }
        else{
            doesNotExistCounter = doesNotExistCounter + 1
            if doesNotExistCounter < 16
            {
                print("Does not exist")
                Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                    #selector(self.checkForFlag), userInfo: nil,  repeats: false)
            }
            else
            {
                self.checkoutButton.setTitle("Not Found", for: UIControlState.normal)
                UIView.animate(withDuration: 1.0) {
                    self.checkoutButton.alpha = 0.8
                    self.checkoutButton.backgroundColor = UIColor.lightGray
                }
            }
        }
//        print(html_to_scrape!)
    }
    
    var doesNotExistCounter = 0
    
    //Passes the current BookModel to the HoldViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.loadTimer?.invalidate()
        self.loadTimer = nil
        self.timer.invalidate()
//        self.timer = nil
        if segue.destination is HoldViewController {
            (segue.destination as! HoldViewController).setBookModel(model: self.selectedBook!)
        }
    }
    
    //Checks for book information download status if the BookModel is not loaded
    @objc func action()
    {
        if(self.reviewButton.window != nil)
        {
            let screenHeight = UIScreen.main.bounds.height
            let tempY = screenHeight + scrollView.contentOffset.y - 80
            //print(tempY)
            let bottomReviewButton = self.reviewButton.frame.maxY
            //print(bottomReviewButton)
            if(tempY > bottomReviewButton && self.holdButtonHidden == false)
            {
                
                self.holdButtonHidden = true
                UIView.animate(withDuration: 0.2)
                {
                    self.checkoutButton.alpha = 0.0
                }
            }
            else if(tempY < bottomReviewButton)
            {
                self.holdButtonHidden = false
                UIView.animate(withDuration: 0.2)
                {
                    self.checkoutButton.alpha = 1.0
                }
            }
        }
        if(scrollView.contentOffset.y > 100 && (self.navigationItem.titleView?.alpha)! == CGFloat(0.0) && smallCoverImageCounter == 0)
        {
            self.smallCoverImageCounter = 10
            self.userInteractionCommitted = true
        }
        else if(scrollView.contentOffset.y < 100)
        {
            self.smallCoverImageCounter = 0
            self.navigationItem.titleView?.alpha = 0.05

        }
       
        if(self.smallCoverImageCounter>0)
        {
            smallCoverImageCounter = smallCoverImageCounter - 1
            if(self.userInteractionCommitted)
            {
            self.navigationItem.titleView?.alpha = CGFloat(1-CGFloat(smallCoverImageCounter)/20)
            }
        }
        else if(scrollView.contentOffset.y < 100)
        {
            
            var tempAlpha = (self.navigationItem.titleView?.alpha)! - 0.4
            if(tempAlpha<0)
            {
                tempAlpha = 0
            }
            self.navigationItem.titleView?.alpha = tempAlpha
            
        }
        
        if(self.userInteractionCommitted == false)
        {
            let temp = UIView.init()
            temp.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
            temp.backgroundColor = UIColor.white
            self.navigationItem.titleView?.addSubview(temp)
            
            self.smallCoverImageCounter = 0
            self.navigationItem.titleView?.alpha = 0
            
        }
        else
        {
            for subview in (self.navigationItem.titleView?.subviews)!
            {
                subview.removeFromSuperview()
            }
        }
        
        
    }
    
    
    
    @available(iOS, deprecated: 9.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkoutButton.setTitle("Checking Availability...", for: UIControlState.normal)
        self.reviewButton.layer.cornerRadius = 10
        self.reviewButton.layer.masksToBounds = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.checkoutButton.layer.cornerRadius = 10
        self.checkoutButton.titleLabel?.text = "Hold"
        self.checkoutButton.imageView?.layer.masksToBounds = true
        
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        //self.navigationController
        UIApplication.shared.statusBarStyle = .lightContent

        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = ""
        
        titleLabel?.text = "Loading..."
        BookCoverImage.image = #imageLiteral(resourceName: "loadingImage")
        checkoutButton.imageView?.image = #imageLiteral(resourceName: "reserveicon7.png")
        //genreImage.image = #imageLiteral(resourceName: "drama")
        //statusImage.image = #imageLiteral(resourceName: "greencheck.png")
        
        titleLabel?.sizeToFit()
        authorLabel?.text = "Loading..."
        descBox?.attributedText = NSAttributedString(string: "Loading from database for ISBN-13 Value: " + BookDetailViewController.ISBN + "...",  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ])
        rawDescription = (descBox?.attributedText.string)!;
        
        formatDescription()
        
        
        let x = ratingView.frame
        
        let overlay = LibraryOverlay()
        self.mapView.add(overlay)
        self.mapView.delegate = self 
        
        var counter: Int = 0
        
        while(counter<5)
        {
            counter = counter + 1;
            //let frame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(counter), y: 0, width: x.width/2, height: x.height*1.4)
            //let animationView: LOTAnimationView = LOTAnimationView(name: "starPop");
            let frame = CGRect(x: x.width/4*CGFloat(counter)-x.width/5, y: x.height/2.3, width: x.width/6, height: x.height/2)

            //animationView.contentMode = .scaleToFill
            let emptyStarView = UIImageView(image: #imageLiteral(resourceName: "emptyStar"))
            emptyStarView.contentMode = .scaleToFill
            emptyStarView.frame = frame
            //animationView.frame = frame
            
            ratingView.addSubview(emptyStarView)
            //animationView.loopAnimation = true
            //animationView.play(fromProgress: 0, toProgress: 5.0, withCompletion: nil)
            //animationView.play()
        }
        
        
        
        mapView.layer.cornerRadius = 25
        mapView.layer.masksToBounds = true
        
        BookCoverImage.layer.cornerRadius=10
        BookCoverImage.layer.masksToBounds = true
        
        //checkoutButton.layer.cornerRadius=15
        checkoutButton.layer.masksToBounds=true
        
        if self.selectedBook != nil && self.selectedBook!.fromGoogle
        {
            let alert = UIAlertController(title: "Book Not Found in Our Database", message: "Here's some information from Google Books. We'll check again and let you hold if it's available.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
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
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33712,  -122.04896), MKCoordinateSpanMake(0.0006, 0.0006)), animated: true)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector:
            #selector(SearchTableViewController.action), userInfo: nil,  repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        if(self.selectedBook != nil)
        {
            print("ISBN: " + (self.selectedBook?.ISBN)!)
            if(fromScanner == false)
            {
            self.descBox!.attributedText = NSAttributedString(string: selectedBook!.desc!,  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ])
                //self.descBox!.sizeToFit()
                var heightConstant = CGFloat(160)
                print("Height")
                print(self.descBox.contentSize.height)
                if(self.descBox.contentSize.height<160)
                {
                    heightConstant = self.descBox.contentSize.height
                    
                }
                else
                {
                    heightConstant = 160
                }
                let constraintRect = CGSize(width: self.view.frame.width - 36, height: .greatestFiniteMagnitude)
                let boundingBox = descBox.attributedText.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
                heightConstant =  boundingBox.height
                print("Height2")
                print(heightConstant)
//                let heightConstraint = NSLayoutConstraint(item: self.descBox, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 160)
//                heightConstraint.isActive = true
////                self.descBox.layoutIfNeeded()
//                heightConstraint.isActive = false
                NSLayoutConstraint(item: self.descBox, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: heightConstant + 18).isActive = true
//                UIView.animate
//                UIView.animate(withDuration: 0, delay: 0, animations:
//                    {
//                        self.descBox.layoutIfNeeded()
//                }
//                )
                
//                self.descBox.addConstraints([heightConstraint])
            
                self.checkAvailability()
                
            self.titleLabel?.text = selectedBook!.title
            self.authorLabel?.text = selectedBook!.author
                
                var counter: Int = 0
                let x = ratingView.frame
                
                let ratingAsInt = Int(selectedBook!.rating) + 1
                self.ratingLabel.text = String(describing: (selectedBook?.rating)!) + " out of 5 stars"
                if((selectedBook?.rating)! < 0)
                {
                    self.ratingLabel.text = "No ratings found"
                    
                }
                for view in self.ratingView.subviews {
                    view.removeFromSuperview()
                }
                counter = 0
                
                while(counter<5)
                {
                    counter = counter + 1;
                    //let frame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(counter), y: 0, width: x.width/2, height: x.height*1.4)
                    //let animationView: LOTAnimationView = LOTAnimationView(name: "starPop");
                    let frame = CGRect(x: x.width/4*CGFloat(counter)-x.width/5, y: x.height/2.3, width: x.width/6, height: x.height/2)
                    
                    //animationView.contentMode = .scaleToFill
                    let emptyStarView = UIImageView(image: #imageLiteral(resourceName: "emptyStar"))
                    emptyStarView.contentMode = .scaleToFill
                    emptyStarView.frame = frame
                    emptyStarView.contentMode = .scaleAspectFill

//                    emptyStarView.layer.frame = CGRect(x: emptyStarView.layer.frame.minX-20, y: emptyStarView.layer.frame.minY, width: emptyStarView.layer.frame.width/4, height: emptyStarView.layer.frame.height)
//                    emptyStarView.layer.masksToBounds = true
                    //animationView.frame = frame
                    //                    if(counter>ratingAsInt)
                    //                    {
                    emptyStarView.alpha = 0.0
                    UIView.animate(withDuration: 0.8, delay: 1.2, animations: {
                        emptyStarView.alpha = 1.0
                    }, completion: nil)
                    ratingView.addSubview(emptyStarView)
                    //                    }
                    //animationView.loopAnimation = true
                    //animationView.play(fromProgress: 0, toProgress: 5.0, withCompletion: nil)
                    //animationView.play()
                }
                counter = 0
                while(counter<ratingAsInt)
                {
                    loadedRating = true
                    
                    counter = counter + 1;
                    var frame: CGRect
                    
                    let animationView: LOTAnimationView = LOTAnimationView(name: "starPop");
                    if counter == ratingAsInt
                    {
                        frame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(counter), y: 0, width: x.width/2, height: x.height*1.4)
                        animationView.contentMode = .scaleToFill
                        animationView.bounds = CGRect(x: 0, y: 0, width: frame.width/2, height: x.height*1.4)
//                        animationView.backgroundColor = .red
//                        animationView.clipsToBounds = true
                        
                        animationView.layer.bounds = CGRect(x: 0, y: 0, width: frame.width/2, height: x.height*1.4)
                        animationView.layer.masksToBounds = true
//                        animationView.mask

                    }
                    else
                    {
                        frame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(counter), y: 0, width: x.width/2, height: x.height*1.4)
                        animationView.contentMode = .scaleToFill

                    }
                    animationView.frame = frame
                    //animationView.backgroundColor = UIColor.white
                    
                    if CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt)+CGFloat(1) > 0.3 || counter != ratingAsInt
                    {
                        ratingView.addSubview(animationView)
                    }
                    
//                    let coverFrame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(ratingAsInt) + (CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt)+CGFloat(1))*(x.width/2), y: 0, width: x.width, height: x.height*1.4)
                    let coverFrame = CGRect(x: -x.width/2.7+(x.width/4)*CGFloat(self.selectedBook!.rating)+(x.width*3/8), y: 0, width: (x.width/4)*(CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt))*CGFloat(-1), height: x.height*1.4)
//                    let coverFrame = CGRect(x: frame.minX+frame.width/2, y: frame.minY+frame.height/4, width: frame.width/2, height: frame.height)
//                    let coverFrame = animationView.frame
//                    let coverFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
                    let coverUpView = UIView.init(frame: coverFrame)
                    coverUpView.backgroundColor = .white
                    print("Big")
                    print(frame.minX)
                    
                    print(CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt)+CGFloat(1))
                    if counter == ratingAsInt
                    {
                        let mutablePath = CGMutablePath()
                        mutablePath.addRect(CGRect(x: frame.minX+frame.width/2, y: frame.minY+frame.height/4, width: frame.width/4, height: frame.height/2))
                        mutablePath.addRect(animationView.frame)
                        
                        // Create a shape layer and cut out the intersection
                        let mask = CAShapeLayer()
                        mask.path = mutablePath
                        mask.fillRule = kCAFillRuleEvenOdd
//                        animationView.addSubview(coverUpView)
                        // Add the mask to the view
//                        animationView.layer.mask = mask
                        if CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt)+CGFloat(1) > 0.3 || CGFloat(self.selectedBook!.rating)-CGFloat(ratingAsInt)+CGFloat(1) < 0.75
                        {
                            ratingView.addSubview(coverUpView)
                        }
//                        animationView.alpha = 0.9
                        
                        let frame = CGRect(x: x.width/4*CGFloat(counter)-x.width/5+5, y: x.height/2.3+5, width: x.width/6-10, height: x.height/2-10)
                        
                        //animationView.contentMode = .scaleToFill
                        let emptyStarView = UIImageView(image: #imageLiteral(resourceName: "emptyStar"))
                        emptyStarView.contentMode = .scaleToFill
                        emptyStarView.frame = frame
//                        emptyStarView.contentMode = .scaleAspectFill
                        
                        //                    emptyStarView.layer.frame = CGRect(x: emptyStarView.layer.frame.minX-20, y: emptyStarView.layer.frame.minY, width: emptyStarView.layer.frame.width/4, height: emptyStarView.layer.frame.height)
                        //                    emptyStarView.layer.masksToBounds = true
                        //animationView.frame = frame
                        //                    if(counter>ratingAsInt)
                        //                    {
                        emptyStarView.alpha = 0.0
                        UIView.animate(withDuration: 0.8, delay: 1.2, animations: {
                            emptyStarView.alpha = 1.0
                        }, completion: nil)
//                        ratingView.addSubview(emptyStarView)
//                        animationView.mask = coverUpView
//                        emptyStarView.mask = coverUpView
//                        ratingView.addSubview(emptyStarView)

                        
                        
                    coverUpView.alpha = 0.0
                    }
                    
                    //animationView.loopAnimation = true
                    //animationView.play(fromProgress: 0, toProgress: 5.0, withCompletion: nil)
                    
                    UIView.animate(withDuration: 0.8, delay: 5, animations: {
                        animationView.play()
                    }, completion: nil)
                }
                
                
            }
            else
            {
                self.descBox!.attributedText = NSAttributedString(string: "Loading",  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ])
                self.titleLabel?.text = "Loading"
                self.authorLabel?.text = "Loading"
            }


            if(selectedBook?.BookCoverImage != nil)
            {
            self.BookCoverImage.image = selectedBook!.BookCoverImage.image
                let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 38))
                tempImageView.image = selectedBook!.BookCoverImage.image
                self.navigationItem.titleView = tempImageView
                self.navigationItem.titleView?.frame = CGRect(x: 0, y: 0, width: 10, height: 38)
                self.navigationItem.titleView?.alpha = 0.0

                //self.navigationItem.titleView.image
                //let tempFrame = self.navigationItem.titleView?.frame
                //    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))

                //self.navigationItem.titleView?.frame = CGRect(x: (tempFrame?.minX)!, y: (tempFrame?.minY)!, width: 10, height: (tempFrame?.height)!)
                self.navigationItem.titleView?.contentMode = .scaleToFill
                let widthConstraint = NSLayoutConstraint(item: self.navigationItem.titleView as Any, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 25)
                let heightConstraint = NSLayoutConstraint(item: self.navigationItem.titleView as Any, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35)

                self.navigationItem.titleView?.addConstraints([widthConstraint, heightConstraint])
                self.navigationItem.titleView?.layer.cornerRadius = 2
                self.navigationItem.titleView?.layer.masksToBounds = true

                
                
            }
            else
            {
                self.BookCoverImage.image = #imageLiteral(resourceName: "loadingImage")
                let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 38))
                tempImageView.image = self.BookCoverImage.image
                self.navigationItem.titleView = tempImageView
                self.navigationItem.titleView?.frame = CGRect(x: 0, y: 0, width: 10, height: 38)
                self.navigationItem.titleView?.alpha = 0.0
                
                //self.navigationItem.titleView.image
                //let tempFrame = self.navigationItem.titleView?.frame
                //    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
                
                //self.navigationItem.titleView?.frame = CGRect(x: (tempFrame?.minX)!, y: (tempFrame?.minY)!, width: 10, height: (tempFrame?.height)!)
                self.navigationItem.titleView?.contentMode = .scaleToFill
                let widthConstraint = NSLayoutConstraint(item: self.navigationItem.titleView as Any, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 25)
                let heightConstraint = NSLayoutConstraint(item: self.navigationItem.titleView as Any, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35)
                
                self.navigationItem.titleView?.addConstraints([widthConstraint, heightConstraint])
                self.navigationItem.titleView?.layer.cornerRadius = 2
                self.navigationItem.titleView?.layer.masksToBounds = true
                if(fromScanner)
                {
//                loadTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector:
//                    #selector(SearchTableViewController.load), userInfo: nil,  repeats: true)
//                    RunLoop.main.add(loadTimer!, forMode: RunLoopMode.commonModes)
                
                }
                
                
            }
            
            
        }
        
    }

    var navBarBackgroundColor: UIColor = UIColor.white
    var navBarTintColor: UIColor = UIColor.white

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.myWebView.stopLoading()
        if self.timer != nil
        {
            self.timer.invalidate()
        }
        if self.loadTimer != nil
        {
            self.loadTimer?.invalidate()
        }
        UIView.animate(withDuration: 0.8, animations: {self.navigationController?.navigationBar.backgroundColor = self.navBarBackgroundColor
            self.navigationController?.navigationBar.barTintColor = self.navBarTintColor

            //self.navigationController?.navigationBar.tintColor = self.navBarTintColor})
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector:
            #selector(SearchTableViewController.action), userInfo: nil,  repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        navBarBackgroundColor = (self.navigationController?.navigationBar.backgroundColor)!
        navBarTintColor = (self.navigationController?.navigationBar.barTintColor)!
        UIView.animate(withDuration: 0.8, animations: {self.navigationController?.navigationBar.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            //self.navigationController?.navigationBar.tintColor = UIColor.white})
        })

        
        if(self.fromScanner == true)
        {
            loadTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:
                #selector(SearchTableViewController.load), userInfo: nil,  repeats: true)
//            loadTimer.
            RunLoop.main.add(loadTimer!, forMode: RunLoopMode.commonModes)
        }
        print("---")
        print("---")
        print("---")
        print(self.selectedBook?.ISBN!)
        print("---")
        print("---")
        print("---")
    }
    
    @IBAction func leaveReviewPressed(_ sender: Any)
    {
        let tempReview = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "reviewController") as! ReviewViewController
        tempReview.setBookModel(model: self.selectedBook!)
        self.present(tempReview, animated: true, completion: nil)
    }
    

    
    @available(iOS, deprecated: 9.0)
    func formatDescription()
    {
        var addDots:Bool = false;

        while/* (descBox?.contentSize.height)!>CGFloat(180)*/ descBox!.attributedText.length>356 {
            addDots = true;
            
            let subRange = NSMakeRange(0,(descBox?.attributedText.length)!-5)
            descBox?.attributedText = descBox?.attributedText.attributedSubstring(from: subRange)
        }
        if(addDots)
        {
            let stringVersion = descBox?.attributedText.string
            let stringIndex = descBox?.attributedText.string.range(of: " ", options: .backwards)?.lowerBound
            
            let finalString = stringVersion?.substring(to: stringIndex!);
            descBox?.attributedText=NSAttributedString(string: finalString!+"... (more)",attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ]);
        }
        descBox.sizeToFit();
    }
    
    @available(iOS, deprecated: 9.0)
    func formatJSONDescription()
    {
        
            DispatchQueue.main.async(execute: {() -> Void in

                let stringVersion = self.descBox?.attributedText.string
                //let stringIndex = self.descBox?.attributedText.string.range(of: " ", options: .backwards)?.lowerBound
            //let finalString = stringVersion?.substring(to: stringIndex!); <- readd if removing scrolling description
                let finalString = stringVersion; self.descBox?.attributedText=NSAttributedString(string: finalString!+"\n(tap for more details)",attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16) ]);
            })
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadCoverImage(url: URL) {
        
        var found: Bool = false;
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                let temp: UIImage? = UIImage(data: data)
                if(temp != nil && Double((temp?.size.height)!)>20.0)
                {
                    
                self.BookCoverImage.image = temp
                    found = true;
                }
                else
                {
                    if(self.foundGoogleImage == false)
                    {
                    print("Image not found")
                    self.BookCoverImage.image = #imageLiteral(resourceName: "loadingImage")
                    }
                }
                print(String(describing: temp?.size.height))
                
            }
        }
        if(found == false)
        {
        if let googleURL = URL(string: self.imageURL) {
            print("Using GBooks Image")
            self.getDataFromUrl(url: googleURL) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                DispatchQueue.main.async() {
                    let temp: UIImage? = UIImage(data: data)
                    if(temp != nil && Double((temp?.size.height)!)>20.0)
                    {
                        self.BookCoverImage.image = temp
                        self.foundGoogleImage = true
                    }
                    else
                    {
                        //self.BookCoverImage.image = #imageLiteral(resourceName: "loadingImage")
                    }
                    print(String(describing: temp?.size.height))
                    
                }
            }
        }
    }
    }
    
    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        
    }

    
    func googleBooksImageURL(newURL: String)
    {
        self.imageURL = newURL
    }
    
    static func updateISBN(newISBN: String)
    {
        BookDetailViewController.ISBN = newISBN;
    }
    
    
}

extension BookDetailViewController: MKMapViewDelegate
{
    
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
            //print("hellos")
            if overlay is LibraryOverlay {
                //print("bigs")
                return LibraryOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "mapOverlay"))
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
    
    
    
    
    
}

