//
//  CoreMotionMagic.swift
//  CoreMotionMagic
//  Wrapper To facilitate the use of CoreMotion
//  Created by Joao Pedro Monteiro Maia on 24/11/22.
//

import Foundation
import CoreMotion

///  Wrapper To facilitate the use of CoreMotion
public class CoreMotionMagic:ObservableObject{
    static let shared = CoreMotionMagic()
    private let motion = CMMotionManager()
    private let altimeterManager = CMAltimeter()
    
    private(set) var availableSensors:[CMMSensors] = []
    private(set) var activeSensors:[CMMSensors] = []
    
    var updateTime:Double = 0
    
    //Sensor Data
    @Published var acceleration:CMAccelerometerData? {didSet{
        guard let acceleration else {return}
        accelerationBuffer.append(acceleration)
    }}
    @Published var gyro:CMGyroData?{didSet{
        guard let gyro else {return}
        gyroBuffer.append(gyro)
    }}
    @Published var magnetometer:CMMagnetometerData?{didSet{
        guard let magnetometer else {return}
        magnetometerBuffer.append(magnetometer)
    }}
    @Published var altimeter:CMAltitudeData?{didSet{
        guard let altimeter else {return}
        altimeterBuffer.append(altimeter)
    }}
    
    //Sensor Buffer
    var bufferSensorSize:Int = 624
    @Published var accelerationBuffer:[CMAccelerometerData] = [] {didSet{
        if(accelerationBuffer.count > bufferSensorSize){
            accelerationBuffer.remove(at: 0)
        }
    }}
    @Published var gyroBuffer:[CMGyroData] = [] {didSet{
        if(gyroBuffer.count > bufferSensorSize){
            gyroBuffer.remove(at: 0)
        }
    }}
    @Published var magnetometerBuffer:[CMMagnetometerData] = []{didSet{
        if(magnetometerBuffer.count > bufferSensorSize){
            magnetometerBuffer.remove(at: 0)
        }
    }}
    @Published var altimeterBuffer:[CMAltitudeData] = []{didSet{
        if(altimeterBuffer.count > bufferSensorSize){
            altimeterBuffer.remove(at: 0)
        }
    }}
    
    
    
    
    private init(){
        _ =  checkAllAvailableSensors()
    }
    
    deinit {
        stopAllSensors()
    }
    
    
    /// Returns all available sensors in this device (CoreMotion Only)
    /// - Returns: a list of CMMSensors containing all available sensors in this device
    @available(iOS 15.0, *)
    func checkAllAvailableSensors()->[CMMSensors]{
        availableSensors = []
        if(motion.isMagnetometerAvailable){
            availableSensors.append(.Magnetometer)
        }
        
        if(motion.isGyroAvailable){
            availableSensors.append(.Gyroscope)
        }
        
        if(motion.isAccelerometerAvailable){
            availableSensors.append(.Accelerometer)
        }
        if(CMAltimeter.isAbsoluteAltitudeAvailable()){
            availableSensors.append(.Altimeter)
        }
        
        return availableSensors
    }
    
    
    
    //
    //Starting sensors
    //
    
    /// Activate a sensors
    /// - Parameters:
    ///   - sensor: CMMSensor enum indicating the sensor to be activeted
    ///   - updateTime: Default time for all sensors update
    func startSensor(_ sensor:CMMSensors, withUpdateTimeOf updateTime:Double){
        if !availableSensors.contains(sensor) || activeSensors.contains(sensor){
            return
        }
        
        self.updateTime = updateTime
        startSensor(sensor)
    }
    
    /// Start the desired sensor based on the enum given
    /// - Parameter sensor: CMMsensor to be started
    func startSensor(_ sensor:CMMSensors){
        if !availableSensors.contains(sensor) || activeSensors.contains(sensor){
            return
        }
        if(self.updateTime <= 0){
            updateTime = 5
        }
        
        switch sensor {
        case .Accelerometer:
            startAccelerometer()
        case .Gyroscope:
            startGyroscope()
        case .Magnetometer:
            startMagnetometer()
        case .Altimeter:
            startBarometer()
        case .Barometer:
            startBarometer()
        }
    }
    
    /// Start all sensors avaliable in this device
    func startAllSensors(){
        for sensor in availableSensors {
            startSensor(sensor)
        }
    }
    
    /// Start all sensors except the one desired
    /// - Parameter desiredSensor: sensor that will NOT be started
    func startAllExcept(_ desiredSensor:CMMSensors){
        for sensor in availableSensors {
            if(sensor != desiredSensor){
                startSensor(sensor)
            }
        }
    }
    
    private func startAccelerometer(){
        motion.accelerometerUpdateInterval = updateTime
        motion.startAccelerometerUpdates(to: .main, withHandler:{ (data,erro) in
            self.acceleration = data
        })
        
    }
    
    private func startGyroscope(){
        motion.gyroUpdateInterval = updateTime
        motion.startGyroUpdates(to: .main, withHandler:{ (data,erro) in
            self.gyro = data
        })
    }
    
    private func startMagnetometer(){
        motion.magnetometerUpdateInterval = updateTime
        motion.startMagnetometerUpdates(to: .main, withHandler:{ (data,erro) in
            self.magnetometer = data
        })
    }
    
    private func startBarometer(){
        altimeterManager.startRelativeAltitudeUpdates(to: .main, withHandler: { (data,erro) in
            self.altimeter = data
        })
    }
    
    //
    //Buffering sensors
    //
    /// Clear all buffer from desired sensor
    /// - Parameter sensor: sensorBuffer to be cleared
    func clearSensorBuffer(fromSensor sensor:CMMSensors){
        switch sensor {
        case .Accelerometer:
            self.accelerationBuffer = []
        case .Gyroscope:
            self.gyroBuffer = []
        case .Magnetometer:
            self.magnetometerBuffer = []
        case .Altimeter:
            self.altimeterBuffer = []
        case .Barometer:
            break
        }
    }
    
    
    //
    //Stopping sensors sensors
    //
    /// Stop the given sensor
    /// - Parameter sensor: sensor to be stoped
    func stopSensor(_ sensor:CMMSensors){
        activeSensors = activeSensors.filter({$0 == sensor})
        switch sensor {
        case .Accelerometer:
            motion.stopAccelerometerUpdates()
        case .Gyroscope:
            motion.stopGyroUpdates()
        case .Magnetometer:
            motion.stopMagnetometerUpdates()
        case .Altimeter:
            altimeterManager.stopRelativeAltitudeUpdates()
        case .Barometer:
            altimeterManager.stopRelativeAltitudeUpdates()
        }
    }
    
    /// Stops all sensors
    func stopAllSensors(){
        for sensor in activeSensors{
            stopSensor(sensor)
        }
    }
    
    /// Stop all sensors except the one given
    /// - Parameter desiredSensor: Sensor that will NOT BE STOPED
    func stopAllExcept(_ desiredSensor:CMMSensors){
        for sensor in activeSensors {
            if desiredSensor != sensor {
                stopSensor(sensor)
            }
        }
    }
    
}



