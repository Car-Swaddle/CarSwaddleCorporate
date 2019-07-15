//
//  RequestAuthorityViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/24/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData

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
        
        confirmButton.addTarget(self, action: #selector(RequestAuthorityViewController.didTapConfirm), for: .touchUpInside)
        adjuster.positionActionButton()
        
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
    
    @objc private func didTapConfirm() {
        guard let selectedIndex = selectedRow() else { return }
        confirmButton.isLoading = true
        let authorityString = authorityNames[selectedIndex].rawValue
        store.privateContext { [weak self] privateContext in
            self?.authorityNetwork.createAuthorityRequest(authority: authorityString, in: privateContext) { authorityRequestID, error in
                DispatchQueue.main.async {
                    self?.confirmButton.isLoading = false
                    if error == nil {
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        
                    }
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
    
}

extension RequestAuthorityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateButtonEnabledness()
    }
    
}

