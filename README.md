# LocationFetchingReactive
Use to fetch location as a singleton service when the app is in foreground

# App delegate
```
func applicationDidBecomeActive(_ application: UIApplication) {
    LocationService.shared.startUpdating()
}

func applicationWillResignActive(_ application: UIApplication) {
    LocationService.shared.endUpdating()
}
```

# View Controller
```
class ViewController: UIViewController {
      override func viewDidAppear(_ animated: Bool) {
        ....
        LocationService.shared.add(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        .....
        LocationService.shared.remove(self)
    }
}

extension ViewController: LocationDelegate {
    func locationUpdated(coordinate: CLLocationCoordinate2D) {
        ...
        // get location updates
    }
}
```
