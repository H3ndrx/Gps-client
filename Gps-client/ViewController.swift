//
//  ViewController.swift
//  Gps-client
//
//  Created by Gabriel Zolnierczuk on 13.05.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
	let tagManager: TagManager = Toybox.shared.tagManager
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tagManager.rangingManager.requestAlwaysPermissions(with: { (granted: Bool) in
			if granted {
				self.tagManager.refreshLocationServices()
			}
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

