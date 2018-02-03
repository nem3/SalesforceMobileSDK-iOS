//
//  ViewController.swift
//  SmartSyncExplorerSwift
//
//  Created by Nicholas McDonald on 1/16/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import CoreGraphics
import SalesforceSDKCore.SFDefaultUserManagementViewController
import SalesforceSDKCore.SFUserAccountManager
import SalesforceSDKCore.SFSecurityLockout
import SalesforceSDKCore.SalesforceSDKManager
import SmartStore.SFSmartStoreInspectorViewController
import SmartSyncExplorerCommon

class RootViewController: UniversalViewController {
    
    fileprivate var isSearching = false
    fileprivate var searchText:String = ""
    fileprivate let tableView = UITableView(frame: .zero, style: .plain)
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var contacts: [ContactRecord] = []

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearPopoversForPasscode),
                                               name: NSNotification.Name(rawValue: kSFPasscodeFlowWillBegin),
                                               object: nil)
        
        self.title = "SmartSync Explorer"
        
        guard let settings = UIImage(named: "setting")?.withRenderingMode(.alwaysOriginal),
            let sync = UIImage(named: "sync")?.withRenderingMode(.alwaysOriginal),
            let add = UIImage(named: "plusButton")?.withRenderingMode(.alwaysOriginal) else { return }
        let settingsButton = UIBarButtonItem(image: settings, style: .plain, target: self, action: #selector(showAdditionalActions(_:)))
        let syncButton = UIBarButtonItem(image: sync, style: .plain, target: self, action: #selector(didPressSyncUpDown))
        let addButton = UIBarButtonItem(image: add, style: .plain, target: self, action: #selector(didPressAddContact))
        self.navigationItem.rightBarButtonItems = [settingsButton, syncButton, addButton]
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = true
        self.definesPresentationContext = true
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorColor = UIColor.appSeparator
        self.tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        let safe = self.view.safeAreaLayoutGuide
        self.commonConstraints.append(contentsOf: [self.tableView.leftAnchor.constraint(equalTo: safe.leftAnchor),
                                                   self.tableView.rightAnchor.constraint(equalTo: safe.rightAnchor),
                                                   self.tableView.topAnchor.constraint(equalTo: safe.topAnchor),
                                                   self.tableView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)])
        
        self.refreshList()
    }

    @objc func showAdditionalActions(_ sender: UIBarButtonItem) {
        let table = AdditionalActionsViewController()
        table.modalPresentationStyle = .popover
        table.preferredContentSize = CGSize(width: 200.0, height: 88.0)
        table.onLogoutSelected = {
            table.dismiss(animated: true, completion: {
                self.showLogoutActionSheet()
            })
        }
        table.onSwitchUserSelected = {
            table.dismiss(animated: true, completion: {
                self.showSwitchUserController()
            })
        }
        
        self.present(table, animated: true, completion: nil)
        
        let popover = table.popoverPresentationController
        popover?.barButtonItem = sender
    }
    
    @objc func didPressAddContact() {
        let detailVC = ContactDetailViewController(nil) {
            self.refreshList()
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func didPressSyncUpDown() {
        let alert = self.showAlert("Syncing", message: "Syncing with Salesforce")
        ContactStore.instance.syncUp { (syncState) in
            DispatchQueue.main.async {
                guard let state = syncState else {return}
                if state.isDone() {
                    alert.message = "Sync Complete!"
                    alert.addAction(self.dismissAlertAction(alert))
                } else if state.hasFailed() {
                    alert.message = "Sync failed!"
                    alert.addAction(self.dismissAlertAction(alert))
                }
                self.refreshList()
            }
        }
    }
    
    @objc func clearPopoversForPasscode() {
        SFSDKLogger.log(type(of: self), level: .debug, message: "Passcode screen loading. Clearing popovers")
        
        // TODO
    }
    
    fileprivate func showAlert(_ title:String, message:String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        return alert
    }
    
    fileprivate func dismissAlertAction(_ forController:UIAlertController) -> UIAlertAction {
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            forController.dismiss(animated: true, completion: nil)
        }
        return action
    }
    
    fileprivate func refreshList() {
        ContactStore.instance.syncDown { (syncState) in
            let storeRows = ContactStore.instance.getRecords()
            DispatchQueue.main.async {
                self.contacts = storeRows
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func showLogoutActionSheet() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out", preferredStyle: .alert)
        let logout = UIAlertAction(title: "Logout", style: .destructive) { (action) in
            SFUserAccountManager.sharedInstance().logout()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(logout)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showSwitchUserController() {
        let controller = SFDefaultUserManagementViewController { (userManagementAction) in
            self.dismiss(animated: true, completion: nil)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RootViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.ContactTableCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contacts[indexPath.row]
        let detail = ContactDetailViewController(contact) {
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        self.navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        let contact = self.contacts[indexPath.row]
        if contact.locallyDeleted == true {
            cell.backgroundColor = UIColor.contactCellDeletedBackground
        } else {
            cell.backgroundColor = UIColor.clear
        }
        cell.showRefresh = contact.locallyUpdated
        cell.title = ContactHelper.nameStringFromContact(contact)
        cell.subtitle = ContactHelper.titleStringFromContact(contact)
        cell.leftImage = ContactHelper.initialsImage(ContactHelper.colorFromContact(contact), initials: ContactHelper.initialsStringFromContact(contact))
        return cell
    }
}

