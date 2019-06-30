//
//  AuthoritiesViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/1/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import Store

class AuthoritiesViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var requestButton: ActionButton!
    
    private var authorityRequest = AuthorityNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjuster.positionActionButton()
        requestButton.addTarget(self, action: #selector(AuthoritiesViewController.didTapRequestAuthority), for: .touchUpInside)
        
        setupTableView()
        requestData()
    }
    
    
    
    private lazy var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: requestButton)
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(AuthoritiesViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @IBAction private func didTapRequests() {
        let viewController = AuthorityRequestListViewController.viewControllerFromStoryboard()
        let navigationController = viewController.inNavigationController()
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func didTapRequestAuthority() {
        let viewController = RequestAuthorityViewController.viewControllerFromStoryboard()
        present(viewController.inNavigationController(), animated: true, completion: nil)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Authority> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Authority> {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        fetchRequest.predicate = NSPredicate(value: true)
        
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
        tableView.register(AuthorityNameCell.self)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.authorityRequest.getAuthorities(in: context) { authorityObjectIDs, error in
                DispatchQueue.main.async {
                    self?.resetData()
                    completion()
                }
            }
        }
    }
    
}

extension AuthoritiesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AuthorityNameCell = tableView.dequeueCell()
        let authority = fetchedResultsController.object(at: indexPath)
        cell.configure(with: authority)
        return cell
    }
    
}

extension AuthoritiesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension AuthoritiesViewController: NSFetchedResultsControllerDelegate {
    
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



extension Authority {
    
    static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Authority.creationDate), ascending: true)
    }
    
}
