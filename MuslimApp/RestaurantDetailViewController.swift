//
//  restaurantDetailViewController.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/18.
//

import UIKit

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var restaurant : Restaurant?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = restaurant?.title
    }
    
}
