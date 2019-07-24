//
//  CreateCouponViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/21/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest

class CreateCouponViewController: TableViewController {
    
    private enum Row: CaseIterable {
        case couponID
        case name
        case redeemByDate
        case discountBookingFee
        case isCorporate
        case maxRedemptions
        case discount
    }
    
    private var couponNetwork: CouponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    
    private lazy var createActionButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(NSLocalizedString("Create Coupon", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        return button
    }()
    
    private lazy var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: createActionButton)
    
    private var rows: [Row] = Row.allCases
    
    private var discount: CouponNetwork.CouponDiscount = .amountOff(value: 0)
    
    private var couponID: String?
    private var name: String?
    private var redeemByDate: Date = Date().dateByAdding(weeks: 1)
    private var discountBookingFee: Bool = false
    private var isCorporate: Bool = true
    private var maxRedemptions: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Coupon Creation", comment: "Title of screen where user can create a coupon")
        
        view.addSubview(createActionButton)

        adjuster.includeTabBarInKeyboardCalculation = false
        adjuster.positionActionButton()
        
        tableView.keyboardDismissMode = .interactive
        
        registerCells()
        
        tableView.tableFooterView = UIView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCreate() {
        guard let couponID = couponID,
            let maxRedemptions = maxRedemptions,
            let name = name else { return }
        
        let discount = self.discount
        let discountBookingFee = self.discountBookingFee
        let isCorporate = self.isCorporate
        let redeemByDate = self.redeemByDate
        
        createActionButton.isLoading = true
        store.privateContext { [weak self] privateContext in
            self?.couponNetwork.createCoupon(id: couponID, discount: discount, maxRedemptions: maxRedemptions, name: name, redeemBy: redeemByDate, discountBookingFee: discountBookingFee, isCorporate: isCorporate, in: privateContext) { couponObjectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.createActionButton.isLoading = false
                    if let error = error {
                        print("error: \(error)")
                    } else {
                        print("success")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func registerCells() {
        tableView.register(LabeledTextFieldCell.self)
        tableView.register(DatePickerCell.self)
        tableView.register(SwitchCell.self)
        tableView.register(CouponDiscountCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .couponID:
            let cell: LabeledTextFieldCell = tableView.dequeueCell()
            cell.labeledTextField.textField.text = couponID
            cell.labeledTextField.labelText = NSLocalizedString("Code", comment: "")
            cell.labeledTextField.textField.autocorrectionType = .no
            cell.labeledTextField.textField.autocapitalizationType = .none
            cell.labeledTextField.textField.spellCheckingType = .no
            cell.labeledTextField.textField.returnKeyType = .next
            
            cell.didBeginEditing = { [weak self] in
                self?.dismissDatePicker()
            }
            cell.textChanged = { [weak self] newText in
                self?.couponID = newText
            }
            cell.didTapReturn = { [weak self] in
                guard let self = self else { return }
                let cell: LabeledTextFieldCell? = self.cellAtIndex(after: indexPath)
                cell?.labeledTextField.textField.becomeFirstResponder()
            }
            return cell
        case .name:
            let cell: LabeledTextFieldCell = tableView.dequeueCell()
            cell.labeledTextField.textField.text = name
            cell.labeledTextField.labelText = NSLocalizedString("Name", comment: "")
            cell.labeledTextField.textField.returnKeyType = .next
            
            cell.textChanged = { [weak self] newText in
                self?.name = newText
            }
            cell.didBeginEditing = { [weak self] in
                self?.dismissDatePicker()
            }
            cell.didTapReturn = { [weak self] in
                guard let self = self else { return }
                let cell: DatePickerCell? = self.cellAtIndex(after: indexPath)
                cell?.showDatePicker()
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
            cell.didShowDatePicker = { [weak self] in
                self?.dismissKeyboard()
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
            
            cell.labeledTextField.textField.autocorrectionType = .no
            cell.labeledTextField.textField.autocapitalizationType = .none
            cell.labeledTextField.textField.spellCheckingType = .no
            cell.labeledTextField.textField.keyboardType = .numberPad
            cell.labeledTextField.textField.returnKeyType = .next
            
            cell.textChanged = { [weak self] newText in
                self?.maxRedemptions = newText?.intValue
            }
            cell.didBeginEditing = { [weak self] in
                self?.dismissDatePicker()
            }
            cell.didTapReturn = { [weak self] in
                guard let self = self else { return }
                let cell: CouponDiscountCell? = self.cellAtIndex(after: indexPath)
                cell?.makeTextFieldFirstResponder()
            }
            return cell
        case .discount:
            let cell: CouponDiscountCell = tableView.dequeueCell()
            cell.configure(with: discount)
            cell.discountDidChange = { [weak self] discount in
                if let discount = discount {
                    self?.discount = discount
                }
            }
            return cell
        }
    }
    
    private func cellAtIndex<T: UITableViewCell>(after indexPath: IndexPath) -> T? {
        if let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row+1, section: 0)) {
            return cell as? T
        }
        return nil
    }
    
    private func dismissDatePicker() {
        tableView.firstVisibleCell(of: DatePickerCell.self)?.hideDatePicker()
    }
    
    private func dismissKeyboard() {
        for cell in tableView.allVisibleCells(of: LabeledTextFieldCell.self) {
            cell.labeledTextField.textField.resignFirstResponder()
        }
    }
    
}



extension String {
    
    public var intValue: Int? {
        return Int(self)
    }
    
}


extension UITableView {
    
    public func firstVisibleCell<T: UITableViewCell>(of type: T.Type) -> T? {
        let cell = visibleCells.first { cell -> Bool in
            return cell is T
        } as? T
        return cell
    }
    
    public func allVisibleCells<T: UITableViewCell>(of type: T.Type) -> [T] {
        let cells = visibleCells.filter { cell -> Bool in
            return cell is T
        } as? [T]
        return cells ?? []
    }
    
}

