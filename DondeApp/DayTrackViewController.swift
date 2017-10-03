import UIKit
import MapKit

class DayTrackViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  let viewModel = DayTrackViewModel()

  init() {
    super.init(nibName: "DayTrackViewController", bundle: nil)

    self.title = "Tracks"

    viewModel.tracksDidChange = { [unowned self] dayTrackViewModel in
      self.tableView.reloadData()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate let timeDateFormat: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
}

extension DayTrackViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let tracks = viewModel.tracks else {
      return 0
    }
    return tracks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")

    guard let tracks = viewModel.tracks else {
      return cell
    }

    let track = tracks[indexPath.row]

    guard let textlabel = cell.textLabel else {
      return cell
    }
    textlabel.text = getCellTextLabel(withTrack: track)

    return cell
  }

  private func getCellTextLabel(withTrack track: RlmTrack) -> String {
    if track.locations.count > 1 {
      return track.speedType  + " " +  timeDateFormat.string(
        from: track.firstTime) + " - " + timeDateFormat.string(from: track.lastTime
      )
    } else {
      return track.speedType  + " " +  timeDateFormat.string(from: track.firstTime)  + " --:--"
    }
  }
}

extension DayTrackViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let tracks = self.viewModel.tracks else {
      return
    }

    let track = tracks[indexPath.row]
    let cordinate = CLLocationCoordinate2D.init(latitude: track.averageLatitud, longitude: track.averageLongitud)
    let mapViewController = MapViewController(centerCoordinate: cordinate, tracks: tracks)
    guard let navigationController = navigationController else {
      return
    }
    navigationController.pushViewController(mapViewController, animated: true)
  }
}
