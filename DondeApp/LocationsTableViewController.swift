//
//  LocationsTableViewController.swift
//  clientApp
//
//  Created by Adrian on 2/27/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import CoreLocation

class LocationsTableViewController: UITableViewController {

    let data: [[AnyObject]]

    init(data: [[AnyObject]]) {

        self.data = data

        super.init(nibName: "LocationsTableViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let location = self.data[indexPath.section][indexPath.row]
        if location is RlmLocation {
            cell.textLabel?.text = "location"
        } else {
            cell.textLabel?.text = "visit"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if data[section].count > 0 {
            let location: AnyObject? = data[section][0]
            if location is RlmLocation {
                return "Visit"
            } else {
                return "Travel"
            }
        } else {
            return "No locations"
        }
    }

    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let location = self.viewModel.visits[indexPath.section][indexPath.row]
        let centerCoordinate: CLLocationCoordinate2D = {
            if let location: RlmLocation = self.data[indexPath.section][indexPath.row] as? RlmLocation {
                return CLLocationCoordinate2D.init(latitude: location.latitud, longitude: location.longitud)
            } else {
                guard let visit = self.data[indexPath.section][indexPath.row] as? RlmVisit else {
                    return CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
                }
                return CLLocationCoordinate2D.init(latitude: visit.latitudPrivate, longitude: visit.longitudPrivate)
            }
        }()

        guard let tracks = data[indexPath.section] as? [RlmTrack] else {
            return
        }

        self.navigationController?.pushViewController(MapViewController.init(centerCoordinate:centerCoordinate ,
                                                                             tracks: tracks), animated: true)
    }
    /*x
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
