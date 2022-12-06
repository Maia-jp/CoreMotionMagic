//
//  CMMSensors.swift
//  CoreMotionMagic
//
//  Created by Joao Pedro Monteiro Maia on 24/11/22.
//

import Foundation
public enum CMMSensors:CaseIterable,Codable{
    case Accelerometer
    case Gyroscope
    case Magnetometer
    case Altimeter
    case Barometer
//    case Temperature TODO: Temperature
}

