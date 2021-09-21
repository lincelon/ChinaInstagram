//
//  UploadPostView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct UploadPostView: View {
    @StateObject private var viewModel =  UploadPostViewModel()
    @Binding private var tabIndex: Int
    
    init(tabIndex: Binding<Int>) {
        self._tabIndex = tabIndex
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                
                if let uiImage = viewModel.selectedImage {
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(12)
                        
                        TextArea(text: $viewModel.caption, placeholder: "Enter your caption")
                    }
                    .frame(height: 100)
                    .padding()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.send(action: .cancel)
                            }
                        }) {
                            Text("Cancel")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .border(Color.black, width: 1)
                        }
                        .background(Color.white)
                        .cornerRadius(4)
                        
                        Button(action: {
                            withAnimation {
                                viewModel.send(action: .share)
                            }
                        }) {
                            Text("Share")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.blue)
                        .cornerRadius(4)
                    }
                    .font(Font.callout.weight(.medium))
                    .frame(maxWidth: screen.width - 30)
            
                } else {
                    NewPhotoButton {
                        viewModel.imagePickerPresented.toggle()
                    }
                    .foregroundColor(.black)
                    .sheet(isPresented: $viewModel.imagePickerPresented) {
                        ImagePicker(image: $viewModel.selectedImage)
                    }
                }
            }
        
            
            Spacer()
        }
        .onReceive(viewModel.$tabIndex, perform: { tabIndex in
            self.tabIndex = tabIndex
        })
    }
}

struct NewPhotoButton: View {
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Circle()
                .stroke(lineWidth: 3)
                .frame(width: 130, height: 130)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                        
                        Text("Photo")
                            .font(Font.title2.weight(.semibold))
                    }
                )
        }
    }
}

struct UploadPostView_Previews: PreviewProvider {
    static var previews: some View {
        UploadPostView(tabIndex: .constant(0))
    }
}
