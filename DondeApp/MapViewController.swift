import UIKit
import MapKit

enum PointMapType {
  case location
  case visit
}

class LocationAnnotation: MKPointAnnotation {

}

class VisitAnnotation: MKPointAnnotation {
  var tag: Int?
  let visit: RlmVisit
  init(visit: RlmVisit) {
    self.visit = visit
  }
}

class MapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  var routeLineView: MKPolylineView?
  let tracks: [RlmTrack]
  let centerCoordinate: CLLocationCoordinate2D

  init (centerCoordinate: CLLocationCoordinate2D, tracks: [RlmTrack]) {
    self.tracks = tracks
    self.centerCoordinate = centerCoordinate
    super.init(nibName: "MapViewController", bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
    printTracksLocations(tracks)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func setupMap() {
    mapView.delegate = self

    // optionally you can set your own boundaries of the zoom
    let span = MKCoordinateSpanMake(0.0040526179677158325, 0.0040526179677158325)

    // now move the map
    let region = MKCoordinateRegion(center: self.centerCoordinate, span: span)
    mapView.setRegion(region, animated: true)
  }

  private func printTracksLocations(_ trakcs: [RlmTrack]) {
    for track in tracks {
      printTrackLine(track)
    }
  }

  private func printTrackLine(_ track: RlmTrack) {
    var coordinateArray: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

    for location in track.locations {
      let locationCoordinate2D = CLLocationCoordinate2D(
        latitude: location.latitud,
        longitude: location.longitud
      )
      coordinateArray.append(locationCoordinate2D)
    }

    // add lines
    let routeline = MKPolyline.init(coordinates: coordinateArray, count: coordinateArray.count)
    mapView.add(routeline)
  }

  private func printPointFrom(locationCoordinate2D: CLLocationCoordinate2D) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = locationCoordinate2D
    mapView.addAnnotation(annotation)
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blue
      polylineRenderer.lineWidth = 5
      polylineRenderer.alpha = 0.5
      return polylineRenderer
    }

    return MKPolylineRenderer(overlay: overlay)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is LocationAnnotation {
      let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")

      //pinAnnotationView.pinColor = .purple
      pinAnnotationView.isDraggable = true
      pinAnnotationView.canShowCallout = true
      pinAnnotationView.animatesDrop = true

      return pinAnnotationView
    } else if annotation is VisitAnnotation {
      let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPinVisit")

      pinAnnotationView.pinTintColor = .purple
      pinAnnotationView.isDraggable = true
      pinAnnotationView.canShowCallout = true
      pinAnnotationView.animatesDrop = true

      return pinAnnotationView
    }

    return nil
  }
}
