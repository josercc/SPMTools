//
//  AddPackageView.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/9.
//

import SwiftUI

struct AddPackageView: View {
    @State var packageName:String = ""
    @State var packageURL:String = ""
    @State var leftInputText:String = ""
    @State var rightInputText:String = ""
    @State var currentRequement:Requirment = .nextMajor
    
    typealias AddOrEditHandle = (RemoteSwiftPackageReference) -> Void
    typealias CancelHandle = () -> Void
    
    var addOrEditHandle:AddOrEditHandle?
    var cancelHandle:CancelHandle?
    
    private var editPakcage:RemoteSwiftPackageReference?
    
    init(package:RemoteSwiftPackageReference? = nil,
         handle:@escaping AddOrEditHandle,
         cancel:@escaping CancelHandle) {
        addOrEditHandle = handle
        cancelHandle = cancel
        editPakcage = package
    }
    
    
    
    private var supportRequirments:[Requirment] = [
        .nextMajor,
        .nextMinor,
        .range,
        .version,
        .branch,
        .revision
    ]
    
    private var addButtonEnable:Bool {
        guard !packageURL.isEmpty else {
            return false
        }
        guard !packageName.isEmpty else {
            return false
        }
        if currentRequement == .range {
            return !leftInputText.isEmpty && !rightInputText.isEmpty
        } else {
            return !leftInputText.isEmpty
        }
    }
    
    
    var body: some View {
        Form {
            TextField("Package Url:", text: $packageURL)
            TextField("Package Name:", text: $packageName)
            Section("Requirement:") {
                Menu(currentRequement.rawValue) {
                    ForEach(supportRequirments, id:\.self) { element in
                        Button(element.rawValue) {
                            currentRequement = element
                        }
                    }
                }
            }
            if currentRequement == .nextMajor
                || currentRequement == .nextMinor {
                TextField("min version:", text: $leftInputText)
            } else if currentRequement == .range {
                TextField("Min Version:", text: $leftInputText)
                TextField("Max Version:", text: $rightInputText)
            } else if currentRequement == .version {
                TextField("Version:", text:$leftInputText)
            } else if currentRequement == .branch {
                TextField("Branch:", text:$leftInputText)
            } else if currentRequement == .revision {
                TextField("Revision:", text:$leftInputText)
            }
            Spacer()
            HStack {
                Button("新增", action: addClick)
                    .disabled(!addButtonEnable)
                Button("取消", action: cancelClick)
            }
        }
        .padding()
        .onAppear {
            if let package = editPakcage {
                packageName = package.name ?? ""
                packageURL = package.repositoryURL
                switch (package.requirement) {
                case .upToNextMajorVersion(let version):
                    currentRequement = .nextMajor
                    leftInputText = version
                case .upToNextMinorVersion(let version):
                    leftInputText = version
                    currentRequement = .nextMinor
                case .versionRange(let min, let max):
                    leftInputText = min
                    rightInputText = max
                    currentRequement = .range
                case .branch(let branch):
                    leftInputText = branch
                    currentRequement = .branch
                case .exactVersion(let version):
                    leftInputText = version
                    currentRequement = .version
                case .revision(let revision):
                    leftInputText = revision
                    currentRequement = .revision
                }
            }
        }
    }
    
    
    
    func addClick() {
        let requirement:RemoteSwiftPackageReference.Requirement
        switch(currentRequement) {
        case .nextMajor:
            requirement = .upToNextMajorVersion(leftInputText)
        case .nextMinor:
            requirement = .upToNextMinorVersion(leftInputText)
        case .range:
            requirement = .versionRange(leftInputText, rightInputText)
        case .version:
            requirement = .exactVersion(leftInputText)
        case .branch:
            requirement = .branch(leftInputText)
        case .revision:
            requirement = .revision(leftInputText)
        }
        let package = RemoteSwiftPackageReference(uuid: UUID().uuidString,
                                                  name: packageName,
                                                  repositoryURL: packageURL,
                                                  requirement: requirement)
        addOrEditHandle?(package)
    }
    
    func cancelClick() {
        cancelHandle?()
    }
    
    enum Requirment:String {
        case nextMajor
        case nextMinor
        case range
        case version
        case branch
        case revision
    }
}

struct AddPackageView_Previews: PreviewProvider {
    static var previews: some View {
        AddPackageView(handle: {_ in}, cancel: {})
            .frame(width: 500, height: 400, alignment: .center)
    }
}
