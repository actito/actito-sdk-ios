//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import AVFoundation
import CoreGraphics
import CoreMedia
import MobileCoreServices
import UIKit

public class ActitoCallbackActionHandler: ActitoBaseActionHandler {
    private var theme: ActitoOptions.Theme?

    private var navigationController: UINavigationController!
    private var viewController: ActitoCallbackViewController!
    private var imagePickerController: UIImagePickerController!

    private var imageData: Data?
    private var videoData: Data?

    private var message: String? {
        viewController.message
    }

    private var mediaUrl: String?
    private var mediaMimeType: String?

    internal override init(notification: ActitoNotification, action: ActitoNotification.Action, sourceViewController: UIViewController) {
        super.init(notification: notification, action: action, sourceViewController: sourceViewController)

        if #available(iOS 26, *) {
            viewController = ActitoLiquidGlassCallbackViewController(
                notification: notification,
                onClose: onCloseClicked,
                onSend: onSendClicked
            )
        } else {
            viewController = ActitoLegacyCallbackViewController(
                notification: notification,
                onClose: onCloseClicked,
                onSend: onSendClicked
            )
        }

        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.presentationController?.delegate = self
    }

    internal override func execute() {
        if action.camera, action.keyboard {
            // First get the camera going, then get the message.
            openCamera()
            return
        }

        if action.keyboard {
            openKeyboard()
            return
        }

        if action.camera {
            openCamera()
            return
        }

        // No properties. Just send an empty reply.
        Task {
            await send()
        }
    }

    @objc private func onCloseClicked() {
        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)

        self.dismiss()
    }

    @objc private func onSendClicked() async {
        if let imageData = imageData {
            do {
                let url = try await Actito.shared.uploadNotificationReplyAsset(imageData, contentType: "image/jpeg")

                mediaUrl = url
                mediaMimeType = "image/jpeg"

                await send()
            } catch {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)

                dismiss()
            }
        } else if let videoData = videoData {
            do {
                let url = try await Actito.shared.uploadNotificationReplyAsset(videoData, contentType: "video/quicktime")

                mediaUrl = url
                mediaMimeType = "video/quicktime"

                await send()
            } catch {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)

                dismiss()
            }
        } else if message != nil {
            await send()
        }
    }

    private func openCamera() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil
        else {
            logger.warning("Missing camera, microphone or photo library permissions. Skipping...")
            return
        }

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            logger.warning("Camera is not available. Falling back to photo library.")
            openPhotoLibrary()

            return
        }

        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .authorized:
            presentImagePicker(sourceType: .camera)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentImagePicker(sourceType: .camera)
                    } else {
                        self.openPhotoLibrary()
                    }
                }
            }

        case .denied, .restricted:
            openPhotoLibrary()

        @unknown default:
            logger.warning("Unknown camera authorization status.")
            openPhotoLibrary()
        }
    }

    private func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            logger.warning("Photo library is not available.")
            return
        }

        presentImagePicker(sourceType: .photoLibrary)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType

        if sourceType == .camera {
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.videoMaximumDuration = 10
        }

        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self

        sourceViewController.presentOrPush(imagePickerController)
    }

    private func openKeyboard() {
        viewController.showKeyboardView()

        sourceViewController.presentOrPush(navigationController)
    }

    private func showMedia(_ image: UIImage?) {
        if action.camera, action.keyboard {
            viewController.showMediaWithKeyboardView(image: image)
        } else {
            viewController.showMediaView(image: image)
        }

        sourceViewController.presentOrPush(navigationController)
    }

    private func send() async {
        dismiss()

        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)

            logAction()

            return
        }

        var params = [
            "label": action.label,
            "notificationID": notification.id,
        ]

        if let message = message {
            params["message"] = message
        }

        if let mediaUrl = mediaUrl {
            params["media"] = mediaUrl
        }

        if let mimeType = mediaMimeType {
            params["mimeType"] = mimeType
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { item in
                params[item.name] = item.value
            }
        }

        let data: Data
        do {
            data = try JSONEncoder.actito.encode(params)
        } catch {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
            return
        }

        var request = URLRequest(url: url)
        request.setActitoHeaders()
        request.setMethod("POST", payload: data)

        URLSession.shared.perform(request) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
                }
            }

            self.logAction()
        }
    }

    private func logAction() {
        Task {
            try? await Actito.shared.createNotificationReply(notification: notification, action: action, message: message, media: mediaUrl, mimeType: mediaMimeType)
        }
    }
}

extension ActitoCallbackActionHandler: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if info[.mediaType] as? String == kUTTypeImage as String {
            if let image = info[.editedImage] as? UIImage {
                imageData = image.fixedOrientation()?.jpegData(compressionQuality: 0.9)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage(data: self.imageData!)!
                    self.showMedia(thumbnail)
                }
            }
        } else if info[.mediaType] as? String == kUTTypeVideo as String || info[.mediaType] as? String == kUTTypeMovie as String {
            if let url = info[.mediaURL] as? URL {
                videoData = try? Data(contentsOf: url)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage.renderVideoThumbnail(for: url)
                    self.showMedia(thumbnail)
                }
            }
        }
    }

    public func imagePickerControllerDidCancel(_: UIImagePickerController) {
        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)

        dismiss()
    }
}

extension ActitoCallbackActionHandler: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)

        dismiss()
    }
}

extension ActitoCallbackActionHandler: UINavigationControllerDelegate {}

extension UIImage {
    internal func fixedOrientation() -> UIImage? {
        // No-op if the orientation is already correct
        guard imageOrientation != .up else {
            return copy() as? UIImage
        }

        guard let cgImage = cgImage,
              let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        else {
            return nil
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.

        var transform: CGAffineTransform = .identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi / -2.0)
        default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image.
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        context.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
    }

    internal static func renderVideoThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumnailTime = CMTimeMake(value: 1, timescale: 2)

        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            return UIImage(cgImage: cgThumbImage)
        } catch {
            return nil
        }
    }
}
