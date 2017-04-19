//
//  ExploreViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ExploreViewController: UIViewController {
    
    
    
    @IBOutlet weak var peoplePostTableView: UITableView!{
        didSet{
            peoplePostTableView.delegate = self
            peoplePostTableView.dataSource = self
            
            peoplePostTableView.register(PeoplePostViewCell.cellNib, forCellReuseIdentifier: PeoplePostViewCell.cellIdentifier)
        }
    }
    
    
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 510.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PeoplePostViewCell.cellIdentifier) as? PeoplePostViewCell
            else { return UITableViewCell() }
        
        
        
        
        
        
        
        return cell
    }
    
}
