//
//  ContentView.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import SwiftUI

struct ContentView: View {
    
    @State var xcodeprojFile:String = ""
    @State var isShowError:Bool = false
    @State var errorMessage:String = ""
    @State var remotePackages:[RemoteSwiftPackageReference] = []
    @State var currentSelectPackageUUID:String?
    @State var isShowAddPoper:Bool = false
    var body: some View {
            VStack {
                HStack {
                    HStack {
                        Text("请选择xcodeproj文件")
                        TextField("请输入xcodeproj路径", text: $xcodeprojFile)
                        Button("选取") {
                            let openPanel = NSOpenPanel()
                            guard openPanel.runModal() == .OK else {
                                return
                            }
                            // file:///Users/king/Documents/SPMTools/SPMTools.xcodeproj/
                            guard let url = openPanel.url?.absoluteString else {
                                return
                            }
                            xcodeprojFile = url.replacingOccurrences(of: "file://", with: "")
                            converJson()
                        }
                    }.padding(.leading,20)
                    Spacer()
                }.padding(.top,20)
                HStack {
                    Text("Name")
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding(.leading, 20)
                    Text("Version Rules")
                        .frame(maxWidth:.infinity, alignment: .center)
                    Text("Location")
                        .padding(.trailing,10)
                        .frame(maxWidth:.infinity, alignment: .trailing)
                        .padding(.trailing,20)
                    
                }
                Form {
                    ForEach(remotePackages,id: \.self) { element in
                        HStack {
                            Text(element.name ?? "")
                                .frame(maxWidth:.infinity, alignment:.leading)
                                .padding(.leading, 20)
                                
                            Text(element.requestDescription)
                                .frame(maxWidth:.infinity, alignment: .center)
                            Text(element.repositoryURL)
                                .padding(.trailing,10)
                                .frame(maxWidth:.infinity, alignment: .trailing)
                                .padding(.trailing,20)
                        }
                        .frame(height:45)
                        .background(currentSelectPackageUUID == element.uuid ? Color.blue : Color.white)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            currentSelectPackageUUID = element.uuid;
                        }
                    }
                }
                Spacer()
                HStack(spacing:20) {
                    Button("新增") {
                        isShowAddPoper = true
                    }.popover(isPresented: $isShowAddPoper) {
                        AddPackageView{ package in
                            do {
                                let help = try XcodeProjectHelp(file: xcodeprojFile)
                                try help.addPackage(package: package)
                                remotePackages.append(package)
                                
                            }catch(let error) {
                                showError(error: error.localizedDescription)
                            }
                        }
                        .frame(width: 500, height: 400, alignment: .center)
                    }
                    Button("删除") {
                        guard let currentSelectPackageUUID = currentSelectPackageUUID else {
                            return
                        }
                        do {
                            let help = try XcodeProjectHelp(file: xcodeprojFile)
                            try help.removePackage(uuid: currentSelectPackageUUID)
                            if let removeIndex = remotePackages.firstIndex(where: {$0.uuid == currentSelectPackageUUID}) {
                                remotePackages.remove(at: removeIndex)
                            }
                        } catch(let error) {
                            showError(error: error.localizedDescription)
                        }
                    }
                    .disabled(currentSelectPackageUUID == nil)
                }
                .padding(.bottom, 20)
            }
            .alert(errorMessage, isPresented: $isShowError) {
                Button("OK") {
                    
                }
        }
        
    }
    
    func converJson() {
        do {
            let help = try XcodeProjectHelp(file: xcodeprojFile)
            remotePackages = help.parsePackageReference()
        } catch (let error) {
            print(error)
            showError(error: error.localizedDescription)
        }
    }
    
    func showError(error:String) {
        errorMessage = error
        isShowError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(remotePackages:[
                .init(uuid: "Request", repositoryURL: "https://github.com/josercc/Request.get", requirement: .upToNextMinorVersion("1.0.0"))
            ])
                .frame(width: 500, height: 400, alignment: .center)

        }
    }
}
