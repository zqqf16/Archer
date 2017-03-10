//
//  ViewController.swift
//  Archer
//
//  Created by zqqf16 on 2017/3/8.
//  Copyright © 2017年 zorro.im. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RuleManager.shared.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func removeRule(_ sender: AnyObject?) {
        let row = self.tableView.selectedRow
        if row < 0 {
            return
        }
        
        let pathes = RuleManager.shared.rules.keys.sorted()
        if row >= pathes.count {
            return
        }
        
        let path = pathes[row]
        RuleManager.shared.remove(path)
        self.tableView.reloadData()
    }
}

extension ViewController: RuleManagerDelegate {
    func didAddRule() {
        self.tableView.reloadData()
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return RuleManager.shared.rules.keys.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rules = RuleManager.shared.rules
        let path = rules.keys.sorted()[row]
        let mock = rules[path]
        
        var cellID: String?
        var text: String?
        
        if tableColumn == tableView.tableColumns[0] {
            cellID = "PathCell"
            text = path
        } else {
            cellID = "FilePathCell"
            text = mock?.serialize().last?.replace(old: "\n", " ")
        }
    
        if let cell = tableView.make(withIdentifier: cellID!, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text!
            cell.toolTip = text!
            return cell
        }
        
        return nil
    }
}
