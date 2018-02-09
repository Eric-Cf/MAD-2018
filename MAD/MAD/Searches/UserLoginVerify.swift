import Foundation
import UIKit



class UserLoginVerify: NSObject {
    
    
    
    weak var delegate: DownloadProtocol!
    
    let urlPath = "http://www.the-library-database.com/php_scripts/user_loginverify.php"
    
    func verifyLogin(schoolID: String, password:String) {
        
        
        //print ("Book ID search started with \(inputID)")
        
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "password=secureAf&schoolid=\(schoolID)&userpassword=\(password)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(responseString)")
            if (responseString == "script failed") {
                DispatchQueue.main.async(execute: { () -> Void in
                    let users = NSMutableArray()
                    users.add("failed")
                    self.delegate.itemsDownloaded(items: users)
                    
                })
            }else {
                self.parseJSON(data)
            }
        }
        task.resume()
        
    }
    
    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        //NSArrays initialized
        var jsonElement = NSDictionary()
        let users = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let user = UserModel()
            
            
            //JsonElement values are guaranteed to not be null through optional binding
            if let id = jsonElement["user_id"] as! String?,
                let password = jsonElement["password"] as! String?,
                let name = jsonElement["name"] as! String?,
                let email = jsonElement["email"] as! String?,
                let schoolid = jsonElement["schoolid"] as! String?
            {
                user.ID = id
                user.password = password
                user.name = name
                user.email = email
                user.schoolid = schoolid
                if let facebookid = jsonElement["facebookid"] as! String?
                {
                    user.facebookid=facebookid
                }else {
                    user.facebookid="0"
                }
            }
            
            users.add(user)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: users)
            
        })
    }
    
}




