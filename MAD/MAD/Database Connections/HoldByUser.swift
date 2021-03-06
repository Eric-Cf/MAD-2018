import Foundation
import UIKit



class HoldbyUser: NSObject {
    
    
    
    weak var delegate: DownloadProtocol!
    
    let urlPath = "http://www.the-library-database.com/hhs_php/hold_userid.php"
    
    //Gets all holds owned by a user
    func downloadItems(inputID: CLong) {
        
        
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "password=secureAf&id=\(inputID)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            _ = String(data: data, encoding: .utf8)
            self.parseJSON(data)
        }
        task.resume()
        
    }
    
    //Parses retrieved JSON
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        //NSArrays initialized
        var jsonElement: NSDictionary = NSDictionary()
        let holds = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let hold = HoldModel()
            
            
            //JsonElement values are guaranteed to not be null through optional binding
            if let id = jsonElement["hold_id"] as! String?,
                let isbn = jsonElement["isbn"] as! String?,
                let userid = jsonElement["user_id"] as! String?,
                let start = jsonElement["timestart"] as! String?,
                let ready = jsonElement["ready"] as! String?
            {
                hold.ID = id
                hold.ISBN = isbn
                hold.userID = userid
                hold.startTimestamp = start
                hold.ready = Int(ready)
            }
            
            holds.add(hold)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            if self.delegate != nil
            {
                self.delegate.itemsDownloaded(items: holds, from: "HoldByUser")
            }
        })
    }
    
}




