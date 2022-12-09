//
//  QRScannerFrameConfig.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 07/05/22.
//

#if os(iOS)
import Foundation
import UIKit

public struct QRScannerConfiguration {
    public var title: String
    public var hint: String?
    public var invalidQRCodeAlertTitle: String
    public var invalidQRCodeAlertActionTitle: String
    public var uploadFromPhotosTitle: String
    public var cameraImage: UIImage?
    public var flashOnImage: UIImage?
    public var galleryImage: UIImage?
    public var length: CGFloat
    public var color: UIColor
    public var radius: CGFloat
    public var thickness: CGFloat
    public var readQRFromPhotos: Bool
    public var cancelButtonTitle: String
    public var cancelButtonTintColor: UIColor?
    
    public init(title: String = "SCAN_QR_CODE".localized,
                hint: String = "ALIGN_QR_CODE_WITHIN_FRAME_TO_SCAN".localized,
                uploadFromPhotosTitle: String = "UPLOAD_FROM_PHOTOS".localized,
                invalidQRCodeAlertTitle: String = "INVALID_QR_CODE".localized,
                invalidQRCodeAlertActionTitle: String = "OK".localized,
                cameraImage: UIImage? = nil,
                flashOnImage: UIImage? = nil,
                length: CGFloat = 20.0,
                color: UIColor = .green,
                radius: CGFloat = 10.0,
                thickness: CGFloat = 5.0,
                readQRFromPhotos: Bool = true,
                cancelButtonTitle: String = "CANCEL".localized,
                cancelButtonTintColor: UIColor? = nil) {
        self.title = title
        self.hint = hint
        self.uploadFromPhotosTitle = uploadFromPhotosTitle
        self.invalidQRCodeAlertTitle = invalidQRCodeAlertTitle
        self.invalidQRCodeAlertActionTitle = invalidQRCodeAlertActionTitle
        self.cameraImage = cameraImage
        self.flashOnImage = flashOnImage
        self.length = length
        self.color = .themeYellow
        self.radius = radius
        self.thickness = thickness
        self.readQRFromPhotos = readQRFromPhotos
        self.cancelButtonTitle = cancelButtonTitle
        self.cancelButtonTintColor = .themeButtonFontColor
    }
}

extension QRScannerConfiguration {
    public static var `default`: QRScannerConfiguration {
        QRScannerConfiguration(title: "SCAN_QR_CODE".localized,
                               hint: "ALIGN_QR_CODE_WITHIN_FRAME_TO_SCAN".localized,
                               uploadFromPhotosTitle: "UPLOAD_FROM_PHOTOS".localized,
                               invalidQRCodeAlertTitle: "INVALID_QR_CODE".localized,
                               invalidQRCodeAlertActionTitle: "OK".localized,
                               cameraImage: nil,
                               flashOnImage: nil,
                               length: 20.0,
                               color: .green,
                               radius: 10.0,
                               thickness: 5.0,
                               readQRFromPhotos: true,
                               cancelButtonTitle: "CANCEL".localized,
                               cancelButtonTintColor: nil)
    }
}
#endif
