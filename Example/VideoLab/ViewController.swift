//
//  ViewController.swift
//  VideoLab
//
//  Created by Bear on 2020/8/3.
//  Copyright (c) 2020 Chocolate. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let controller = VLEDemoViewController.init()
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 1 {
            let controller = VLEMainViewController.init()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

