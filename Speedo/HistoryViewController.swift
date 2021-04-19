//
//  HistoryViewController.swift
//  Speedo
//
//  Created by Mushfiq Humayoon on 18/04/21.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!

    var ridingHistory = [History]()
    var cellIdentifier = "historyCell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        context = appDelegate.persistentContainer.viewContext
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        fetchRidingHistory()
        ridingHistory = ridingHistory.reversed()
        decideView()
    }

    //MARK: Fetch Riding History from Core Data
    func fetchRidingHistory() {
        context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [History] {
                ridingHistory.append(data)
                tableView.reloadData()
          }
        } catch {
            print("Failed")
        }
    }
    func changedDateFormat(at indexPath: IndexPath) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
         return dateFormatter.string(from: ridingHistory[indexPath.row].date!)
    }
    func decideView() {
        tableView.isHidden = ridingHistory.count == 0 ? true : false
        emptyLabel.isHidden = ridingHistory.count == 0 ? false : true
    }
    override func viewDidDisappear(_ animated: Bool) {
        ridingHistory.removeAll()
    }
}

//MARK: Tableview Data Source and Delegate
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ridingHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HistoryTableViewCell
        else {
            return UITableViewCell()
        }
        let startedLocation = ridingHistory[indexPath.row].startedLocation
        let endedLocation = ridingHistory[indexPath.row].endedLocation
        cell.rideStartedFromLabel.text = startedLocation == "" ? "-" : startedLocation
        cell.rideEndedLabel.text = endedLocation == "" ? "-" : endedLocation
        cell.averageSpeedLabel.text = ridingHistory[indexPath.row].averageSpeed
        cell.distanceTraveledLabel.text = ridingHistory[indexPath.row].distanceTraveled
        cell.dateLabel.text = changedDateFormat(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = ridingHistory[indexPath.row]
            context?.delete(commit)
            ridingHistory.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            do {
                try context?.save()
              } catch {
               print("Failed saving")
            }
            decideView()
        }
    }

}
