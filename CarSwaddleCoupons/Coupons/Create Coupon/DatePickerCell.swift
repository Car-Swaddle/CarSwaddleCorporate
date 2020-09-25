//
//  DatePickerCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/22/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import UIKit

let monthDayYearTimeDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy, h:mm a"
    dateFormatter.amSymbol = NSLocalizedString("am", comment: "am")
    dateFormatter.pmSymbol = NSLocalizedString("pm", comment: "pm")
    return dateFormatter
}()

private let doneTitle = NSLocalizedString("Done", comment: "")
private let selectTitle = NSLocalizedString("Select", comment: "")

class DatePickerCell: UITableViewCell, NibRegisterable {
    
    public var didChangeDate: ( _ date: Date) -> Void = { _ in }
    public var willUpdateHeight: () -> Void = {}
    public var didUpdateHeight: () -> Void = {}
    public var didShowDatePicker: () -> Void = {}
    
    public var selectedDate: Date = Date.distantFuture {
        didSet {
            updateDatePickerWithSelectedDate()
            didChangeDate(datePicker.date)
        }
    }
    
    public func hideDatePicker() {
        isShowingDatePicker = false
    }
    
    public func showDatePicker() {
        isShowingDatePicker = true
    }

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var topContainerView: UIView!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    @IBOutlet private var heightViewHeightConstraint: NSLayoutConstraint!
        
    private var isShowingDatePicker: Bool = false {
        didSet {
            updateUIForIsShowingDatePicker()
            if isShowingDatePicker {
                didShowDatePicker()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedDate = Date()
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
        updateUIForIsShowingDatePicker()
        
        clipsToBounds = true
        datePicker.minimumDate = Date()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        datePicker.minimumDate = Date()
        if selectedDate < Date() {
            datePicker.date = selectedDate
        }
    }
    
    private func updateDatePickerWithSelectedDate() {
        dateLabel.text = monthDayYearTimeDateFormatter.string(from: selectedDate)
    }
    
    private func updateUIForIsShowingDatePicker() {
        willUpdateHeight()
        heightViewHeightConstraint.constant = isShowingDatePicker ? topContainerView.frame.height + datePicker.frame.height : topContainerView.frame.height
        didUpdateHeight()
        
        UIView.animate(withDuration: 0.25) {
            self.datePicker.alpha = self.isShowingDatePicker ? 1.0 : 0.0
        }
        
        UIView.performWithoutAnimation {
            self.doneButton.setTitle(self.buttonTitle, for: .normal)
            self.doneButton.layoutIfNeeded()
        }
    }
    
    private var buttonTitle: String {
        return isShowingDatePicker ? doneTitle : selectTitle
    }
    
    @IBAction private func didTapDone() {
       isShowingDatePicker = !isShowingDatePicker
    }
    
    @objc private func dateDidChange() {
        selectedDate = datePicker.date
    }
    
}

