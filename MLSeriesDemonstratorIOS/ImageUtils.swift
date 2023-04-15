//
//  ImageUtils.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 25/02/23.
//

import AVFoundation
import MLKit
import SwiftUI
import UIKit

class ImageUtils {
    
    public static func drawFramesWithLabel(frames: Array<FrameWithLabel>, uiImage: UIImage) -> UIImage {
        
        // Parameters
        let margin: CGFloat = 10
        let color = CGColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let fontSize: CGFloat = 32
        
        var bmp = uiImage
        autoreleasepool {
            let rendererFormat = UIGraphicsImageRendererFormat()
            rendererFormat.scale = 1
            let renderer = UIGraphicsImageRenderer(size : uiImage.size, format: rendererFormat)
            bmp = renderer.image { ctx in
                uiImage.draw(in: CGRect(x:0, y:0, width: uiImage.size.width, height: uiImage.size.height))
                ctx.cgContext.setLineWidth(2)
                
                let textTransform = CGAffineTransform(scaleX: 1.0, y: -1.0)
                ctx.cgContext.textMatrix = textTransform
                
                for frame in frames {
                    ctx.cgContext.setStrokeColor(UIColor.yellow.cgColor)
                    ctx.cgContext.addRect(frame.frame)
                    ctx.cgContext.drawPath(using: .stroke)
                    
                    let fontName = "Verdana" as CFString
                    let font = CTFontCreateWithName(fontName, fontSize, nil)
                    
                    let attributes: [NSAttributedString.Key : Any] = [.font: font, .foregroundColor: color]
                    
                    // Text
                    let attributedString = NSAttributedString(string: frame.label,
                                                              attributes: attributes)
                    
                    // Render
                    let line = CTLineCreateWithAttributedString(attributedString)
                    let stringRect = CTLineGetImageBounds(line, ctx.cgContext)
                    
                    ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
                    ctx.cgContext.setFillColor(UIColor.red.cgColor)
                    ctx.cgContext.setTextDrawingMode(.fillStroke)
                    ctx.cgContext.textPosition = CGPoint(x: frame.frame.minX + margin, y: frame.frame.minY + margin + stringRect.height)
                    CTLineDraw(line, ctx.cgContext)
                }
            }
        }
        return bmp
    }
    
    public static func bufferToUIImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        return convert(cmage: ciimage)
    }
    
    // Convert CIImage to UIImage
    // dont use UIImage(ciImage: ciImage) as cgImage will be nil
    public static func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    public static func resizeWithCoreGraphics(cgImage: CGImage, newSize: CGSize) -> CGImage? {
        guard let colorSpace = cgImage.colorSpace else { return nil }

        let width = Int(newSize.width)
        let height = Int(newSize.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(cgImage, in: rect)

        return context.makeImage()
    }
    
    public static func resizeWithBiLinearInterpolation(cgImage: CGImage, newSize: CGSize) -> CGImage? {
        guard let colorSpace = cgImage.colorSpace else { return nil }

        let width = Int(newSize.width)
        let height = Int(newSize.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(cgImage, in: rect)

        return context.makeImage()
    }
    
}

extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        return ciContext.createCGImage(self, from: self.extent)
    }
}

struct FrameWithLabel {
    let frame: CGRect
    let label: String
}

// MARK: - Data
extension Data {
  /// Creates a new buffer by copying the buffer pointer of the given array.
  ///
  /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
  ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
  ///     data from the resulting buffer has undefined behavior.
  /// - Parameter array: An array with elements of type `T`.
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }

  func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
    var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
    _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
    return array
  }
}

// MARK: - Constants
private enum Constant {
  static let maxRGBValue: Float32 = 255.0
}
