//
//  UIUtilities.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 26/02/23.
//

import AVFoundation
import CoreVideo
import MLKit
import UIKit

public class UIUtilities {
    
    public static func imageOrientation(
        fromDevicePosition devicePosition: AVCaptureDevice.Position = .back
      ) -> UIImage.Orientation {
        var deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .faceDown || deviceOrientation == .faceUp
          || deviceOrientation
            == .unknown
        {
          deviceOrientation = currentUIOrientation()
        }
        switch deviceOrientation {
        case .portrait:
          return devicePosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
          return devicePosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
          return devicePosition == .front ? .rightMirrored : .left
        case .landscapeRight:
          return devicePosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
          return .up
        @unknown default:
          fatalError()
        }
      }
    
    private static func currentUIOrientation() -> UIDeviceOrientation {
      let deviceOrientation = { () -> UIDeviceOrientation in
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
          return .landscapeRight
        case .landscapeRight:
          return .landscapeLeft
        case .portraitUpsideDown:
          return .portraitUpsideDown
        case .portrait, .unknown:
          return .portrait
        @unknown default:
          fatalError()
        }
      }
      guard Thread.isMainThread else {
        var currentOrientation: UIDeviceOrientation = .portrait
        DispatchQueue.main.sync {
          currentOrientation = deviceOrientation()
        }
        return currentOrientation
      }
      return deviceOrientation()
    }
}
