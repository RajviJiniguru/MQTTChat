

import UIKit

class twoTypingCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.masksToBounds = true
            imageViewThumb.layer.cornerRadius = imageViewThumb.frame.size.height / 2
            imageViewThumb.clipsToBounds = true
        }
    }
    @IBOutlet weak var btnImage2: UIButton!
    @IBOutlet weak var imageViewThumb2: UIImageView! {
        didSet {
            imageViewThumb2.layer.masksToBounds = true
            imageViewThumb2.layer.cornerRadius = imageViewThumb2.frame.size.height / 2
            imageViewThumb2.clipsToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(dictData : NSDictionary)
    {
        if (dictData[kprofile_picture_url] as? String) != ""
        {
            let imageUrlString = (dictData[kprofile_picture_url] as? String)!
            
            self.imageViewThumb.isHidden = false
            self.btnImage.isHidden = true
            
            self.imageViewThumb2.isHidden = false
            self.btnImage2.isHidden = true
            
            if let imgUrl = URL(string : imageUrlString)
            {
                print("imageUrlString== \(imgUrl)")
                //self.imageViewThumb.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                
                let url2 = URL(string: "http://carers-online.transaction.partners/uploads/profile_small.jpg")
              //  self.imageViewThumb2.sd_setImage(with: url2, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                
            }
        }
        else
        {
            self.imageViewThumb.isHidden = true
            self.btnImage.isHidden = false
            let str = dictData[kName] as? String
            self.btnImage.layer.masksToBounds = true
            self.btnImage.layer.cornerRadius = self.btnImage.frame.size.height / 2
            self.btnImage.clipsToBounds = true
            self.btnImage.setTitle(String((str?.first)!), for: .normal)
            
        }
    }
}
