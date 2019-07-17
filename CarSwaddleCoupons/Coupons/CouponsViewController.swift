//
//  CouponsViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/1/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData
import CoreData

class CouponsViewController: FetchedResultsTableViewController<Coupon> {
    
    private var couponNetwork: CouponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CouponCell.self)
        
        requestData()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Coupons", comment: "Coupons title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    override var fetchRequest: NSFetchRequest<Coupon>! {
        let fetchRequest: NSFetchRequest<Coupon> = Coupon.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [Coupon.creationDateSortDescriptor]
        return fetchRequest
    }
    
    override var context: NSManagedObjectContext! {
        return store.mainContext
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CouponCell = tableView.dequeueCell()
        cell.configure(with: object(at: indexPath))
        return cell
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.couponNetwork.getCoupons(limit: 30, offset: 0, in: context) { couponIDs, error in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
}


extension Coupon {
    
    static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Coupon.creationDate), ascending: false)
    }
    
}
