//
//  HomeView.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 25/02/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView{
            VStack {
                NavigationLink(destination: {
                    CommonPhotoVideoView(viewModel: ImageClassificationViewModel())
                }, label: {
                    Text("Image Classification/Image Labelling")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(.blue)
                        .cornerRadius(10)
                })
                .navigationTitle("Home")
                
                NavigationLink(destination: {
                    CommonPhotoVideoView(viewModel: FlowerIdentificationViewModel())
                }, label: {
                    Text("Custom Image Labelling/Flower Identification")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(.blue)
                        .cornerRadius(10)
                })
                .navigationTitle("Home")
                
                NavigationLink(destination: {
                    CommonPhotoVideoView(viewModel: FaceDetectorViewModel())
                }, label: {
                    Text("Face Detection")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(.blue)
                        .cornerRadius(10)
                })
                .navigationTitle("Home")
                
                NavigationLink(destination: {
                    FaceRecognitionView(viewModel: FaceRecognitionViewModel())
                }, label: {
                    Text("Face Recognition")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(.blue)
                        .cornerRadius(10)
                })
                .navigationTitle("Home")
                
                NavigationLink(destination: {
                    CommonPhotoVideoView(viewModel: ObjectDetectionViewModel())
                }, label: {
                    Text("Object detection with classification")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(.blue)
                        .cornerRadius(10)
                })
                .navigationTitle("Home")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
