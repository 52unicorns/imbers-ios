import UIKit

class PageContentViewController: UIViewController {
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var labelView: UILabel!
  @IBOutlet weak var descriptionView: UILabel!
  
  var pageIndex : Int = 0
  var titleText : String = ""
  var descriptionText : String = ""
  var imageFile : String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.backgroundImageView.image = UIImage(named: self.imageFile)
    self.labelView.text = self.titleText
    self.descriptionView.text = self.descriptionText
  }
}