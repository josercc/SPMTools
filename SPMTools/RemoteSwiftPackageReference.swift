//
//  RemoteSwiftPackageReference.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import Foundation

struct RemoteSwiftPackageReference: Hashable {
    func hash(into hasher: inout Hasher) {
        
    }
    static func == (lhs: RemoteSwiftPackageReference, rhs: RemoteSwiftPackageReference) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    /// 3CBCD1572735149500488F3D
    let uuid:String
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

