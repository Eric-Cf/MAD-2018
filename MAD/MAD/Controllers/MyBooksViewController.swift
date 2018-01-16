//
//  MyBooksViewController.swift
//  MAD
//
//  Created by NonAdmin Eric on 10/29/17.
//  Copyright © 2017 Eric C. All rights reserved.
//

import Foundation
import UIKit

class MyBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BookIdProtocol{
    var feedItems: NSArray = NSArray()
    @IBOutlet weak var listTableView: UITableView!
    var temp:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let m = BookModel.init(ISBN: "9781921019630")

        //set delegates
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let Idsearch = IdSearchBook()
            Idsearch.delegate = self
        Idsearch.downloadItems(inputID:9780375831003000)
        
    }
    
    func itemsDownloaded(items: NSArray) {
        
        feedItems = items
        self.listTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Retrieve cell
        let cellIdentifier: String = "BasicCell"
        let myCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        // Get references to labels of cell
        
        myCell.textLabel!.text = "The Theory of Nothing"
        //self.listTableView.reloadData()

        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Set selected location to var
        //selectedLocation = feedItems[indexPath.row] as! LocationModel
        // Manually call segue to detail view controller
        BookDetailViewController.updateISBN(newISBN: "9781921019630");
        
        //let scanners = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController
        
        
        //self.navigationController?.push
        //self.navigationController?.pushViewController(scanners, animated: true)
        self.performSegue(withIdentifier: "bookInfoSegue", sender: self)
        //let scanners = self.storyboard?.instantiateViewController(withIdentifier: "bookInfoSegue") as! BookDetailViewController
        
        //scanners.delegate = self
        
        //self.navigationController?.push
        //self.navigationController?.pushViewController(scanners, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "scannerDetailViewSegue"
        {
            let destinationVC = segue.destination as! BookDetailViewController
            destinationVC.fromSB = .fromMyBooksViewController
                //ISBN13 Value (string) ||
                //                      \/
                //destinationVC.updateISBN(newISBN: "9780545010221");
        }
        else if segue.identifier == "bookInfoSegue"{
            let bookViewController = segue.destination as! BookDetailViewController
            bookViewController.fromSB = .fromMyBooksViewController
        }
        
        // Get reference to the destination view controller
        //let detailVC  = segue.destination as! DetailViewController
        // Set the property to the selected location so when the view for
        // detail view controller loads, it can access that property to get the feeditem obj
        //detailVC.selectedLocation = selectedLocation
    }
}
