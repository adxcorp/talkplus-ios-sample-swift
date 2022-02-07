//
//  ImagePickerManager.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2022/02/04.
//

import UIKit
import Photos

class ImagePickerManager: NSObject {
    static let shared = ImagePickerManager()
    
    private var completion: ((UIImage?, String?) -> Void)?
    
    public func show(_ viewController: UIViewController, sourceType: UIImagePickerController.SourceType, completion: @escaping ((UIImage?, String?) -> Void)) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            DispatchQueue.main.async { [weak self] in
                if #available(iOS 14.0, *) {
                    if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
                        self?.completion = completion
                        self?.showPicker(viewController, sourceType: sourceType)
                        
                    } else {
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                            if status == .authorized {
                                self?.show(viewController, sourceType: sourceType, completion: completion)
                            }
                        }
                    }
                    
                } else {
                    if PHPhotoLibrary.authorizationStatus() == .authorized {
                        self?.completion = completion
                        self?.showPicker(viewController, sourceType: sourceType)
                        
                    } else {
                        PHPhotoLibrary.requestAuthorization { [weak self] status in
                            if status == .authorized {
                                self?.show(viewController, sourceType: sourceType, completion: completion)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showPicker(_ viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if #available(iOS 11.0, *) {
                if picker.sourceType == .photoLibrary {
                    let imageURL: URL = info[.imageURL] as! URL
                    let imagePath = imageURL.path
                    
                    completion?(image, imagePath)
                    picker.dismiss(animated: true)
                    
                    return
                }
            }
            
            let documentURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let imageURL = documentURLs?.appendingPathComponent("image.jpg")
            let imagePath = imageURL?.path
            
            let imageData = image.jpegData(compressionQuality: 0.8)
            try! imageData?.write(to: imageURL!)
            
            completion?(image, imagePath)
            picker.dismiss(animated: true)
            
        } else {
            completion?(nil, nil)
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
