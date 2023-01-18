//
//  AssessmentConfig.swift
//


import UIKit
import Research
import WeatherRecorder
import MobilePassiveData
import JsonModel
import BridgeClient
import BridgeClientExtension
import BridgeClientUI

extension AppConfigObserver {
    
    public func decodeRecorderConfig() -> AssessmentRecorderConfig? {
        do {
            guard let data = self.configElementJson(identifier: "BackgroundRecorders")
            else {
                return nil
            }
            let decoder = JSONDecoder()
            return try decoder.decode(AssessmentRecorderConfig.self, from: data)
        }
        catch let err {
            print("WARNING! Failed to decode config: \(err)")
            return nil
        }
    }
}

public struct AssessmentRecorderConfig : Decodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case recorders, excludeMapping
    }
    
    public let recorders : [AsyncActionConfiguration]
    public let excludeMapping : [String : [String]]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var objects : [AsyncActionConfiguration] = []
        var mutableContainer = try container.nestedUnkeyedContainer(forKey: .recorders)
        while !mutableContainer.isAtEnd {
            let nestedDecoder = try mutableContainer.superDecoder()
            do {
                let object = try decoder.factory.decodePolymorphicObject(AsyncActionConfiguration.self, from: nestedDecoder)
                objects.append(object)
            }
            catch DecodingError.typeMismatch(let type, let context) {
                print("WARNING: Failed to decode recorder configuration \(type): \(context)")
            }
        }
        self.recorders = objects
        self.excludeMapping = try container.decodeIfPresent([String : [String]].self, forKey: .excludeMapping) ?? [:]
    }
}

extension WeatherResult : RSDArchivable {
    
    /// Build the archiveable or uploadable data for this result.
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        
        // create the manifest and encode the result.
        let manifest = RSDFileManifest(filename: "\(self.identifier).json",
                                       timestamp: self.startDate,
                                       contentType: "application/json",
                                       identifier: self.identifier,
                                       stepPath: stepPath)
        let data = try self.jsonEncodedData()
        return (manifest, data)
    }
}
