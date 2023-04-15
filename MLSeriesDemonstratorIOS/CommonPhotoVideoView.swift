//
//  CommonPhotoVideoView.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 27/02/23.
//

import SwiftUI

struct CommonPhotoVideoView: View {
    
    @StateObject var viewModel: BaseViewModel
    
    @State var type: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSheet = false
    @State private var selectedUiImage: UIImage = UIImage()
        
    var body: some View {
        GeometryReader { geo in
            VStack {
                if let previewImage = viewModel.viewfinderImage {
                    previewImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height * 0.8)
                } else if let uiImage = selectedUiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height * 0.8)
                }
                Text(viewModel.resultText)
                    .multilineTextAlignment(.center)
                    .frame(width: geo.size.width, height: geo.size.height * 0.1)
                HStack {
                    Text(" Select a Photo ")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 10)
                        .background(.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            showSheet = true
                        }
                    Button
                    {
                        Task {
                            await viewModel.camera.start()
                        }
                    } label: {
                        Text("Camera Preview")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .padding(.horizontal, 10)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }.frame(width: geo.size.width, height: geo.size.height * 0.1)
            }
        }.sheet(isPresented: $showSheet) {
            // Pick an image from the photo library:
            ImagePicker(sourceType: .photoLibrary) { selectedImage in
                viewModel.didSelectImage(newImage: selectedImage) { finalImage in
                    selectedUiImage = finalImage
                }
            }
        }
    }
}

struct CommonPhotoVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CommonPhotoVideoView(viewModel: FaceDetectorViewModel())
    }
}
