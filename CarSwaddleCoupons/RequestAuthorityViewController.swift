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
    
    private var authorities: [Authority.Name] = [.createCoupons, .editAuthorities, .readAuthorities, .readMechanics, .editMechanics]
    
    private var authorityNetwork: AuthorityNetwork = AuthorityNetwork(serviceRequest: serviceRequest)
    
    private lazy var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: confirmButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RequestAuthorityCell.self)
        tableView.tableFooterView = UIView()
        
        confirmButton.addTarget(self, action: #selector(RequestAuthorityViewController.didTapConfirm), for: .touchUpInside)
        adjuster.positionActionButton()
    }
    
    @IBAction private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapConfirm() {
        guard let selectedIndex = tableView.indexPathForSelectedRow?.row else { return }
        confirmButton.isLoading = true
        let authorityString = authorities[selectedIndex].rawValue
        store.privateContext { [weak self] privateContext in
            self?.authorityNetwork.createAuthorityRequest(authority: authorityString, in: privateContext) { authorityRequestID, error in
                print("yo")
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
        return authorities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestAuthorityCell = tableView.dequeueCell()
        cell.configure(with: authorities[indexPath.row])
        return cell
    }
    
}

extension RequestAuthorityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

