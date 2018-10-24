//
//  MasterViewController.swift
//  animatedSet
//
//  Created by Anti on 10/22/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

class GameChooserViewController: UIViewController {
    
    let themes = [
        "Sports":"⚽️🏀🏈⚾️🎾🏐🏉🎱🏓🏂🥊⛳️",
        "Animals":"🐶🐔🦊🐼🦀🐌🐨🐳🐙🦄🐵",
        "Faces":"😀😂😎😣🤨🧐😡😳😱😖",
        ]
    
//    override func awakeFromNib() {
//        splitViewController?.delegate = self
//    }
    
    // weird reversed bool
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentrationViewController {
            if cvc.theme == nil {
                return true
            }
        }
        return false
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        // for ipad split views
        if let cvc = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            // for iphones
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    // MARK: - Navigation
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                    lastSeguedToConcentrationViewController = cvc
                }
            }
        }
    }
}

