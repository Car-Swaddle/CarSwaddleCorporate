//
//  AuthorityRequestListViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/20/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import CarSwaddleStore

private let rejectTitle = NSLocalizedString("Reject", comment: "reject title")
private let approveTitle = NSLocalizedString("Approve", comment: "reject title")
private let doneTitle = NSLocalizedString("Done", comment: "done button")

class AuthorityRequestListViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var authorityRequest = AuthorityNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var actionButton: ActionButton!
    lazy private var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestData()
        
        navigationItem.leftBarButtonItem = doneButton
    }
    
    private var doneButton: UIBarButtonItem {
        return UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(didTapDone))
    }
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func didTapRequestAuthority() {
        
    }
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(AuthorityRequestListViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<AuthorityRequest> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<AuthorityRequest> {
        let fetchRequest: NSFetchRequest<AuthorityRequest> = AuthorityRequest.fetchRequest()
        fetchRequest.sortDescriptors = [AuthorityRequest.creationDateSortDescriptor]
        fetchRequest.predicate = AuthorityRequest.predicateForOutstandingAuthorityRequests()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(AuthorityRequestCell.self)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.authorityRequest.getAuthorityRequests(pending: true, in: context) { authorityRequestIDs, error in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}

extension AuthorityRequestListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AuthorityRequestCell = tableView.dequeueCell()
        let authorityRequest = fetchedResultsController.object(at: indexPath)
        cell.configure(with: authorityRequest)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let secretID = fetchedResultsController.object(at: indexPath).secretID else {
            return nil
        }
        let rejectAction = UIContextualAction(style: .destructive, title: rejectTitle) { action, view, completion in
            store.privateContext{ privateContext in
                self.authorityRequest.rejectAuthorityRequest(secretID: secretID, in: privateContext) { confirmationID, error in
                    //                    print("confirmation: \(confirmationID)")
                    if let error = error {
                        print("error: \(error)")
                    }
                    DispatchQueue.main.async {
                        completion(error == nil)
                    }
                }
            }
        }
        let approveAction = UIContextualAction(style: .normal, title: approveTitle) { action, view, completion in
            store.privateContext{ privateContext in
                self.authorityRequest.approveAuthorityRequest(secretID: secretID, in: privateContext) { confirmationID, error in
                    //                    print("confirmation: \(confirmationID)")
                    if let error = error {
                        print("error: \(error)")
                    }
                    DispatchQueue.main.async {
                        completion(error == nil)
                    }
                }
            }
        }
        approveAction.backgroundColor = .blue4
        
        return UISwipeActionsConfiguration(actions: [approveAction, rejectAction])
    }
    
}

extension AuthorityRequestListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}


extension AuthorityRequestListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}



extension AuthorityRequest {
    
    static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AuthorityRequest.creationDate), ascending: true)
    }
    
    static func predicateForOutstandingAuthorityRequests() -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [AuthorityRequest.noConfirmationPredicate(), AuthorityRequest.expiredPredicate()])
    }
    
    static func noConfirmationPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == nil", #keyPath(AuthorityRequest.authorityConfirmation))
    }
    
    static func expiredPredicate() -> NSPredicate {
        return NSPredicate(format: "%@ < %K", Date() as CVarArg, #keyPath(AuthorityRequest.expirationDate))
    }
    
}
