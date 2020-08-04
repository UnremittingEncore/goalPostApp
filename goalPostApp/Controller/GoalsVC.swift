//
//  ViewController.swift
//  goalPostApp
//
//  Created by Kaushik Talluri on 03/08/20.
//  Copyright © 2020 tckr. All rights reserved.
//

import UIKit
import CoreData

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @IBAction func addGoalBtnPressed(_ sender: Any) {
        guard let CreateGoalVC = storyboard?.instantiateViewController(identifier: "CreateGoalVC") else {
            return
        }
        presentDetail(CreateGoalVC)
    }
    
}

extension GoalsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else {
            return UITableViewCell()
        }
        cell.configureCell(description: "Eat salad Twice a week", type: .longTerm, goalProgressAmount: 2)
        return cell
    }
}

