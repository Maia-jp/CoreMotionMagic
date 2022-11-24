
# CoreMotionMagic
CoreMotionMagic is a CoreMotion wrapper, the aim's to facilitate the use of Core Motion in amateur projects.

## Installation

To use this project, simply paste this GitHub URL in your dependency manager. 
    
## Usage/Examples

In order to instantiate it, just use:

```swift
  @StateObject var sharedCMM = CoreMotionMagic.shared
```

Now, it is a good time to set the default update interval for all sensors (the default value is `5`).

```swift
  CoreMotionMagic.shared.updateTime = 1 //in seconds
```

After that, it is time to initialize one of the sensors (all of them are described in the following enum:
```swift
  enum CMMSensors:CaseIterable{
    case Accelerometer
    case Gyroscope
    case Magnetometer
    case Altimeter
    case Barometer
}
```

Initializing the altitude Sensor
```swift
sharedCMM.startSensor(.Accelerometer)
//You can also start it passing the update time
sharedCMM.startSensor(.Accelerometer, withUpdateTimeOf: 1)
```

Finally, you can access the CMAccelerometerData easily using: 
```swift
if let accData = sharedCMM.acceleration {
    print(accData)
}
```

To stop this sensor, just use:
```swift
sharedCMM.stopSensor(.Accelerometer)
```
Here are some other useful methods:
```swift
/// Returns all available sensors in this device (CoreMotion Only)
/// - Returns: a list of CMMSensors containing all available sensors in this device
func checkAllAvailableSensors()->[CMMSensors]

/// Start all sensors avaliable in this device
func startAllSensors()

/// Start all sensors except the one desired
/// - Parameter desiredSensor: sensor that will NOT be started
func startAllExcept(_ desiredSensor:CMMSensors)



/// Stop the given sensor
/// - Parameter sensor: sensor to be stoped
func stopSensor(_ sensor:CMMSensors)

/// Stops all sensors
func stopAllSensors()

/// Stop all sensors except the one given
/// - Parameter desiredSensor: Sensor that will NOT BE STOPED
func stopAllExcept(_ desiredSensor:CMMSensors)

```
## FAQ

#### Which data can I access ? 

```swift
    @Published var acceleration:CMAccelerometerData
    @Published var gyro:CMGyroData
    @Published var magnetometer:CMMagnetometerData
    @Published var altimeter:CMAltitudeData
```

#### How can I get past data ? 

All data are also available in a buffer that holds 624 entries by default.
```swift
    @Published var accelerationBuffer:[CMAccelerometerData]
    @Published var gyroBuffer:[CMGyroData] = []
    @Published var magnetometerBuffer:[CMMagnetometerData]
    @Published var altimeterBuffer:[CMAltitudeData]
```

To change the buffer size: 

```swift
    CoreMotionMagic.shared.bufferSensorSize = 10 //desired value
```


#### Can you give an example in SwiftUI ? 
Sure:
```swift
struct ContentView: View {
    @StateObject var sharedCMM = CoreMotionMagic.shared

    
    @State var shownText1 = "_"
    
    
    var body: some View {
        VStack {
            Text(sharedCMM.acceleration?.description ?? "_")
        }
        .padding()
        .onAppear{
            sharedCMM.startSensor(.Accelerometer, withUpdateTimeOf: 1)
        }
    }
    
    
}
```



## Authors

- [@MaiaJP](https://github.com/Maia-jp)



