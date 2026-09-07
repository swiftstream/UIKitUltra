#if os(macOS) || os(iOS) || os(tvOS)
//
//  ImagePicker.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 01.11.2020.
//
#if !os(macOS)
import Foundation
import UIKit

@MainActor
private var _picker: ImagePicker?

@available(*, deprecated, renamed: "MediaPicker")
public typealias VideoPicker = MediaPicker

@available(*, deprecated, renamed: "MediaPicker")
public typealias ImagePicker = MediaPicker

@MainActor
open class MediaPicker: NSObject {
    private lazy var picker = UIImagePickerController()
    
    private var cancelHandler = {}
    private var imageHandler: (UIImage, ImageInfo) -> () = { _,_ in }
    private var infoHandler: ([UIImagePickerController.InfoKey : Any]) -> () = { _ in }
    private var videoHandler: (URL) -> () = { _ in }
    private var sourceType: UIImagePickerController.SourceType = .camera
    
    public struct ImageInfo {
        let original: [UIImagePickerController.InfoKey : Any]
        let mediaType: String
        let originalImage: UIImage
        let editedImage: UIImage?
        let cropRect: CGRect?
        let mediaURL: URL?
        let mediaMetadata: NSDictionary
        
        init? (_ info: [UIImagePickerController.InfoKey : Any]) {
            original = info
            guard let mediaType = info[.mediaType] as? String else { return nil }
            guard let originalImage = info[.originalImage] as? UIImage else { return nil }
            self.mediaType = mediaType
            self.originalImage = originalImage
            self.cropRect = info[.cropRect] as? CGRect
            self.mediaURL = info[.mediaURL] as? URL
            self.mediaMetadata = (info[.mediaMetadata] as? NSDictionary) ?? [:]
            editedImage = info[.editedImage] as? UIImage
        }
    }
    
    @discardableResult
    public override init() {
        super.init()
        picker.delegate = self
    }
    
    @discardableResult
    public func configure(_ handler: (UIImagePickerController) -> Void) -> Self {
        handler(picker)
        return self
    }
    
    /// Use e.g. `public.image` or `public.movie`
    @discardableResult
    public func mediaTypes(_ types: String...) -> Self {
        mediaTypes(types)
    }
    
    /// Use e.g. `public.image` or `public.movie`
    @discardableResult
    public func mediaTypes(_ types: [String]) -> Self {
        picker.mediaTypes = types
        return self
    }
    
    // default value is 10 minutes.
    @discardableResult
    public func videoMaximumDuration(_ value: TimeInterval) -> Self {
        picker.videoMaximumDuration = value
        return self
    }
    
    /// default value is UIImagePickerControllerQualityTypeMedium.
    /// If the cameraDevice does not support the videoQuality, it will use the default value.
    @discardableResult
    public func videoQuality(_ value: UIImagePickerController.QualityType) -> Self {
        picker.videoQuality = value
        return self
    }
    
    /// Can be used to specify the transcoding quality for videos (via a AVAssetExportPreset* string).
    /// If the value is nil (the default) then the transcodeQuality is determined by `videoQuality` instead.
    /// Not valid if the source type is `UIImagePickerControllerSourceTypeCamera`
    @discardableResult
    public func videoExportPreset(_ value: String) -> Self {
        if #available(iOS 11.0, *) {
            picker.videoExportPreset = value
        }
        return self
    }
    
    /// set to NO to hide all standard camera UI. default is YES
    @discardableResult
    public func showsCameraControls(_ value: Bool) -> Self {
        picker.showsCameraControls = value
        return self
    }
    
    /// set a view to overlay the preview view.
    @discardableResult
    public func cameraOverlayView(_ value: UIView?) -> Self {
        picker.cameraOverlayView = value
        return self
    }
    
    /// set the transform of the preview view.
    @discardableResult
    public func cameraViewTransform(_ value: CGAffineTransform) -> Self {
        picker.cameraViewTransform = value
        return self
    }
    
    /// default is UIImagePickerControllerCameraCaptureModePhoto
    @discardableResult
    public func cameraCaptureMode(_ value: UIImagePickerController.CameraCaptureMode) -> Self {
        picker.cameraCaptureMode = value
        return self
    }
    
    /// default is UIImagePickerControllerCameraDeviceRear
    @discardableResult
    public func cameraDevice(_ value: UIImagePickerController.CameraDevice) -> Self {
        picker.cameraDevice = value
        return self
    }
    
    /// default is UIImagePickerControllerCameraFlashModeAuto.
    @discardableResult
    public func cameraFlashMode(_ value: UIImagePickerController.CameraFlashMode) -> Self {
        picker.cameraFlashMode = value
        return self
    }
    
    @discardableResult
    public func allowsEditing(_ value: Bool = true) -> Self {
        picker.allowsEditing = value
        return self
    }
    
    @discardableResult
    public func transitionStyle(_ style: UIModalTransitionStyle) -> Self {
        picker.modalTransitionStyle = style
        return self
    }
    
    @discardableResult
    public func sourceType(_ type: UIImagePickerController.SourceType) -> Self {
        picker.sourceType = type
        return self
    }
    
    @discardableResult
    public func onCancel(_ handler: @escaping () -> Void) -> Self {
        cancelHandler = handler
        return self
    }
    
    @available(*, deprecated, renamed: "onImage")
    @discardableResult
    public func onDone(_ handler: @escaping (UIImage, ImageInfo) -> Void) -> Self {
        onImage(handler)
    }
    
    @available(*, deprecated, renamed: "onImage")
    @discardableResult
    public func onDone(_ handler: @escaping (UIImage) -> Void) -> Self {
        onImage(handler)
    }
    
    @discardableResult
    public func onImage(_ handler: @escaping (UIImage, ImageInfo) -> Void) -> Self {
        imageHandler = handler
        return self
    }
    
    @discardableResult
    public func onImage(_ handler: @escaping (UIImage) -> Void) -> Self {
        imageHandler = { image, info in
            handler(image)
        }
        return self
    }
    
    @discardableResult
    public func onInfo(_ handler: @escaping ([UIImagePickerController.InfoKey : Any]) -> Void) -> Self {
        infoHandler = handler
        return self
    }
    
    @discardableResult
    public func onVideo(_ handler: @escaping (URL) -> Void) -> Self {
        videoHandler = handler
        return self
    }
    
    @discardableResult
    public func present(in vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> Self {
        _picker = self
        vc.present(picker, animated: animated, completion: completion)
        return self
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        infoHandler(info)
        if let mediaType = info[.mediaType] as? String,
           ["movie", "video"].contains { mediaType.contains($0) },
           let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            videoHandler(videoURL)
        }
        if let imageInfo = ImageInfo(info) {
            imageHandler(imageInfo.editedImage ?? imageInfo.originalImage, imageInfo)
        }
        picker.dismiss(animated: true)
        _picker = nil
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelHandler()
        picker.dismiss(animated: true)
        _picker = nil
    }
}

extension ImagePicker: UINavigationControllerDelegate {}
#endif
#endif
