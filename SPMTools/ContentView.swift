//
//  ContentView.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import SwiftUI

struct ContentView: View {
    
    @State var xcodeprojFile:String = "/Users/king/Documents/SPMTools/SPMTools.xcodeproj"
    @State var isShowError:Bool = false
    @State var errorMessage:String = ""
    @State var remotePackages:[RemoteSwiftPackageReference] = []
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
            List {
                ForEach(remotePackages,id: \.self) { element in
                    HStack {
                        Text(element.uuid)
                            .frame(maxWidth:.infinity, alignment: .leading)
                            .padding(.leading, 20)
                        Text(element.requestDescription)
                            .frame(maxWidth:.infinity, alignment: .center)
                        Text(element.repositoryURL)
                            .padding(.trailing,10)
                            .frame(maxWidth:.infinity, alignment: .trailing)
                            .padding(.trailing,20)
                        
                    }.onTapGesture {
                        
                    }
                }
            }
            Spacer()
        }.alert(errorMessage, isPresented: $isShowError) {
            Button("OK") {
                
            }
        }
    }
    
    func converJson() {
        let help = XcodeProjectHelp(xcodeProjectFile: xcodeprojFile)
        do {
            remotePackages = try help.converJsonFormat()
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
            ContentView()
                .frame(width: 500, height: 400, alignment: .center)

        }
    }
}
