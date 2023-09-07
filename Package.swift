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
//        .package(url: "https://github.com/Sage-Bionetworks/BridgeClientKMM.git",
//                 from: "0.17.6"),
        .package(path: "../BridgeClientKMM/"),
        .package(url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.5.4"),
        .package(url: "https://github.com/Sage-Bionetworks/SageResearch.git",
                 from: "4.10.0"),
        .package(url: "https://github.com/Sage-Bionetworks/SharedMobileUI-AppleOS.git",
                 from: "0.19.1"),
        .package(url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "2.0.0"),

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
                    .product(name: "Research", package: "SageResearch"),
                    .product(name: "ResearchUI", package: "SageResearch"),
                    .product(name: "SharedMobileUI", package: "SharedMobileUI-AppleOS"),
                    .product(name: "JsonModel", package: "JsonModel-Swift"),
                    
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
