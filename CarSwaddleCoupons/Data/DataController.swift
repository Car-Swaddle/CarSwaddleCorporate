//
//  CurrentUserDataController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/23/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import Foundation
import CarSwaddleData
import CarSwaddleStore
import CoreData
import UIKit

extension Notification.Name {
    static let didUpdateAllAppData = Notification.Name("DataController.didUpdateAllData")
    static let currentUserAuthoritiesDidChange = Notification.Name("DataController.currentUserAuthoritiesDidChange")
}


class DataController: NSObject, NotificationObserver {
    
    private var authorityNetwork: AuthorityNetwork = AuthorityNetwork(serviceRequest: serviceRequest)
    
    public static func create() {
        _ = DataController.shared
    }
    
    public static  let shared: DataController = DataController()
    
    override init() {
        super.init()
        observe(selector: #selector(DataController.didLaunchApp), name: UIApplication.didFinishLaunchingNotification, object: nil)
        observe(selector: #selector(DataController.didOpenApp), name: UIApplication.didBecomeActiveNotification, object: nil)
        _ = fetchedResultsController
    }
    
    @objc private func didLaunchApp() {
        guard User.currentUser(context: store.mainContext) != nil else { return }
        updateAllData()
    }
    
    @objc private func didOpenApp() {
        guard User.currentUser(context: store.mainContext) != nil else { return }
        updateAllData()
    }
    
    public func updateAllData(completion: @escaping () -> Void = {}) {
        let group = DispatchGroup()
        group.enter()
        
        updateAuthorities {
            group.leave()
        }
        
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: .didUpdateAllAppData, object: nil)
            completion()
        }
    }
    
    private func updateAuthorities(completion: @escaping () -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.authorityNetwork.getCurrentUserAuthorities(in: privateContext) { authorityIDs, error in
                completion()
            }
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Authority> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Authority> {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        fetchRequest.predicate = Authority.currentUserAuthoritiesPredicate()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private var didAddAuthority: Bool = false
    
}

extension DataController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            didAddAuthority = true
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if didAddAuthority {
            NotificationCenter.default.post(name: .currentUserAuthoritiesDidChange, object: nil)
        }
    }
    
}





protocol NotificationObserver {
    func observe(selector: Selector, name: Notification.Name?, object: Any?)
}

extension NotificationObserver {
    
    func observe(selector: Selector, name: Notification.Name?, object: Any?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
}
