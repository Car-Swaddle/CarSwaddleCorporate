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

class MechanicListViewController: FetchedResultsTableViewController<Mechanic> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Mechanics", comment: "Title of mechanic list")
        requestData()
        tableView.register(MechanicListCell.self)
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
    
}
