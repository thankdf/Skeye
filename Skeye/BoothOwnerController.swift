//
//  BoothOwnerController.swift
//  Skeye
//
//  Created by Sandeep Kaur on 5/8/17.
//  Copyright © 2017 Team_Parking. All rights reserved.
//

import MapKit
import UIKit

class BoothOwnerController : UIViewController, UITableViewDataSource, UITableViewDelegate, HomeModelProtocal{
    
    //Properties
    
    weak var delegate: HomeModelProtocal!
    var boothList: NSArray = NSArray()
    var selectedLocation : LocationModel = LocationModel()
    
    
    @IBOutlet weak var boothListTable: UITableView!
    var data : NSMutableData = NSMutableData()
    
    let urlPath: String = "http://130.65.159.80/BoothList_new.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates and initialize homeModel
        
        self.boothListTable.delegate = self
        self.boothListTable.dataSource = self
        
        retrieveBoothList()
        
    }
    
    func itemsDownloaded(items: NSArray) {
        print("tableView is working")
        boothList = items
        self.boothListTable.reloadData()
        print(boothList)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        return boothList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve cell
        let cellIdentifier: String = "boothCell"
        let myCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        // Get the location to be shown
        let item: LocationModel = boothList[indexPath.row] as! LocationModel
        // Get references to labels of cell
        myCell.textLabel!.text = item.event_name
        myCell.detailTextLabel?.text = item.username
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set selected location to var
        selectedLocation = boothList[indexPath.row] as! LocationModel
        // Manually call segue to detail view controller
        // self.performSegue(withIdentifier: "eventPinSegue", sender: self)
        
        self.performSegue(withIdentifier: "BoothListToEditBooth", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if segue.identifier == "eventPinSegue"
        if segue.identifier == "BoothListToEditBooth"
            
        {
            // Get reference to the destination view controller
            let detailVC  = segue.destination as! EditBoothViewController
            // Set the property to the selected location so when the view for
            // detail view controller loads, it can access that property to get the feeditem obj
            detailVC.selectedLocation = selectedLocation
        }
    }
    
    
    func retrieveBoothList()
    {
        
        let username = UserDefaults.standard.string(forKey: "username")
        
        let url = URL(string: urlPath)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST";
        
        let postString = "searchWord=\(username!)"
        
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) {
            
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            self.data.append(data! as Data);
            
            print("Data downloaded")
            
            self.parseJSON()
            
        }
        task.resume()
        
        
        
    }
    
    
    
    func parseJSON() {
        
        var jsonResult = [[String:Any]]()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
            
        } catch let error as NSError {
            print(error)
            
        }
        
        let locations: NSMutableArray = NSMutableArray()
        for json in jsonResult
        {
            //the following insures none of the JsonElement values are nil through optional binding
            if let event_name = json["event_name"] as? String,
                let username = json["username"] as? String,
                let booth_id = json["booth_id"] as? String
                
                
                /*             let address = jsonElement["Address"] as? String,
                 let latitude = jsonElement["Latitude"] as? String,
                 let longitude = jsonElement["Longitude"] as? String
                 */
            {
                
                let location = LocationModel()
                location.event_name = event_name
                location.username = username
                location.booth_id = Int(booth_id)
                
                /*             location.address = address
                 location.latitude = latitude
                 location.longitude = longitude
                 
                 */
                locations.add(location)
            }
            
            
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.itemsDownloaded(items: locations)
            
        })
    }
}
