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
    
    override var cellTypes: [NibRegisterable.Type] { return [CouponCell.self] }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTapCreate))
    }
    
    @objc private func didTapCreate() {
        let coupon = CreateCouponViewController().inNavigationController()
        present(coupon, animated: true, completion: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Coupons", comment: "Coupons title")
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var fetchRequest: NSFetchRequest<Coupon>! {
        let fetchRequest: NSFetchRequest<Coupon> = Coupon.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [Coupon.creationDateSortDescriptor]
        return fetchRequest
    }
    
    override var context: NSManagedObjectContext! { return store.mainContext }
    
    final public override func cell(for coupon: Coupon, indexPath: IndexPath) -> UITableViewCell {
        let cell: CouponCell = tableView.dequeueCell()
        cell.configure(with: coupon)
        return cell
    }
    
    override func requestData(offset: Int, count: Int, completion: @escaping (Int?) -> Void) {
        store.privateContext { [weak self] context in
            self?.couponNetwork.getCoupons(limit: count, offset: offset, in: context) { couponIDs, error in
                DispatchQueue.main.async {
                    completion(couponIDs.count)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.firstVisibleCell(of: CouponCell.self)?.showCopyMenu()
    }
        
}


extension Coupon {
    
    static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Coupon.creationDate), ascending: false)
    }
    
}
