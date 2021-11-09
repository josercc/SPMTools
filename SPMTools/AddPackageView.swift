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
    @State var currentRequement:String?
    
    var didAddpackageHandle:((RemoteSwiftPackageReference) -> Void)?
    
    var body: some View {
        Form {
            TextField("请输入URL", text: $packageURL)
            TextField("请输入包名", text: $packageName)
            MenuButton(label: Text(currentRequement ?? "请选择依赖")) {
                Button("NextMajor") {
                    currentRequement = "NextMajor"
                }
                Button("NextMinor") {
                    currentRequement = "NextMinor"
                }
                Button("Range") {
                    currentRequement = "Range"
                }
                Button("Version") {
                    currentRequement = "Version"
                }
                Button("Branch") {
                    currentRequement = "Branch"
                }
                Button("Revision") {
                    currentRequement = "Revision"
                }
            }
            if let currentRequement = currentRequement {
                if currentRequement == "Range" {
                    HStack {
                        TextField("请输入最小版本", text: $leftInputText)
                        Text("-")
                        TextField("请输入最大版本", text: $rightInputText)
                    }
                } else if currentRequement == "NextMajor" || currentRequement == "NextMinor" {
                    TextField("请输入最低支持版本", text: $leftInputText)
                } else if currentRequement == "Version" {
                    TextField("请输入指定版本", text: $leftInputText)
                } else if currentRequement == "Branch" {
                    TextField("请输入指定分支", text: $leftInputText)
                } else if currentRequement == "Revision" {
                    TextField("请输入指定提交", text: $leftInputText)
                }
            }
            Button("添加") {
                guard let currentRequement = currentRequement else {
                    return
                }
                if currentRequement == "NextMajor" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .upToNextMajorVersion(leftInputText)))
                } else if currentRequement == "NextMinor" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .upToNextMinorVersion(leftInputText)))
                } else if currentRequement == "Range" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .versionRange(leftInputText, rightInputText)))
                } else if currentRequement == "Version" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .exactVersion(leftInputText)))
                } else if currentRequement == "Branch" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .branch(leftInputText)))
                } else if currentRequement == "Revision" {
                    didAddpackageHandle?(.init(uuid: UUID().uuidString,
                                               name: packageName,
                                               repositoryURL: packageURL,
                                               requirement: .revision(leftInputText)))
                }
            }.disabled(currentRequement == nil)
            Spacer()
        }.padding()
    }
}

struct AddPackageView_Previews: PreviewProvider {
    static var previews: some View {
        AddPackageView()
            .frame(width: 500, height: 400, alignment: .center)
    }
}
