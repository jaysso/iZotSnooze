//
//  HealthKitSetupAssistant.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 3/2/21.
//

import Foundation
import HealthKit

class HealthKitSetupAssistant {
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        enum HealthkitSetupError: Error {
            case notAvailableOnDevice(String)
            case dataTypeNotAvailable(String)}
            
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false,HealthkitSetupError.notAvailableOnDevice("User device does not support HealthKit."))
            return}
        //2. Prepare the data types that will interact with HealthKit
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let breathRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
                let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let standardDeviationHR = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
                let bodyTemp = HKObjectType.quantityType(forIdentifier: .bodyTemperature),
                let basalBodyTemp = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature), // resting body temp
                let enviroNoise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                let headphoneAudio = HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure),
                let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
                // sleepAnalysis.inBed, .asleep, .awake
                else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable("Data type is not avaliable."))
                return
                }
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [heartRate,
                                                        breathRate,
                                                        bodyMassIndex,
                                                        restingHeartRate,
                                                        standardDeviationHR,
                                                        bodyTemp,
                                                        basalBodyTemp,
                                                        enviroNoise,
                                                        headphoneAudio,
                                                        sleepAnalysis,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
            
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       heartRate,
                                                       breathRate,
                                                       restingHeartRate,
                                                       standardDeviationHR,
                                                       bodyTemp,
                                                       basalBodyTemp,
                                                       enviroNoise,
                                                       headphoneAudio,
                                                       sleepAnalysis,
                                                       HKObjectType.workoutType()]

        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        }
    }
}
