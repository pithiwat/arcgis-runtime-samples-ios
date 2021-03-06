//
// Copyright 2016 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

protocol DirectionsListVCDelegate:class {
    func directionsListViewController(directionsListViewController:DirectionsListViewController, didSelectDirectionManuever directionManeuver:AGSDirectionManeuver)
    func directionsListViewControllerDidDeleteRoute(directionsListViewController:DirectionsListViewController)
}

class DirectionsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView:UITableView!
    @IBOutlet var milesLabel:UILabel!
    @IBOutlet var minutesLabel:UILabel!
    
    weak var delegate:DirectionsListVCDelegate?
    
    var route:AGSRoute! {
        didSet {
            self.tableView?.reloadData()
            self.updateLabels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels() {
        if self.route != nil {
            let miles = String(format: "%.2f", self.route.totalLength*0.000621371)
            self.milesLabel.text = "(\(miles) mi)"
            
            var minutes = Int(self.route.totalTime)
            let hours = minutes/60
            minutes = minutes%60
            let hoursString = hours == 0 ? "" : "\(hours) hr "
            let minutesString = minutes == 0 ? "" : "\(minutes) min"
            self.minutesLabel.text = "\(hoursString)\(minutesString)"
        }
    }

    //MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.route?.directionManeuvers.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell")!
        
        cell.textLabel?.text = self.route.directionManeuvers[indexPath.row].directionText
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let directionManeuver = self.route.directionManeuvers[indexPath.row]
        self.delegate?.directionsListViewController(self, didSelectDirectionManuever: directionManeuver)
    }
    
    //MARK: - Actions
    
    @IBAction func deleteRouteAction() {
        self.delegate?.directionsListViewControllerDidDeleteRoute(self)
    }
}
