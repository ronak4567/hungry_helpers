/** This is custom made class which initialize the default image picker with third party cropper.
 
 Cropper used
 URL :- https://github.com/sprint84/PhotoCropEditor
 
 */
import UIKit
import AVFoundation

protocol CustomImagePickerProtocol {
    func didFinishPickingImage(image:UIImage)
    func didCancelPickingImage()
}

class CustomImagePicker: NSObject {
    
    var viewController:UIViewController?
    var delegate:CustomImagePickerProtocol!
    
    
    /**
     This function will present the custom image picker.
     */
    
    func openImagePicker(controller:UIViewController, source: UIView) {
        self.viewController = controller
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraBtnTitle = MSSLocalizedKeys.sharedInstance.localizedTextFor(key:MSSLocalizedKeys.CustomImagePickerText.openCamera.rawValue)
        
        let galleryBtnTitle = MSSLocalizedKeys.sharedInstance.localizedTextFor(key:MSSLocalizedKeys.CustomImagePickerText.openGallery.rawValue)
        
        let cameraBtn = UIAlertAction(title:cameraBtnTitle , style: .default) { (action) in
            
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                self.openCamera()
            }
            else if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
                CustomAlertController.sharedInstance.showAlert(subTitle: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.GeneralText.cameraPermission.rawValue), type: .warning)
            }
            else if AVCaptureDevice.authorizationStatus(for: .video) ==  .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    if granted {
                        self.openCamera()
                    }
                })
            }
        }
        
        let galleryBtn = UIAlertAction(title:galleryBtnTitle , style: .default) { (action) in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.viewController?.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancelBtn = UIAlertAction(title:MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.GeneralText.cancel.rawValue) , style: .cancel) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cameraBtn)
        alertController.addAction(galleryBtn)
        alertController.addAction(cancelBtn)
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = source
            presenter.sourceRect = source.bounds
        }
        
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.viewController?.present(imagePicker, animated: true, completion: nil)
    }
}

extension CustomImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = (info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage) else { return }
        
        self.viewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let controller = CropViewController()
        controller.delegate = self
        controller.image = pickedImage
        controller.keepAspectRatio = true
        controller.cropAspectRatio =  1
        
        self.viewController?.navigationController?.pushViewController(controller, animated: true)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        self.viewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let controller = CropViewController()
        controller.delegate = self
        controller.image = pickedImage
        controller.keepAspectRatio = true
        controller.cropAspectRatio =  1
        
        self.viewController?.navigationController?.pushViewController(controller, animated: true)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CustomImagePicker: CropViewControllerDelegate {
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        delegate.didFinishPickingImage(image: image)
        
        controller.navigationController?.popViewController(animated: true)
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        delegate.didCancelPickingImage()
        controller.navigationController?.popViewController(animated: true)
    }
}
