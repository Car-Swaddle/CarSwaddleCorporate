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
import CarSwaddleStore
import CarSwaddleNetworkRequest

final class AuthoritiesViewController: FetchedResultsTableButtonViewController<Authority> {
    
    private var authorityRequest = AuthorityNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.setTitle(NSLocalizedString("Request Authority", comment: ""), for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Requests", comment: ""), style: .plain, target: self, action: #selector(AuthoritiesViewController.didTapRequests))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestDataIfNeeded()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Authorities", comment: "Coupons title")
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var fetchRequest: NSFetchRequest<Authority>! {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        fetchRequest.predicate = NSPredicate(value: true)
        return fetchRequest
    }
    
    override var context: NSManagedObjectContext! {
        return store.mainContext
    }
    
    @objc private func didTapRequests() {
        let viewController = AuthorityRequestListViewController.viewControllerFromStoryboard()
        let navigationController = viewController.inNavigationController()
        present(navigationController, animated: true, completion: nil)
    }
    
    override func didSelectActionButton() {
        let viewController = RequestAuthorityViewController.viewControllerFromStoryboard()
        present(viewController.inNavigationController(), animated: true, completion: nil)
    }
    
    override var cellTypes: [NibRegisterable.Type] {
        return [AuthorityNameCell.self]
    }
    
    override func requestData(offset: Int, count: Int, completion: @escaping (Int?) -> Void) {
        store.privateContext { [weak self] context in
            self?.authorityRequest.getAuthorities(limit: count, offset: offset, in: context) { authorityObjectIDs, error in
                DispatchQueue.main.async {
                    completion(authorityObjectIDs.count)
                }
            }
        }
    }
    
    override func cell(for authority: Authority, indexPath: IndexPath) -> UITableViewCell {
        let cell: AuthorityNameCell = tableView.dequeueCell()
        cell.configure(with: authority)
        return cell
    }
    
}



extension Authority {
    
    static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Authority.creationDate), ascending: true)
    }
    
}
