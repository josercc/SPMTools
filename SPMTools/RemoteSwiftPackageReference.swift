//
//  RemoteSwiftPackageReference.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import Foundation
import SwiftyJSON

struct RemoteSwiftPackageReference: Hashable {
    func hash(into hasher: inout Hasher) {
        
    }
    static func == (lhs: RemoteSwiftPackageReference, rhs: RemoteSwiftPackageReference) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    /// 3CBCD1572735149500488F3D
    let uuid:String
    var name:String?
    let repositoryURL:String
    let requirement:Requirement
    
    var requestDescription:String {
        switch (requirement) {
        case .upToNextMajorVersion(let version):
            return "\(version) NextMajor"
        case .upToNextMinorVersion(let version):
            return "\(version) NextMinor"
        case .versionRange(let start, let end):
            return "\(start) - \(end)"
        case .exactVersion(let version):
            return version
        case .branch(let branch):
            return branch
        case .revision(let revision):
            return revision
        }
    }
    
    var jsonValue:JSON {
        var json = JSON()
        json["isa"] = JSON("XCRemoteSwiftPackageReference")
        switch(requirement) {
        case .upToNextMajorVersion(let version):
            var requirement = JSON()
            requirement["kind"] = JSON("upToNextMajorVersion")
            requirement["minimumVersion"] = JSON(version)
            json["requirement"] = requirement
        case .upToNextMinorVersion(let version):
            var requirement = JSON()
            requirement["kind"] = JSON("upToNextMinorVersion")
            requirement["minimumVersion"] = JSON(version)
            json["requirement"] = requirement
        case .versionRange(let minimumVersion, let maximumVersion):
            var requirement = JSON()
            requirement["kind"] = JSON("versionRange")
            requirement["minimumVersion"] = JSON(minimumVersion)
            requirement["maximumVersion"] = JSON(maximumVersion)
            json["requirement"] = requirement
        case .branch(let branch):
            var requirement = JSON()
            requirement["kind"] = JSON("branch")
            requirement["branch"] = JSON(branch)
            json["requirement"] = requirement
        case .exactVersion(let version):
            var requirement = JSON()
            requirement["kind"] = JSON("exactVersion")
            requirement["version"] = JSON(version)
            json["requirement"] = requirement
        case .revision(let revision):
            var requirement = JSON()
            requirement["kind"] = JSON("revision")
            requirement["revision"] = JSON(revision)
            json["requirement"] = requirement
        }
        
        return json
    }
}

extension RemoteSwiftPackageReference {
    enum Requirement {
        case upToNextMajorVersion(String)
        case upToNextMinorVersion(String)
        case versionRange(String,String)
        case exactVersion(String)
        case branch(String)
        case revision(String)
    }
}

