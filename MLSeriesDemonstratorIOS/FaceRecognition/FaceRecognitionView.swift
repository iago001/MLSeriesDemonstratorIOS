//
//  FaceRecognitionView.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 01/04/23.
//

import SwiftUI

struct FaceRecognitionView: View {
    
    @StateObject var viewModel: FaceRecognitionViewModel
    
    @State var type: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSheet = false
    @State private var name: String = ""
    @State private var showPickerSheet = false
    @State private var selectedUiImage: UIImage = UIImage()
    
    @Environment(\.scenePhase) var scenePhase
        
    var body: some View {
        GeometryReader { geo in
            VStack {
                if let uiImage = selectedUiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height * 0.8)
                }
                HStack {
                    Text("Select a Photo")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 10)
                        .background(.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            showPickerSheet = true
                        }
                    Text(" Add a face ")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 10)
                        .background(.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            showSheet = true
                        }
                }.frame(width: geo.size.width, height: geo.size.height * 0.1)
            }
        }.sheet(isPresented: $showSheet) {
            GeometryReader { geo in
                VStack {
                    if let croppedImage = viewModel.croppedFaceImage {
                        croppedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height * 0.8)
                    } else {
                        Image(uiImage: UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height * 0.8)
                    }
                    TextField(
                        "Enter name",
                        text: $name,
                        onCommit: {
                            viewModel.registerFace(name)
                            showSheet = false
                            viewModel.isSheet(open: false)
                        }
                    )
                    .frame(width: geo.size.width, height: geo.size.height * 0.2)
                }
            }
            .onAppear {
                viewModel.isSheet(open: true)
                viewModel.copyFaceVector()
            }
        }.sheet(isPresented: $showPickerSheet) {
            // Pick an image from the photo library:
            ImagePicker(sourceType: .photoLibrary) { selectedImage in
                viewModel.didSelectImage(newImage: selectedImage) { finalImage in
                    selectedUiImage = finalImage
                }
            }
        }
    }
}

struct FaceRecognitionViewPreview: PreviewProvider {
    static var previews: some View {
        FaceRecognitionView(viewModel: FaceRecognitionViewModel())
    }
}
