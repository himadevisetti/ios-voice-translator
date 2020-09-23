
import UIKit
import MaterialComponents

class ChatTableViewCell: UITableViewCell {
  
  @IBOutlet weak var selfCardView: MDCCard!
  @IBOutlet weak var selfText: UILabel!
  @IBOutlet weak var botCardView: MDCCard!
  @IBOutlet weak var botResponseText: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    selfCardView?.cornerRadius = selfCardView.frame.height/2
    botCardView?.cornerRadius = botCardView.frame.height/2
    
    selfCardView?.backgroundColor = UIColor.init(red: 188/255, green: 206/255, blue: 255/255, alpha: 1)
    botCardView?.backgroundColor = UIColor.init(red: 138/255, green: 156/255, blue: 255/255, alpha: 1)
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
