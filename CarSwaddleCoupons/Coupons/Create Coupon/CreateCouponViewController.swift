//
//  CreateCouponViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/21/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData

class CreateCouponViewController: TableViewController {
    
    private enum Row: CaseIterable {
        case couponID
        case name
        case redeemByDate
        case discountBookingFee
        case isCorporate
        case maxRedemptions
    }
    
    private var couponNetwork: CouponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    
    private var rows: [Row] = Row.allCases
    
    private var couponID: String?
    private var name: String?
    private var redeemByDate: Date = Date().dateByAdding(weeks: 1)
    private var discountBookingFee: Bool = false
    private var isCorporate: Bool = true
    private var maxRedemptions: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive
        registerCells()
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTapCreate))
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCreate() {
//        guard let couponID = couponID,
//            let discount =
//        couponNetwork.createCoupon(id: <#T##String#>, discount: <#T##CouponNetwork.CouponDiscount#>, maxRedemptions: <#T##Int?#>, name: <#T##String#>, redeemBy: <#T##Date#>, discountBookingFee: <#T##Bool#>, isCorporate: <#T##Bool#>, in: <#T##NSManagedObjectContext#>, completion: <#T##(NSManagedObjectID?, Error?) -> Void#>)
    }
    
    private var discount: CouponNetwork.CouponDiscount? {
//        if let
        return nil
    }
    
    private func registerCells() {
        tableView.register(LabeledTextFieldCell.self)
        tableView.register(DatePickerCell.self)
        tableView.register(SwitchCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .couponID:
            let cell: LabeledTextFieldCell = tableView.dequeueCell()
            cell.labeledTextField.textField.text = couponID
            cell.labeledTextField.labelText = NSLocalizedString("Coupon Code", comment: "")
            cell.textChanged = { [weak self] newText in
                self?.couponID = newText
            }
            return cell
        case .name:
            let cell: LabeledTextFieldCell = tableView.dequeueCell()
            cell.labeledTextField.textField.text = name
            cell.labeledTextField.labelText = NSLocalizedString("Coupon Name", comment: "")
            cell.textChanged = { [weak self] newText in
                self?.name = newText
            }
            return cell
        case .redeemByDate:
            let cell: DatePickerCell = tableView.dequeueCell()
            cell.selectedDate = Date()
            cell.didChangeDate =  { [weak self] newDate in
                self?.redeemByDate = newDate
            }
            cell.willUpdateHeight = { [weak self] in
                self?.tableView.beginUpdates()
            }
            cell.didUpdateHeight = { [weak self] in
                self?.tableView.endUpdates()
            }
            return cell
        case .discountBookingFee:
            let cell: SwitchCell = tableView.dequeueCell()
            cell.labelText = NSLocalizedString("Remove Booking Fee", comment: "")
            cell.switchIsOn = discountBookingFee
            cell.switchDidChange = { [weak self] isOn in
                guard let self = self else { return }
                self.discountBookingFee = isOn
            }
            return cell
        case .isCorporate:
            let cell: SwitchCell = tableView.dequeueCell()
            cell.labelText = NSLocalizedString("Corporate Coupon", comment: "")
            cell.switchIsOn = isCorporate
            cell.switchDidChange = { [weak self] isOn in
                guard let self = self else { return }
                self.isCorporate = isOn
            }
            return cell
        case .maxRedemptions:
            let cell: LabeledTextFieldCell = tableView.dequeueCell()
            cell.labeledTextField.textField.text = maxRedemptions?.stringValue
            cell.labeledTextField.labelText = NSLocalizedString("Max redemptions", comment: "")
            cell.textChanged = { [weak self] newText in
                self?.maxRedemptions = newText?.intValue
            }
            return cell
        }
    }
    
}



extension String {
    
    public var intValue: Int? {
        return Int(self)
    }
    
}
