// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedOpenBridgeApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        // Core app code that can be used to set up a bespoke app
        .library(
            name: "SharedOpenBridgeApp",
            targets: ["SharedOpenBridgeApp"]),
    ],
    dependencies: [

        // Core dependencies that are required to connect to Bridge/Synapse
        .package(url: "https://github.com/BridgeDigitalHealth/BridgeClientKMM.git",
                 from: "0.19.0"),
        .package(url: "https://github.com/BridgeDigitalHealth/AssessmentModelKMM.git",
                 from: "1.0.2"),
        .package(url: "https://github.com/BridgeDigitalHealth/MobilePassiveData-SDK.git",
                 from: "1.6.2"),
        .package(url: "https://github.com/BridgeDigitalHealth/JsonModel-Swift.git",
                 from: "2.2.2"),

    ],
    targets: [
        // Shared app code that can be imported by assessment QA apps.
        .target(
            name: "SharedOpenBridgeApp",
            dependencies: [
                "SharedLibraries",
            ],
            resources: [.process("Resources")]
        ),
        
        // Used to work-around SwiftUI previews not working for packages.
        // Note: by setting the Swift tools version to 5.8, this work-around appears to be unnecessary. syoung 06/30/2023
        .target(name: "SharedLibraries",
                dependencies: [
                    .product(name: "BridgeClient", package:"BridgeClientKMM"),
                    .product(name: "MobilePassiveData", package: "MobilePassiveData-SDK"),
                    .product(name: "JsonModel", package: "JsonModel-Swift"),
                    .product(name: "AssessmentModel", package: "AssessmentModelKMM"),
                    .product(name: "AssessmentModelUI", package: "AssessmentModelKMM"),                 
                    
                    // Leaving these here commented out - if recorders are ever supported again, these will
                    // need to be uncommented and the package and plist will need to include them. syoung 05/19/2023
                    //    .product(name: "AudioRecorder", package: "MobilePassiveData"),
                    //    .product(name: "WeatherRecorder", package: "MobilePassiveData"),
                    //    .product(name: "MotionSensor", package: "MobilePassiveData"),
                    //    .product(name: "LocationAuthorization", package: "MobilePassiveData"),
                ]
               ),
        
        .testTarget(
            name: "SharedOpenBridgeAppTests",
            dependencies: ["SharedOpenBridgeApp"]),
    ]
)
