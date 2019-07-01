//
//  MechanicListViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/29/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleUI
import Store
import CoreData


private let disallowTitle = NSLocalizedString("Disallow", comment: "reject title")
private let allowTitle = NSLocalizedString("Allow", comment: "reject title")

class MechanicListViewController: FetchedResultsTableViewController<Mechanic> {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MechanicListCell.self)
        requestData()
//        tableView.delegate = self
    }
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override var fetchRequest: NSFetchRequest<Mechanic>! {
        return createFetchRequest()
    }
    
    private func createFetchRequest() -> NSFetchRequest<Mechanic> {
        let fetchRequest: NSFetchRequest<Mechanic> = Mechanic.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Mechanic.creationDate), ascending: true)]
        return fetchRequest
    }
    
    override var context: NSManagedObjectContext! {
        return store.mainContext
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MechanicListCell = tableView.dequeueCell()
        cell.configure(with: object(at: indexPath))
        return cell
    }
    
    override func didRefresh() {
        requestData { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getMechanics(limit: 30, offset: 0, sortType: .descending, in: context) { mechanicIDs, error in
                print("done: \(mechanicIDs.count)")
                completion()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let action = self.rowAction(for: indexPath) {
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let action = self.rowAction(for: indexPath) {
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            return nil
        }
    }
    
    private func rowAction(for indexPath: IndexPath) -> UIContextualAction? {
        if object(at: indexPath).isAllowed {
            return self.disallowAction(indexPath: indexPath)
        } else {
            return self.allowAction(indexPath: indexPath)
        }
    }
    
    private func disallowAction(indexPath: IndexPath) -> UIContextualAction? {
        guard currentUserCanEditMechanic else { return nil }
        return self.action(title: disallowTitle, isAllowed: false, backgroundColor: .red5, indexPath: indexPath)
    }
    
    private func allowAction(indexPath: IndexPath) -> UIContextualAction? {
        guard currentUserCanEditMechanic else { return nil }
        return self.action(title: allowTitle, isAllowed: true, backgroundColor: .blue5, indexPath: indexPath)
    }
    
    private func action(title: String, isAllowed: Bool, backgroundColor: UIColor, indexPath: IndexPath) -> UIContextualAction? {
        let mechanicID = object(at: indexPath).identifier
        let action = UIContextualAction(style: .normal, title: title) { [weak self] action, view, completion in
            store.privateContext{ privateContext in
                self?.mechanicNetwork.updateMechanicCorperate(mechanicID: mechanicID, isAllowed: isAllowed, in: privateContext) { mechanicObjectID, error in
                    print("update")
                    DispatchQueue.main.async {
                        completion(error == nil)
                    }
                }
            }
        }
        action.backgroundColor = backgroundColor
        return action
    }
    
    
    private var currentUserCanEditMechanic: Bool {
        return Authority.currentUser(has: .editAuthorities, in: store.mainContext)
    }
    
}
