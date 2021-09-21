//
//  RegistrationView.swift
//  Instagram
//
//  Created by Maxim Soroka on 16.04.2021.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @Binding var showRegisterView: Bool
    @Binding var applyOpacity: Bool

    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                if let uiImage = viewModel.selectedImage  {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .onTapGesture {
                            showImagePicker = true
                        }
                    
                } else {
                    NewPhotoButton {
                        showImagePicker = true
                    }
                    .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
           
            VStack(spacing: 16) {
                AuthenticationTextField(image: Image(systemName: "envelope"), placeHolder: "Email", errorMessage: viewModel.emailValidation.message, show: viewModel.email.isEmpty, text: $viewModel.email)
                    
                
                AuthenticationTextField(image: Image(systemName: "person"), placeHolder: "Username", errorMessage: viewModel.usernameValidation.message, show: viewModel.username.isEmpty, text: $viewModel.username)
                    
                AuthenticationTextField(image: Image(systemName: "person"), placeHolder: "Full Name", errorMessage: viewModel.fullNameValidation.message, show: viewModel.fullName.isEmpty, text: $viewModel.fullName)
                
                AuthenticationTextField(image: Image(systemName: "lock"), placeHolder: "Password", errorMessage: viewModel.passwordValidation.message, isSecureFiled: true, show: viewModel.password.isEmpty, text: $viewModel.password)
                
                Button(action: {
                    viewModel.send(action: .signup)
                }) {
                    Text("Sign up")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.purple.opacity(0.9))
                .cornerRadius(22)
                .padding(.top)
                .opacity(!viewModel.canSignup ? 0.7 : 1)
                .disabled(!viewModel.canSignup)
                
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .frame(width: screen.width - 30)
            
            Spacer()
        }
        .opacity(applyOpacity ? 1 : 0)
        .animation(.easeIn)

    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RegistrationView(showRegisterView: .constant(true), applyOpacity: .constant(true))
        }
    }
}
