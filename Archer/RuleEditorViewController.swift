//
//  RuleEditorViewController.swift
//  Archer
//
//  Created by zqqf16 on 2017/3/9.
//  Copyright © 2017年 zorro.im. All rights reserved.
//

import Cocoa

class RuleEditorViewController: NSViewController {

    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var fileField: NSTextField!
    
    @IBOutlet var jsonField: NSTextView!
    @IBOutlet var xmlField: NSTextView!
    
    @IBOutlet weak var tabView: NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func selectFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: self.view.window!) {
            (result) in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            
            if panel.urls.count == 0 {
                return
            }
            
            let url = panel.urls[0]
            self.fileField.stringValue = url.path;
        }
    }
    
    func jsonMock() -> MockResponse? {
        guard let content = self.jsonField.string, content.characters.count > 1 else {
            return nil
        }
        
        return .json(content)
    }
    
    func xmlMock() -> MockResponse? {
        guard let content = self.xmlField.string, content.characters.count > 1 else {
            return nil
        }
        
        return .xml(content)
    }
    
    func fileMock() -> MockResponse? {
        let path = self.fileField.stringValue
        if path == "" {
            return nil
        }
        
        return .file(path)
    }
    
    
    @IBAction func addRule(_ sender: Any) {
        let path = self.pathField.stringValue
        
        guard let selected = self.tabView.selectedTabViewItem else {
            return
        }

        let index = self.tabView.indexOfTabViewItem(selected)
        var mock: MockResponse? = nil

        if index == 0 {
            mock = self.jsonMock()
        } else if index == 1 {
            mock = self.xmlMock()
        } else {
            mock = self.fileMock()
        }
        
        if mock == nil {
            return
        }
        
        RuleManager.shared.add(path, mock: mock!)
        
        self.dismiss(nil)
    }
}
