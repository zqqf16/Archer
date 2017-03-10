//
//  WindowController.swift
//  Archer
//
//  Created by zqqf16 on 2017/3/8.
//  Copyright © 2017年 zorro.im. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var progress: NSProgressIndicator!
   
    override func windowDidLoad() {
        super.windowDidLoad()
        
        //self.window?.styleMask.insert(.unifiedTitleAndToolbar)
    }

    @IBAction func startServer(_ sender: AnyObject?) {
        try? HttpServer.shared.start(9999, forceIPv4: true, priority: .default)
        self.progress.startAnimation(nil)
    }
    
    @IBAction func stopServer(_ sender: AnyObject?) {
        HttpServer.shared.stop()
        self.progress.stopAnimation(nil)
    }
}
