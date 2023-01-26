

import UIKit

public protocol CropViewControllerDelegate: class {
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect)
    func cropViewControllerDidCancel(_ controller: CropViewController)
}

open class CropViewController: UIViewController {
    open weak var delegate: CropViewControllerDelegate?
    open var image: UIImage? {
        didSet {
            cropView?.image = image
        }
    }
    open var keepAspectRatio = false {
        didSet {
            cropView?.keepAspectRatio = keepAspectRatio
        }
    }
    open var cropAspectRatio: CGFloat = 0.0 {
        didSet {
            cropView?.cropAspectRatio = cropAspectRatio
        }
    }
    open var cropRect = CGRect.zero {
        didSet {
            adjustCropRect()
        }
    }
    open var imageCropRect = CGRect.zero {
        didSet {
            cropView?.imageCropRect = imageCropRect
        }
    }
    open var toolbarHidden = true
    open var rotationEnabled = true {
        didSet {
            cropView?.rotationGestureRecognizer.isEnabled = rotationEnabled
        }
    }
    open var rotationTransform: CGAffineTransform {
        return cropView!.rotation
    }
    open var zoomedCropRect: CGRect {
        return cropView!.zoomedCropRect()
    }

    fileprivate var cropView: CropView?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    fileprivate func initialize() {
        rotationEnabled = true
    }
    
    open override func loadView() {
        let contentView = UIView()
        contentView.autoresizingMask = .flexibleWidth
        contentView.backgroundColor = UIColor.black
        view = contentView
        
        // Add CropView
        cropView = CropView(frame: contentView.bounds)
        contentView.addSubview(cropView!)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.toolbar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CropViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CropViewController.done(_:)))
        
        
        navigationController?.isToolbarHidden = toolbarHidden
        
        cropView?.image = image
        cropView?.rotationGestureRecognizer.isEnabled = rotationEnabled
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cropAspectRatio != 0 {
            cropView?.cropAspectRatio = cropAspectRatio
        }
        
        if !cropRect.equalTo(CGRect.zero) {
            adjustCropRect()
        }
        
        if !imageCropRect.equalTo(CGRect.zero) {
            cropView?.imageCropRect = imageCropRect
        }
        
        cropView?.keepAspectRatio = keepAspectRatio
    }
    
    open func resetCropRect() {
        cropView?.resetCropRect()
    }
    
    open func resetCropRectAnimated(_ animated: Bool) {
        cropView?.resetCropRectAnimated(animated)
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        delegate?.cropViewControllerDidCancel(self)
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        if let image = cropView?.croppedImage {
            guard let rotation = cropView?.rotation else {
                return
            }
            guard let rect = cropView?.zoomedCropRect() else {
                return
            }
            delegate?.cropViewController(self, didFinishCroppingImage: image, transform: rotation, cropRect: rect)
        }
    }

    // MARK: - Private methods
    fileprivate func adjustCropRect() {
        imageCropRect = CGRect.zero
        
        guard var cropViewCropRect = cropView?.cropRect else {
            return
        }
        cropViewCropRect.origin.x += cropRect.origin.x
        cropViewCropRect.origin.y += cropRect.origin.y
        
        let minWidth = min(cropViewCropRect.maxX - cropViewCropRect.minX, cropRect.width)
        let minHeight = min(cropViewCropRect.maxY - cropViewCropRect.minY, cropRect.height)
        let size = CGSize(width: minWidth, height: minHeight)
        cropViewCropRect.size = size
        cropView?.cropRect = cropViewCropRect
    }
    
    

}
