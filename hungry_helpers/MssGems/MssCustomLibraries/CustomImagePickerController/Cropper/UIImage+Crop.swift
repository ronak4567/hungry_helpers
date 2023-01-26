

import UIKit


extension UIImage {
    func rotatedImageWithTransform(_ rotation: CGAffineTransform, croppedToRect rect: CGRect) -> UIImage {
        let rotatedImage = rotatedImageWithTransform(rotation)
        
        let scale = rotatedImage.scale
        let cropRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        let croppedImage = rotatedImage.cgImage?.cropping(to: cropRect)
        let image = UIImage(cgImage: croppedImage!, scale: self.scale, orientation: rotatedImage.imageOrientation)
        return image
    }
    
    fileprivate func rotatedImageWithTransform(_ transform: CGAffineTransform) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context?.concatenate(transform)
        context?.translateBy(x: size.width / -2.0, y: size.height / -2.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage!
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
