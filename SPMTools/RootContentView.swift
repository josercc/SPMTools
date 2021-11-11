//
//  RootContentView.swift
//  SPMTools
//
//  Created by 张行 on 2021/11/5.
//

import SwiftUI
import AppKit

/// 主界面
struct RootContentView: View {
    /// 选取的 xcodeproj 文件的路径
    @State var xcodeprojFile:String = ""
    /// 是否展示错误
    @State var isShowError:Bool = false
    /// 展示错误信息
    @State var errorMessage:String = ""
    /// 当前Xcode添加的依赖
    @State var remotePackages:[RemoteSwiftPackageReference] = []
    /// 当前选中的依赖的 UUID
    @State var currentSelectPackageUUID:String?
    /// 展示新的弹窗
    @State var isShowAddPoper:Bool = false
    
    @State var showAddPackageSheet:Bool = false
    @State var showEditPackageSheet:Bool = false

    var body: some View {
        Form {
            HStack {
                Text("请选择xcodeproj文件:")
                    .foregroundColor(.gray)
                Text(xcodeprojFile).frame(maxWidth:.infinity, alignment: .leading)
                    .foregroundColor(.blue)
                Button("选取", action: selectButtonClick)
            }
            .padding()
            HStack {
                Text("Name")
                    .frame(width:150, alignment: .leading)
                Text("Version Rules")
                    .frame(width:150, alignment: .leading)
                Text("Location")
                    .frame(maxWidth:.infinity, alignment: .leading)

            }
            .padding()
            .background(.white)
            ForEach(remotePackages,id: \.self) { element in
                HStack {
                    Text(element.name ?? "")
                        .frame(width:150, alignment:.leading)
                    Text(element.requestDescription)
                        .frame(width:150, alignment: .leading)
                    Text(element.repositoryURL)
                        .frame(maxWidth:.infinity, alignment: .leading)
                }
                .padding()
                .background(currentSelectPackageUUID == element.uuid ? Color.blue : defaultCellBackground)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    currentSelectPackageUUID = element.uuid;
                }
            }
            Spacer()
            HStack() {
                Spacer()
                Button("新增", action: {showAddPackageSheet = true})
                    .sheet(isPresented: $showAddPackageSheet) {
                        addPackageView
                    }
                Button("编辑", action: {showEditPackageSheet = true})
                    .disabled(disableEditButton)
                    .sheet(isPresented: $showEditPackageSheet) {
                        editPackageView
                    }
                Button("删除", action: deletePackageClick)
                    .disabled(disableDeleteButton)
                Spacer()
            }
            .padding()
        }
        .alert(errorMessage, isPresented: $isShowError) {
            Text("OK")
        }
    }
    
    private var defaultCellBackground: Color {
        Color(hue: 1.0, saturation: 0.0, brightness: 0.96)
    }
    
    private var disableEditButton:Bool {
        currentSelectPackageUUID == nil
    }
    
    private var disableDeleteButton:Bool {
        currentSelectPackageUUID == nil
    }
    
    private var addPackageView:some View {
        AddPackageView(handle: {package in
            showAddPackageSheet = false
            addPackage(package: package)
        }, cancel: {
            showAddPackageSheet = false
        })
            .frame(width: 500, height: 200, alignment: .center)
    }
    
    private var editPackageView: some View {
        HStack {
            if let currentSelectPackageUUID = currentSelectPackageUUID, let package = remotePackages.first(where: {$0.uuid == currentSelectPackageUUID}) {
                AddPackageView(package:package ,handle: {package in
                    showEditPackageSheet = false
                    editPackage(package: package)
                }, cancel: {
                    showEditPackageSheet = false
                })
                    .frame(width: 500, height: 200, alignment: .center)
            } else {
                EmptyView()
            }
        }
    }
    
    func selectButtonClick() {
        guard let file = selectXcodeProjFile() else {return}
        xcodeprojFile = file
        do {
            remotePackages = try parsePackageList()
        } catch {
            showError(error: error.localizedDescription)
        }
    }
    func selectXcodeProjFile() -> String? {
        let openPanel = NSOpenPanel()
        guard openPanel.runModal() == .OK else {
            return nil
        }
        // file:///Users/king/Documents/SPMTools/SPMTools.xcodeproj/
        guard let url = openPanel.url?.absoluteString else {
            return nil
        }
        return url.replacingOccurrences(of: "file://", with: "")
    }
    
    func parsePackageList() throws -> [RemoteSwiftPackageReference] {
        let help = try XcodeProjectHelp(file: xcodeprojFile)
        return help.parsePackageReference()
    }
    
    func addPackage(package:RemoteSwiftPackageReference) {
        do {
            let help = try XcodeProjectHelp(file: xcodeprojFile)
            if let exitPackage = findExitPackage(packageUrl: package.repositoryURL) {
                try help.removePackage(uuid: exitPackage.uuid)
            }
            try help.addPackage(package: package)
            remotePackages = help.parsePackageReference()
        } catch {
            showError(error: error.localizedDescription)
        }
    }
    
    func editPackage(package:RemoteSwiftPackageReference) {
        do {
            let help = try XcodeProjectHelp(file: xcodeprojFile)
            if let exitPackage = findExitPackage(packageUrl: package.repositoryURL) {
                try help.removePackage(uuid: exitPackage.uuid)
            }
            try help.addPackage(package: package)
            remotePackages = help.parsePackageReference()
        } catch {
            showError(error: error.localizedDescription)
        }
    }
    
    func showViewInWindow<V:View>(view:V) {
        let window = NSWindowController(window: NSWindow())
        window.contentViewController = NSHostingController(rootView: view)
        window.showWindow(nil)
    }
    
    func deletePackageClick() {
        guard let currentSelectPackageUUID = currentSelectPackageUUID else {
            return
        }
        
        do {
            let help = try XcodeProjectHelp(file: xcodeprojFile)
            try help.removePackage(uuid: currentSelectPackageUUID)
            guard let removeIndex = remotePackages.firstIndex(where: {$0.uuid == currentSelectPackageUUID}) else {return}
            remotePackages.remove(at: removeIndex)
        } catch {
            showError(error: error.localizedDescription)
        }
    }
    
    func showError(error:String) {
        errorMessage = error
        isShowError = true
    }
    
    func findExitPackage(packageUrl:String) -> RemoteSwiftPackageReference? {
        return remotePackages.first(where: {$0.repositoryURL == packageUrl})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootContentView(remotePackages:[
                .init(uuid: UUID().uuidString,
                      name: "Request",
                      repositoryURL: "https://github.com/josercc/Request.get",
                      requirement: .upToNextMinorVersion("1.0.0"))
            ])
                .previewLayout(.device)

        }
    }
}
