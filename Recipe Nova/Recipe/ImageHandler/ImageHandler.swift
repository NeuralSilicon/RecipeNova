

import UIKit

class ImageHandler: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
    @IBOutlet var collectionView:UICollectionView!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var image = ImageStruct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.view.backgroundColor = UI.MC.toColor()
        self.collectionView.backgroundColor = .clear
        
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        self.collectionView.isPagingEnabled=true
        
        ///handle switching between images in collectionview
        if image.images.count != 0 && image.SelectedImage != -1{
            DispatchQueue.main.async{
                self.collectionView.scrollToItem(at: IndexPath(row: self.image.SelectedImage, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    
    deinit {
        self.image.images = []
        self.collectionView.removeFromSuperview()
    }
    

        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.image.images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCVC", for: indexPath) as? ImageCVC
    
        let image = UIImage(data: self.image.images[indexPath.row])?.Resize(targetSize: CGSize(width: 400, height: 400))
        cell?.Image.image = image
            
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
        
}



class ImageCVC: UICollectionViewCell,UIScrollViewDelegate{
    @IBOutlet var ScrollView: UIScrollView!{
        didSet{
            self.ScrollView.delegate=self
            self.ScrollView.maximumZoomScale = 10.0
            self.ScrollView.minimumZoomScale = 1.0
            self.ScrollView.layer.cornerRadius = 25
            self.ScrollView.showsVerticalScrollIndicator = false
            self.ScrollView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet var Image: UIImageView!{
        didSet{
            self.Image.layer.cornerRadius = 25
            self.Image.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.Image.image = nil
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.Image
    }
}
