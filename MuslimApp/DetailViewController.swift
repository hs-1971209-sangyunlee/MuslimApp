import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var restaurant : Restaurant?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = restaurant?.title
    }
    
    @IBAction func createPostTouch(_ sender: UIButton) {
        
    }
}
