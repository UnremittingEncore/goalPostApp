//
//  ViewController.swift
//  goalPostApp
//
//  Created by Kaushik Talluri on 03/08/20.
//  Copyright © 2020 tckr. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goalStatus: UILabel! 
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var undoLbl: UILabel!
    
    func undoButtonHidden() {
        goalStatus.isHidden = true
        undoBtn.isHidden = true
        undoLbl.isHidden = true
    }
    
    func undoButtonShown() {
        goalStatus.isHidden = false
        undoBtn.isHidden = false
        undoLbl.isHidden = false
    }
    
    var goals: [Goal] = []
    var tempGoalDescription: String! = ""
    var tempGoalType: String! = ""
    var tempCompletionVal: Int32 = 0
    var tempProgress: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        undoButtonHidden()
    }
    
    @IBAction func undoBtnPressed(_ sender: Any) {
        print("In removed condition")
        self.undoManager?.registerUndo(withTarget: self, handler: { (Target) in
         Target.saveGoal(derscription: self.tempGoalDescription, type: self.tempGoalType, completionValue: self.tempCompletionVal, progress: self.tempProgress)
        })
         self.undoManager?.undo()
         fetchCoreDataObjects()
         tableView.reloadData()
         undoButtonHidden()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    func fetchCoreDataObjects() {
        //let tempGoalCount = goals.count
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                }
                else {
                    tableView.isHidden = true
                    tempGoalDescription = ""
                }
            }
        }
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
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else {
            return UITableViewCell()
        }
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let resetAction = UIContextualAction(style: .normal, title: "RESET") { (action, view, nil) in
            self.setProgress(atIndexPath: indexPath, flag: 2)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        let removeAction = UIContextualAction(style: .normal, title: "-1") { (action, view, nil) in
            self.setProgress(atIndexPath: indexPath, flag: 1)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        }
        resetAction.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
       
        removeAction.backgroundColor = #colorLiteral(red: 0.06774160893, green: 0.2751933062, blue: 0.3610305256, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [resetAction, removeAction])
        configuration.performsFirstActionWithFullSwipe = false// use this if you dont want full swipe
        return configuration
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let addAction =  UITableViewRowAction(style: .destructive, title: "+1") { (rowAction, indexPath) in
                   self.setProgress(atIndexPath: indexPath, flag: 0)
                   tableView.reloadRows(at: [indexPath], with: .automatic)
               }
        addAction.backgroundColor = #colorLiteral(red: 0.9385011792, green: 0.7164435983, blue: 0.3331357837, alpha: 1)
        deleteAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        return [deleteAction, addAction]
    }
}

extension GoalsVC {
    func saveGoal(derscription: String, type: String, completionValue: Int32, progress: Int32) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let goal = Goal(context: managedContext)
        
        goal.goalDescription = derscription
        goal.goalType = type
        goal.goalCompletionValue = completionValue
        goal.goalProgress = progress
        
        do {
            try managedContext.save()
            print("Successfully saved data.")
            
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            
        }
    }
    
    func setProgress(atIndexPath indexPath: IndexPath, flag: Int) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let chosenGoal = goals[indexPath.row]
        /*Flag guide
            if Flag = 0 -> add progress
            if Flag = 1 -> -1 progress
            if flag = anything else(say 2 here) -> reset progress to 0
         */
        if flag == 0 {
            if chosenGoal.goalProgress <= chosenGoal.goalCompletionValue {
                chosenGoal.goalProgress += 1
            }
            else {
                return
            }
        }
        else if flag == 1 {
            if chosenGoal.goalProgress <= chosenGoal.goalCompletionValue {
                if chosenGoal.goalProgress > 0 {chosenGoal.goalProgress -= 1}
            }
            else {
                return
            }
        }
        else {
            chosenGoal.goalProgress = 0
        }
       
        do {
            try managedContext.save()
            print("success set progress")
        }catch {
            debugPrint("Could not set progress: \(error.localizedDescription)")
        }
    }
    
    func removeGoal(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        tempGoalDescription = goals[indexPath.row].goalDescription
        tempGoalType = goals[indexPath.row].goalType
        tempCompletionVal = goals[indexPath.row].goalCompletionValue
        tempProgress = goals[indexPath.row].goalProgress
        
        managedContext.delete(goals[indexPath.row])
        
        do {
            try managedContext.save()
            undoButtonShown()
            goalStatus.text = "Goal Removed"
            print("success removal")
        } catch {
            debugPrint("Could not remove: \(error)")
        }
    }
    
    
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        
        do {
            goals = try managedContext.fetch(fetchRequest)
            completion(true)
            print("fetch success")
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}
