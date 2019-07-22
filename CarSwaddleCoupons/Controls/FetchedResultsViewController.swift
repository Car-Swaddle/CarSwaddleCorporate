//
//  FetchedResultsViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/29/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CoreData
import CarSwaddleUI


public enum FetchedResultsControllerUpdateType {
    case reloadAlways
    case individual
}

open class FetchedResultsTableViewController<T: NSFetchRequestResult>: TableViewController, NSFetchedResultsControllerDelegate {
    
    open var updateType: FetchedResultsControllerUpdateType = .individual
    
    private func didResetFetchedResultsController() {
        tableView.reloadData()
    }
    
    lazy private(set) open var fetchedResultsController: NSFetchedResultsController<T> = {
        return createFetchedResultsController()
    }()
    
    open var fetchRequest: NSFetchRequest<T>! {
        fatalError("subclass must override this property and return a value")
    }
    open var context: NSManagedObjectContext! {
        fatalError("subclass must override this property and return a value")
    }
    
    open var sectionNameKeyPath: String? { return nil }
    open var cacheName: String? { return nil }
    
    final public func resetFetchedResultsController() {
        self.fetchedResultsController = createFetchedResultsController()
        didResetFetchedResultsController()
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<T> {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            fatalError("Could not performFetch on FetchedResultsController, error: \(error.localizedDescription)")
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Convenience
    
    final func object(at indexPath: IndexPath) -> T {
        return fetchedResultsController.object(at: indexPath)
    }
    
    final func indexPath(forObject object: T) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    final func count(for section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard updateType == .individual else { return }
        switch type {
        case .insert:
            guard let insertIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [insertIndexPath], with: .automatic)
        case .delete:
            guard let deleteIndexPath = indexPath else { return }
            tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        case .update:
            guard let updateIndexPath = indexPath else { return }
            tableView.reloadRows(at: [updateIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            break
        }
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        guard updateType == .individual else { return }
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        @unknown default:
            break
        }
    }
    
    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch updateType {
        case .individual:
            tableView.beginUpdates()
        case .reloadAlways:
            break
        }
    }
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch updateType {
        case .individual:
            tableView.endUpdates()
        case .reloadAlways:
            tableView.reloadData()
        }
    }
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    
    // MARK: - Tableview Datasource
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("subclass must override")
    }
    
}







open class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBInspectable
    open var tableViewStyle: UITableView.Style = .plain
    
    @IBInspectable final private(set) public lazy var tableView: UITableView = {
        var tableView = UITableView(frame: self.view.bounds, style: tableViewStyle)
        return tableView
    }()
    
    public var refreshControl: UIRefreshControl? {
        didSet {
            guard viewIfLoaded != nil else { return }
            updateRefreshControl()
        }
    }
    
    @objc open func didPullToRefresh() {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.pinFrameToSuperViewBounds()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.sendSubviewToBack(tableView)
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TableViewController.didPullToRefresh), for: .valueChanged)
        self.refreshControl = refresh
        
        updateRefreshControl()
    }
    
    private func updateRefreshControl() {
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Tableview Datasource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("subclass must override")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("subclass must override")
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

