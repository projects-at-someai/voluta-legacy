// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Ensembles",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "Ensembles",
            type: .dynamic,
            targets: ["Ensembles"]
        ),
        .library(
            name: "EnsemblesCloudKit",
            type: .dynamic,
            targets: ["EnsemblesCloudKit"]
        ),
        .library(
            name: "EnsemblesDropboxV2",
            type: .dynamic,
            targets: ["EnsemblesDropboxV2"]
        ),
        .library(
            name: "EnsemblesZip",
            type: .dynamic,
            targets: ["EnsemblesZip"]
        ),
        .library(
            name: "EnsemblesNode",
            type: .dynamic,
            targets: ["EnsemblesNode"]
        ),
        .library(
            name: "EnsemblesMultipeer",
            type: .dynamic,
            targets: ["EnsemblesMultipeer"]
        )
    ],
    targets: [
        .target(
            name: "Ensembles",
            dependencies: [],
            path: "Framework/Source/",
            resources: [.process("SwiftPackageResources")],
            publicHeadersPath: "SwiftPackageHeaders",
            cSettings: [
                .headerSearchPath("General"),
                .headerSearchPath("Asynchronicity"),
                .headerSearchPath("Baselines"),
                .headerSearchPath("Cloud"),
                .headerSearchPath("Cloud File Systems"),
                .headerSearchPath("Ensemble"),
                .headerSearchPath("Events"),
                .headerSearchPath("Integration"),
                .headerSearchPath("Migration"),
                .headerSearchPath("Model"),
                .headerSearchPath("Revisioning"),
            ]
        ),
        .target(
            name: "EnsemblesCloudKit",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
                "CDEEncryptedCloudFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDENodeCloudFileSystem.m",
                "CDEZipCloudFileSystem.m"
            ],
            sources: ["CDECloudKitFileSystem.m"],
            publicHeadersPath: "SwiftPackageCloudKitHeaders"
        ),
        .target(
            name: "EnsemblesDropboxV2",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEEncryptedCloudFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDENodeCloudFileSystem.m",
                "CDEZipCloudFileSystem.m"
            ],
            sources: ["CDEDropboxV2CloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageDropboxV2Headers"
        ),
        .target(
            name: "EnsemblesZip",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEEncryptedCloudFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDENodeCloudFileSystem.m"
            ],
            sources: ["CDEZipCloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageZipHeaders"
        ),
        .target(
            name: "EnsemblesNode",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEEncryptedCloudFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDEZipCloudFileSystem.m"
            ],
            sources: ["CDENodeCloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageNodeHeaders"
        ),
        .target(
            name: "EnsemblesMultipeer",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEEncryptedCloudFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDEZipCloudFileSystem.m",
                "CDENodeCloudFileSystem.m"
            ],
            sources: ["CDEMultipeerCloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageMultipeerHeaders"
        ),
        .target(
            name: "EnsemblesEncrypted",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEWebDavCloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEZipCloudFileSystem.m",
                "CDENodeCloudFileSystem.m"
            ],
            sources: ["CDEEncryptedCloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageEncryptedHeaders"
        ),
        .target(
            name: "EnsemblesWebDav",
            dependencies: ["Ensembles"],
            path: "Framework/Extensions",
            exclude: [
				"CDECloudKitFileSystem.m",
                "CDEDropboxCloudFileSystem.m",
                "CDEDropboxV2CloudFileSystem.m",
                "CDEEncryptedCloudFileSystem.m",
                "CDEMultipeerCloudFileSystem.m",
                "CDEZipCloudFileSystem.m",
                "CDENodeCloudFileSystem.m"
            ],
            sources: ["CDEWebDavCloudFileSystem.m"],
            publicHeadersPath: "SwiftPackageWebDavHeaders"
        )
    ]
)

