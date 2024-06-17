//
//  HomeViewController.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/14.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backButtonTitle = "뒤로가기"
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonTouch(_ sender: UIButton) {
        guard let testViewController = self.storyboard?.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else { return }
                // UINavigationController를 사용하여 push 방식으로 화면 전환
                self.navigationController?.pushViewController(testViewController, animated: true)
    }
}
