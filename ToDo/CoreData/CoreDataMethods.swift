//
//  CoreData.swift
//  ToDo
//
//  Created by Антон on 08.05.2022.
//
import UIKit
import CoreData

class CoreDataMethods {
	var coreDataModel: [Tasks] = []
	static let shared = CoreDataMethods()
	
	//MARK: - SAVE TASK
	func saveTask(taskTitle:    String,
								taskTime:     String?,
								taskDate:     String?,
								taskDateDate: Date?,
								createdAt:    Date?,
								check:        Bool,
								alarmImage:   Bool,
								repeatImage:  Bool,
								timeInterval: String?) {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context) else {return}
		let model = Tasks(entity: entity, insertInto: context)
		model.taskTitle     = taskTitle
		model.taskTime      = taskTime
		model.taskDate      = taskDate
		model.taskDateDate  = taskDateDate
		model.createdAt     = createdAt
		model.check         = check
		model.alarmImage    = alarmImage
		model.repeatImage   = repeatImage
		model.timeInterval  = timeInterval
		do{
			try context.save()
			coreDataModel.append(model)
		} catch let error as NSError {
			print(error.localizedDescription)
		}
		
		guard alarmImage == true else { return }
		if repeatImage == true {
			LocalNotification.shared.sendRepeatNotification("repeat every \(Int(timeInterval!)!/60) min", taskTitle, timeInterval!)
		} else if alarmImage == true, repeatImage == false {
			LocalNotification.shared.sendReminderNotification("reminder \(taskTime!)", taskTitle, taskDateDate!)
		}
	}
	
	//MARK: - Delete Cell
	public func deleteCell(indexPath: IndexPath, presentedViewController: UIViewController) {
		//tappedRigid()
		let task             = coreDataModel[indexPath.row]
		let taskTitle        = task.taskTitle
		let areYouSureAllert = UIAlertController(title: "Delete '\(taskTitle)'?", message: nil, preferredStyle: .actionSheet)
		let noAction         = UIAlertAction(title: "cancel", style: .cancel)
		let yesAction        = UIAlertAction(title: "Yes, delete '\(taskTitle)'", style: .destructive) {_ in
			self.deleteFromContext(indexPath: indexPath, taskTitle: taskTitle, task: task)
		}
		areYouSureAllert.addAction(noAction)
		areYouSureAllert.addAction(yesAction)
		presentedViewController.present(areYouSureAllert, animated: true)
	}
	
	private func deleteFromContext(indexPath: IndexPath, taskTitle: String, task: Tasks) {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["id_\(taskTitle)"])
		context.delete(task as NSManagedObject)
		coreDataModel.remove(at: indexPath.row)
		let _ : NSError! = nil
		do {
			try context.save()
      NotificationCenter.default.post(name: Notification.Name("TableViewReloadData"), object: .none)
		} catch {
			print("error : \(error)")
		}
	}
	
	//MARK: - Fetch Request
	public func fetchRequest() {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
		do{
			coreDataModel = try context.fetch(fetchRequest)
		} catch let error as NSError {
			print(error.localizedDescription)
		}
	}
}
