//
//  RequestAuthorityViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/24/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore
import CarSwaddleData
import CoreData

final class RequestAuthorityViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: ActionButton!
    
    private var authorityNames: [Authority.Name] = [] {
        didSet {
            assert(Thread.isMainThread, "Must be on main when setting names")
            tableView.reloadData()
        }
    }
    
    private var authorityNetwork: AuthorityNetwork = AuthorityNetwork(serviceRequest: serviceRequest)
    
    private lazy var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: confirmButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RequestAuthorityCell.self)
        tableView.tableFooterView = UIView()
        
        requestAuthorityNames()
        updateButtonEnabledness()
    }
    
    private func requestAuthorityNames() {
        authorityNetwork.getAuthorityTypes { [weak self] authorityNames, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.authorityNames = authorityNames
            }
        }
    }
    
    @IBAction private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    private func selectedRow() -> Int? {
        return tableView.indexPathForSelectedRow?.row
    }
    
    private var isButtonEnabled: Bool {
        return selectedRow() != nil
    }
    
    private func updateButtonEnabledness() {
        confirmButton.isEnabled = isButtonEnabled
    }

    private func requestAuthority(_ authority: Authority.Name, completion: @escaping () -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.authorityNetwork.createAuthorityRequest(authority: authority.rawValue, in: privateContext) { authorityRequestID, error in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}


extension RequestAuthorityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authorityNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestAuthorityCell = tableView.dequeueCell()
        cell.configure(with: authorityNames[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if currentUserHasAuthority(at: indexPath) {
            return nil
        } else {
            return indexPath
        }
    }
    
    func currentUserHasAuthority(at indexPath: IndexPath) -> Bool {
        let name = authorityNames[indexPath.row]
        return name.currentUserHasAuthority(in: store.mainContext)
    }
    
    func currentUserHasRequestedAuthority(at indexPath: IndexPath) -> Bool {
        let name = authorityNames[indexPath.row]
        return AuthorityRequest.currentUserHasUnexpiredRequestedAuthority(with: name, in: store.mainContext)
    }
    
}

extension RequestAuthorityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = authorityNames[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? RequestAuthorityCell
        cell?.isRequesting = true
        requestAuthority(name) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let cell = self.tableView.cellForRow(at: indexPath) as? RequestAuthorityCell
                cell?.isRequesting = false
                self.tableView.reloadData()
            }
        }
    }
    
}


extension AuthorityRequest {
    
    public static func currentUserHasUnexpiredRequestedAuthority(with name: Authority.Name, in context: NSManagedObjectContext) -> Bool {
        return fetchCurrentUserAuthorityRequest(withName: name.rawValue, in: context) != nil
    }
    
    public static func currentUserHasUnexpiredRequestedAuthority(withName name: String, in context: NSManagedObjectContext) -> Bool {
        return fetchCurrentUserAuthorityRequest(withName: name, in: context) != nil
    }
    
    public static func fetchCurrentUserUnexpiredAuthorityRequest(with name: Authority.Name, in context: NSManagedObjectContext) -> AuthorityRequest? {
        return fetchCurrentUserAuthorityRequest(withName: name.rawValue, in: context)
    }
    
    public static func fetchCurrentUserAuthorityRequest(withName name: String, in context: NSManagedObjectContext) -> AuthorityRequest? {
        guard let userID = User.currentUser(context: context)?.identifier else { return nil }
        let fetchRequest: NSFetchRequest<AuthorityRequest> = AuthorityRequest.fetchRequest()
        let predicates = [AuthorityRequest.predicateForRequester(withUserID: userID), AuthorityRequest.predicateForAuthorityRequest(withName: name), AuthorityRequest.predicateForEpirationDate(greaterThan: Date())]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [AuthorityRequest.creationDateSortDescriptor]
        return try? context.fetch(fetchRequest).first
    }
    
    public static func predicateForAuthorityRequest(withName name: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(AuthorityRequest.authorityName), name)
    }
    
    public static func predicateForRequester(withUserID userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(AuthorityRequest.requester.identifier), userID)
    }
    
    public static func predicateForEpirationDate(greaterThan date: Date) -> NSPredicate {
        return NSPredicate(format: "%K > %@", #keyPath(AuthorityRequest.expirationDate), date as NSDate)
    }
    
}
