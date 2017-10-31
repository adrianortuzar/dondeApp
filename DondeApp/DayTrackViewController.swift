import UIKit
import MapKit
import DatePickerDialog

class DayTrackViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  let viewModel = DayTrackViewModel()

  lazy var dateButton: UIButton = {
    var button = UIButton.init(type: .custom)
    button.frame = CGRect.init(x: 0, y: 0, width: 100, height: 40)
    button.setTitleColor(UIColor.black, for: .normal)
    button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    return button
  }()

  init() {
    super.init(nibName: "DayTrackViewController", bundle: nil)

    self.title = "Tracks"

    viewModel.tracksDidChange = { [unowned self] dayTrackViewModel in
      self.tableView.reloadData()
    }

    addButtonToNavigationTitle()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(mapButtonPressed))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func addButtonToNavigationTitle() {
    setDateButtonTitle()
    self.navigationItem.titleView = dateButton
  }

  private func setDateButtonTitle() {
    let buttonTitle = DateFormatter().stringDayMonth(from: viewModel.day)
    dateButton.setTitle(buttonTitle, for: .normal)
  }

  func pressed(sender: UIButton!) {
    DatePickerDialog().show("", defaultDate: viewModel.day, datePickerMode: .date) { date in
      guard let date = date else {
        return
      }
      self.viewModel.day = date
      self.setDateButtonTitle()
    }
  }

  func mapButtonPressed(sender: UIButton!) {
    guard let tracks = self.viewModel.tracks, let track = tracks.first else {
      return
    }

    presentMapView(trackCenter: track, tracks: tracks)
  }

  func presentMapView(trackCenter: RlmTrack, tracks: [RlmTrack]) {
    let cordinate = CLLocationCoordinate2D.init(latitude: trackCenter.averageLatitud, longitude: trackCenter.averageLongitud)
    let mapViewController = MapViewController(centerCoordinate: cordinate, tracks: tracks)
    guard let navigationController = navigationController else {
      return
    }
    navigationController.pushViewController(mapViewController, animated: true)
  }
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
    let dateFormatter = DateFormatter()
    let trackFirstTime = dateFormatter.stringHourMinutes(from: track.firstTime)
    let trackLastTime = dateFormatter.stringHourMinutes(from: track.lastTime)

    if track.locations.count > 1 {
      return track.speedType  + " " +  trackFirstTime + " - " + trackLastTime
    } else {
      return track.speedType  + " " + trackFirstTime + " --:--"
    }
  }
}

extension DayTrackViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let tracks = viewModel.tracks else {
      return
    }
    presentMapView(trackCenter: tracks[indexPath.row], tracks: [tracks[indexPath.row]])
  }
}
