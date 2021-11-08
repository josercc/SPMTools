//
//  XcodeProjectHelp.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import Foundation
import SwiftShell
import AppKit
import SwiftyJSON

struct XcodeProjectHelp {
    let xcodeProjectFile:String
    func converJsonFormat() throws -> [RemoteSwiftPackageReference] {
        main.currentdirectory = xcodeProjectFile
        try runAndPrint("ls")
        // plutil -convert json project.pbxproj
        try runAndPrint("plutil", "-convert", "json", "project.pbxproj")
        let pbxprojFile = (xcodeProjectFile + "/project.pbxproj").replacingOccurrences(of: "//", with: "/")
        let source = try String(contentsOf: URL(fileURLWithPath: pbxprojFile))
        let json = JSON(parseJSON: source)
        var remotePackages:[RemoteSwiftPackageReference] = []
        var swiftPackageProducts:[SwiftPackageProductDependency] = []
        let objects = json["objects"].dictionaryValue
        for object in objects {
            let element = object.value
            if let isa = element["isa"].string, isa == "XCRemoteSwiftPackageReference" {
                guard let repositoryURL = element["repositoryURL"].string else {continue}
                let requirement = element["requirement"]
                guard let kind = requirement["kind"].string else {continue}
                if kind == "upToNextMajorVersion", let minimumVersion = requirement["minimumVersion"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .upToNextMajorVersion(minimumVersion)))
                } else if kind == "upToNextMinorVersion", let minimumVersion = requirement["minimumVersion"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .upToNextMinorVersion(minimumVersion)))
                } else if kind == "versionRange", let minimumVersion = requirement["minimumVersion"].string, let maximumVersion = requirement["maximumVersion"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .versionRange(minimumVersion, maximumVersion)))
                } else if kind == "exactVersion", let version = requirement["version"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .exactVersion(version)))
                } else if kind == "branch", let branch = requirement["branch"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .branch(branch)))
                } else if kind == "revision", let revision = requirement["revision"].string {
                    remotePackages.append(.init(uuid: object.key,
                                                repositoryURL: repositoryURL,
                                                requirement: .revision(revision)))
                }
            } else if let isa = element["isa"].string, isa == "XCSwiftPackageProductDependency" {
                guard let package = element["package"].string else {continue}
                guard let productName = element["productName"].string else {continue}
                swiftPackageProducts.append(.init(package: package, productName: productName))
            }
        }
        return remotePackages.map { package in
            guard let element = swiftPackageProducts.first(where: {$0.package == package.uuid}) else {
                return package
            }
            return .init(uuid: element.productName,
                         repositoryURL: package.repositoryURL,
                         requirement: package.requirement)
        }
    }
    
}

extension String: LocalizedError {
    public var errorDescription: String? {self}
}

