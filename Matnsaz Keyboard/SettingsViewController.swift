//
//  SettingsViewController.swift
//  Matnsaz Keyboard
//
//  Created by Zeerak Ahmed on 8/4/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    private let settings = ["ترتیب", "حروف کی نمایندگی"]
    private var layouts: [String]
    private var layoutsEnglish: [String]
    private let labels = ["حروف کی علیحدہ صورتیں", "لفظ میں آنے والی صورت"]
    
    private let headerHeight: CGFloat = 42.0
    
    private var colorMode: KeyboardColorMode
    var keyboardViewController: KeyboardViewController?
    
    init(frame: CGRect, colorMode: KeyboardColorMode) {
        
        // instance variables
        self.colorMode = colorMode
        
        // add layouts
        self.layouts = []
        self.layoutsEnglish = []
        layouts.append(KeyboardLayout.Alphabetical.toUrdu())
        layoutsEnglish.append(KeyboardLayout.Alphabetical.rawValue)
        layouts.append(KeyboardLayout.MappingToQWERTY.toUrdu())
        layoutsEnglish.append(KeyboardLayout.MappingToQWERTY.rawValue)
        
        super.init(style: UITableView.Style.grouped)
        
        // basic table view setup
        self.tableView.frame = frame
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.semanticContentAttribute = .forceRightToLeft
       
        // header
        let headerView = UIView.init(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: 48.0)))
        let closeButton = UIButton.init(frame: CGRect(origin: CGPoint(x: frame.width - headerHeight, y: 0), size: CGSize(width: headerHeight, height: headerHeight)))
        closeButton.setImage(UIImage(named: "Close-" + self.colorMode.rawValue + ".png"), for: UIControl.State.normal)
        closeButton.addTarget(self, action: #selector(dismissSelf(sender:)), for: .touchUpInside)
        headerView.addSubview(closeButton)
        self.tableView.tableHeaderView = headerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismissSelf(sender: UIButton) {
        self.keyboardViewController?.hideSettings()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.layouts.count
        case 1:
            return self.labels.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        var data: Array<String> = []
        var selected = false
        switch indexPath.section {
        case 0:
            data = self.layouts
            let defaultLayout = UserDefaults.standard.value(forKey: SavedDefaults.KeyLayout.rawValue)
            if layoutsEnglish.index(of: defaultLayout as! String) == indexPath.row {
                selected = true
            }
        case 1:
            data = self.labels
            let defaultLabels = UserDefaults.standard.value(forKey: SavedDefaults.KeyLabels.rawValue)
            if indexPath.row == defaultLabels as! Int {
                selected = true
            }
        default:
            break
        }
        cell.textLabel?.text = data[indexPath.row]
        if selected {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // save settings
        switch indexPath.section {
        case 0:
            UserDefaults.standard.set(layoutsEnglish[indexPath.row], forKey: SavedDefaults.KeyLayout.rawValue)
        case 1:
            switch indexPath.row {
            case 0:
                UserDefaults.standard.set(false, forKey: SavedDefaults.KeyLabels.rawValue)
            case 1:
                UserDefaults.standard.set(true, forKey: SavedDefaults.KeyLabels.rawValue)
            default:
                break
            }
        default:
            break
        }
        
        // check mark selected row
        uncheckAllRowsInSection(section: indexPath.section)
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func uncheckAllRowsInSection(section: Int) {
        let rows = self.tableView.numberOfRows(inSection: section)
        for row in 0...rows {
            self.tableView.cellForRow(at: IndexPath(row: row, section: section))?.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
}
