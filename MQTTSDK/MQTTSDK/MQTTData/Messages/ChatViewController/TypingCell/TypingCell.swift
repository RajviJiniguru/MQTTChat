
import UIKit

class TypingCell:  UITableViewHeaderFooterView {

    //  ====view wave ======
    @IBOutlet weak var viewWave: UIView!
    public var displayLink: CADisplayLink?
    private var startTime: CFAbsoluteTime?
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!

    // ====view 1======
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.masksToBounds = true
            imageViewThumb.layer.cornerRadius = imageViewThumb.frame.size.height / 2
            imageViewThumb.clipsToBounds = true
        }
    }
    
    // ====view 2======
    @IBOutlet weak var v2btnImage1: UIButton!
    @IBOutlet weak var v2imageViewThumb1: UIImageView! {
        didSet {
            v2imageViewThumb1.layer.masksToBounds = true
            v2imageViewThumb1.layer.cornerRadius = v2imageViewThumb1.frame.size.height / 2
            v2imageViewThumb1.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var v2btnImage2: UIButton!
    @IBOutlet weak var v2imageViewThumb2: UIImageView! {
        didSet {
            v2imageViewThumb2.layer.masksToBounds = true
            v2imageViewThumb2.layer.cornerRadius = v2imageViewThumb2.frame.size.height / 2
            v2imageViewThumb2.clipsToBounds = true
        }
    }
    
    // ====view 3======
    @IBOutlet weak var v3btnImage1: UIButton!
    @IBOutlet weak var v3imageViewThumb1: UIImageView! {
        didSet {
            v3imageViewThumb1.layer.masksToBounds = true
            v3imageViewThumb1.layer.cornerRadius = v3imageViewThumb1.frame.size.height / 2
            v3imageViewThumb1.clipsToBounds = true
        }
    }
    @IBOutlet weak var v3btnImage2: UIButton!
    @IBOutlet weak var v3imageViewThumb2: UIImageView! {
        didSet {
            v3imageViewThumb2.layer.masksToBounds = true
            v3imageViewThumb2.layer.cornerRadius = v3imageViewThumb2.frame.size.height / 2
            v3imageViewThumb2.clipsToBounds = true
        }
    }
    @IBOutlet weak var v3btnImage3: UIButton!
    @IBOutlet weak var v3imageViewThumb3: UIImageView! {
        didSet {
            v3imageViewThumb3.layer.masksToBounds = true
            v3imageViewThumb3.layer.cornerRadius = v3imageViewThumb3.frame.size.height / 2
            v3imageViewThumb3.clipsToBounds = true
        }
    }
    
    // ====view 4======
    @IBOutlet weak var v4btnImage1: UIButton!
    @IBOutlet weak var v4imageViewThumb1: UIImageView! {
        didSet {
            v4imageViewThumb1.layer.masksToBounds = true
            v4imageViewThumb1.layer.cornerRadius = v4imageViewThumb1.frame.size.height / 2
            v4imageViewThumb1.clipsToBounds = true
        }
    }
    @IBOutlet weak var v4btnImage2: UIButton!
    @IBOutlet weak var v4imageViewThumb2: UIImageView! {
        didSet {
            v4imageViewThumb2.layer.masksToBounds = true
            v4imageViewThumb2.layer.cornerRadius = v4imageViewThumb2.frame.size.height / 2
            v4imageViewThumb2.clipsToBounds = true
        }
    }
    @IBOutlet weak var v4btnImage3: UIButton!
    @IBOutlet weak var v4imageViewThumb3: UIImageView! {
        didSet {
            v4imageViewThumb3.layer.masksToBounds = true
            v4imageViewThumb3.layer.cornerRadius = v4imageViewThumb3.frame.size.height / 2
            v4imageViewThumb3.clipsToBounds = true
        }
    }
    @IBOutlet weak var v4btnImage4: UIButton!
    @IBOutlet weak var v4imageViewThumb4: UIImageView! {
        didSet {
            v4imageViewThumb4.layer.masksToBounds = true
            v4imageViewThumb4.layer.cornerRadius = v4imageViewThumb4.frame.size.height / 2
            v4imageViewThumb4.clipsToBounds = true
        }
    }
    
    
    // ====view 5======
    @IBOutlet weak var v5btnImage1: UIButton!
    @IBOutlet weak var v5imageViewThumb1: UIImageView! {
        didSet {
            v5imageViewThumb1.layer.masksToBounds = true
            v5imageViewThumb1.layer.cornerRadius = v5imageViewThumb1.frame.size.height / 2
            v5imageViewThumb1.clipsToBounds = true
        }
    }
    @IBOutlet weak var v5btnImage2: UIButton!
    @IBOutlet weak var v5imageViewThumb2: UIImageView! {
        didSet {
            v5imageViewThumb2.layer.masksToBounds = true
            v5imageViewThumb2.layer.cornerRadius = v5imageViewThumb2.frame.size.height / 2
            v5imageViewThumb2.clipsToBounds = true
        }
    }
    @IBOutlet weak var v5btnImage3: UIButton!
    @IBOutlet weak var v5imageViewThumb3: UIImageView! {
        didSet {
            v5imageViewThumb3.layer.masksToBounds = true
            v5imageViewThumb3.layer.cornerRadius = v5imageViewThumb3.frame.size.height / 2
            v5imageViewThumb3.clipsToBounds = true
        }
    }
    @IBOutlet weak var v5btnImage4: UIButton!
    @IBOutlet weak var v5imageViewThumb4: UIImageView! {
        didSet {
            v5imageViewThumb4.layer.masksToBounds = true
            v5imageViewThumb4.layer.cornerRadius = v5imageViewThumb4.frame.size.height / 2
            v5imageViewThumb4.clipsToBounds = true
        }
    }
    @IBOutlet weak var v5btnImage5: UIButton!
    @IBOutlet weak var v5imageViewThumb5: UIImageView! {
        didSet {
            v5imageViewThumb5.layer.masksToBounds = true
            v5imageViewThumb5.layer.cornerRadius = v5imageViewThumb5.frame.size.height / 2
            v5imageViewThumb5.clipsToBounds = true
        }
    }
    //=========
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    /// The `CAShapeLayer` that will contain the animated path
    
    private let shapeLayer: CAShapeLayer = {
        let _layer = CAShapeLayer()
        _layer.strokeColor = UIColor.black.cgColor
        _layer.fillColor = UIColor.clear.cgColor
        _layer.lineWidth = 2
        return _layer
    }()
    
    /// Start the display link
    
    private func startDisplayLink() {
        startTime = CFAbsoluteTimeGetCurrent()
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink!.add(to: RunLoop.current, forMode: .common)
    }
    
    /// Stop the display link
    
    public func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Handle the display link timer.
    ///
    /// - Parameter displayLink: The display link.
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime!
        shapeLayer.path = wave(at: elapsed).cgPath
    }
    
    /// Create the wave at a given elapsed time.
    ///
    /// You should customize this as you see fit.
    ///
    /// - Parameter elapsed: How many seconds have elapsed.
    /// - Returns: The `UIBezierPath` for a particular point of time.
    
    private func wave(at elapsed: Double) -> UIBezierPath {
        let centerY = viewWave.bounds.height / 2
        //   let amplitude = CGFloat(50) - abs(fmod(CGFloat(elapsed), 3) - 1.5) * 40
        let amplitude = CGFloat(50) - abs(fmod(CGFloat(elapsed),0.5) - 1.5) * 40
        //  let amplitude = CGFloat(50) - abs(fmod(CGFloat(1),0.5) - 1.5) * 40
        func f(_ x: Int) -> CGFloat {
            return sin(((CGFloat(x) / viewWave.bounds.width) + CGFloat(elapsed)) * 4 * .pi) * amplitude + centerY
        }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: f(0)))
        for x in stride(from: 0, to: Int(viewWave.bounds.width + 9), by: 10) {
            path.addLine(to: CGPoint(x: CGFloat(x), y: f(x)))
        }
        return path
    }
    
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    func configureCell(dictData : NSDictionary, countArray : Int)
    {
        viewWave.layer.addSublayer(shapeLayer)
        self.startDisplayLink()
        
        if (dictData[kprofile_picture_url] as? String) != ""
        {
            let imageUrlString = (dictData[kprofile_picture_url] as? String)!
            
            self.imageViewThumb.isHidden = false
            self.btnImage.isHidden = true
            
            if countArray == 1{
                
                view1.isHidden = false
                view2.isHidden = true
                view3.isHidden = true
                view4.isHidden = true
                view5.isHidden = true

                if let imgUrl = URL(string : imageUrlString)
                {
                    print("imageUrlString== \(imgUrl)")
               //     self.imageViewThumb.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                }
            }
            else if countArray == 2{
                
                view1.isHidden = true
                view2.isHidden = false
                view3.isHidden = true
                view4.isHidden = true
                view5.isHidden = true

                if let imgUrl = URL(string : imageUrlString)
                {
                    self.v2imageViewThumb1.isHidden = false
                    self.v2btnImage1.isHidden = true
                    
                    self.v2imageViewThumb2.isHidden = false
                    self.v2btnImage2.isHidden = true
                    
                    let imgUrl2 = URL(string : (dictData["profile_picture_url_2"] as? String)!)
                    
//                    self.v2imageViewThumb1.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v2imageViewThumb2.sd_setImage(with: imgUrl2, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                }
            }
            else if countArray == 3{
                
                view1.isHidden = true
                view2.isHidden = true
                view3.isHidden = false
                view4.isHidden = true
                view5.isHidden = true

                if let imgUrl = URL(string : imageUrlString)
                {
                    self.v3imageViewThumb1.isHidden = false
                    self.v3btnImage1.isHidden = true
                    
                    self.v3imageViewThumb2.isHidden = false
                    self.v3btnImage2.isHidden = true
                    
                    
                    self.v3imageViewThumb3.isHidden = false
                    self.v3btnImage3.isHidden = true
                   
            
                    let imgUrl2 = URL(string : (dictData["profile_picture_url_2"] as? String)!)
                    let imgUrl3 = URL(string : (dictData["profile_picture_url_3"] as? String)!)
                    
//                    self.v3imageViewThumb1.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v3imageViewThumb2.sd_setImage(with: imgUrl2, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v3imageViewThumb3.sd_setImage(with: imgUrl3, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                }
            }
            else if countArray == 4{
                
                view1.isHidden = true
                view2.isHidden = true
                view3.isHidden = true
                view4.isHidden = false
                view5.isHidden = true

                if let imgUrl = URL(string : imageUrlString)
                {
                    self.v4imageViewThumb1.isHidden = false
                    self.v4btnImage1.isHidden = true
                    
                    self.v4imageViewThumb2.isHidden = false
                    self.v4btnImage2.isHidden = true
                    
                    
                    self.v4imageViewThumb3.isHidden = false
                    self.v4btnImage3.isHidden = true
                    
                    self.v4imageViewThumb4.isHidden = false
                    self.v4btnImage4.isHidden = true
                    
                    let imgUrl2 = URL(string : (dictData["profile_picture_url_2"] as? String)!)
                    let imgUrl3 = URL(string : (dictData["profile_picture_url_3"] as? String)!)
                    let imgUrl4 = URL(string : (dictData["profile_picture_url_4"] as? String)!)

//                    self.v4imageViewThumb1.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v4imageViewThumb2.sd_setImage(with: imgUrl2, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v4imageViewThumb3.sd_setImage(with: imgUrl3, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v4imageViewThumb4.sd_setImage(with: imgUrl4, placeholderImage: UIImage(named: ImageName.PlaceholderImage))

                }
            }
            else if countArray == 5{
                
                view1.isHidden = true
                view2.isHidden = true
                view3.isHidden = true
                view4.isHidden = true
                view5.isHidden = false
                
                if let imgUrl = URL(string : imageUrlString)
                {
                    self.v5imageViewThumb1.isHidden = false
                    self.v5btnImage1.isHidden = true
                    
                    self.v5imageViewThumb2.isHidden = false
                    self.v5btnImage2.isHidden = true
                    
                    self.v5imageViewThumb3.isHidden = false
                    self.v5btnImage3.isHidden = true
                    
                    self.v5imageViewThumb4.isHidden = false
                    self.v5btnImage4.isHidden = true
                    
                    let imgUrl2 = URL(string : (dictData["profile_picture_url_2"] as? String)!)
                    let imgUrl3 = URL(string : (dictData["profile_picture_url_3"] as? String)!)
                    let imgUrl4 = URL(string : (dictData["profile_picture_url_4"] as? String)!)
                    let imgUrl5 = URL(string : (dictData["profile_picture_url_5"] as? String)!)

//                    self.v5imageViewThumb1.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v5imageViewThumb2.sd_setImage(with: imgUrl2, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v5imageViewThumb3.sd_setImage(with: imgUrl3, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
//                    self.v5imageViewThumb4.sd_setImage(with: imgUrl4, placeholderImage: UIImage(named: ImageName.PlaceholderImage))
                    
                }
            }
        }
        else
        {
            self.imageViewThumb.isHidden = true
            self.btnImage.isHidden = true
            let str = dictData[kName] as? String
            self.btnImage.layer.masksToBounds = true
            self.btnImage.layer.cornerRadius = self.btnImage.frame.size.height / 2
            self.btnImage.clipsToBounds = true
            self.btnImage.setTitle(String((str?.first)!), for: .normal)
            
        }
    }
}
