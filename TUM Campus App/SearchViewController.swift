//
//  SearchViewController.swift
//  TUM Campus App
//
//  Created by Mathias Quintero on 10/28/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UITextFieldDelegate, TumDataReceiver, ImageDownloadSubscriber {
    
    var delegate: DetailViewDelegate?
    
    var elements = [DataElement]()
    
    func updateImageView() {
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        searchTextField.becomeFirstResponder()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = 102
    }
    
    override func viewWillDisappear(animated: Bool) {
        searchTextField.resignFirstResponder()
    }
    
    func receiveData(data: [DataElement]) {
        elements = data
        for element in elements {
            if let downloader = element as? ImageDownloader {
                downloader.subscribeToImage(self)
            }
        }
        tableView.reloadData()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string != " " {
            for element in elements {
                if let downloader = element as? ImageDownloader {
                    downloader.clearSubscribers()
                }
            }
            let replaced = NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string)
            if  replaced != "" {
                delegate?.dataManager().search(self, query: replaced)
            } else {
                elements = []
                tableView.reloadData()
            }
        }
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(elements[indexPath.row].getCellIdentifier()) as? CardTableViewCell ?? CardTableViewCell()
        cell.setElement(elements[indexPath.row])
        return cell
    }
    

}
