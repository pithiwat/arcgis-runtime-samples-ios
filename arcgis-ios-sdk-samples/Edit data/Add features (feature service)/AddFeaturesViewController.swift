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

class AddFeaturesViewController: UIViewController, AGSGeoViewTouchDelegate {
    
    @IBOutlet private var mapView:AGSMapView!
    
    private var featureTable:AGSServiceFeatureTable!
    private var featureLayer:AGSFeatureLayer!
    private var lastQuery:AGSCancelable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the source code button item to the right of navigation bar
        (self.navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["AddFeaturesViewController"]
        
        //instantiate map with a basemap
        let map = AGSMap(basemap: AGSBasemap.streetsBasemap())
        //set initial viewpoint
        map.initialViewpoint = AGSViewpoint(center: AGSPoint(x: 544871.19, y: 6806138.66, spatialReference: AGSSpatialReference.webMercator()), scale: 2e6)
        
        //assign the map to the map view
        self.mapView.map = map
        //set touch delegate on map view as self
        self.mapView.touchDelegate = self
        
        //instantiate service feature table using the url to the service
        self.featureTable = AGSServiceFeatureTable(URL: NSURL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
        //create a feature layer using the service feature table
        self.featureLayer = AGSFeatureLayer(featureTable: self.featureTable)
        
        //add the feature layer to the operational layers on map
        map.operationalLayers.addObject(featureLayer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addFeature(mappoint:AGSPoint) {
        //show the progress hud
        SVProgressHUD.showWithStatus("Adding..", maskType: SVProgressHUDMaskType.Gradient)
        //disable interaction with map view
        self.mapView.userInteractionEnabled = false
        
        //normalize geometry
        let normalizedGeometry = AGSGeometryEngine.normalizeCentralMeridianOfGeometry(mappoint)!
        
        //attributes for the new feature
        let featureAttributes = ["typdamage" : "Minor", "primcause" : "Earthquake"]
        //create a new feature
        let feature = self.featureTable.createFeatureWithAttributes(featureAttributes, geometry: normalizedGeometry)
        
        //add the feature to the feature table
        self.featureTable.addFeature(feature) { [weak self] (error: NSError?) -> Void in
            if let error = error {
                SVProgressHUD.showErrorWithStatus("Error while adding feature :: \(error.localizedDescription)")
                print("Error while adding feature :: \(error)")
            }
            else {
                //applied edits on success
                self?.applyEdits()
            }
            //enable interaction with map view
            self?.mapView.userInteractionEnabled = true
        }
    }
    
    func applyEdits() {
        self.featureTable.applyEditsWithCompletion { (featureEditResults: [AGSFeatureEditResult]?, error: NSError?) -> Void in
            if let error = error {
                SVProgressHUD.showErrorWithStatus("Error while applying edits :: \(error.localizedDescription)")
            }
            else {
                if let featureEditResults = featureEditResults where featureEditResults.count > 0 && featureEditResults[0].completedWithErrors == false {
                    SVProgressHUD.showSuccessWithStatus("Edits applied successfully")
                }
                SVProgressHUD.dismiss()
            }
        }
    }
  
    //MARK: - AGSGeoViewTouchDelegate
    
    func geoView(geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //add a feature at the tapped location
        self.addFeature(mapPoint)
    }
}
