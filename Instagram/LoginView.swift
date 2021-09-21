//
//  LoginView.swift
//  Instagram
//
//  Created by Maxim Soroka on 16.04.2021.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
        
    var body: some View {
        VStack {
            Image("Instagram.logo")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.white)
                .frame(maxWidth: screen.width - 100)
            
            VStack(spacing: 16) {
                AuthenticationTextField(image: Image(systemName: "envelope"), placeHolder: "Email", errorMessage: viewModel.emailValidation.message, show: viewModel.email.isEmpty, text: $viewModel.email)
                
                AuthenticationTextField(image: Image(systemName: "lock"), placeHolder: "Password", errorMessage: viewModel.passwordValidation.message, isSecureFiled: true, show: viewModel.password.isEmpty, text: $viewModel.password)
                
                Button(action: {}) {
                    Text("Forgot Password?")
                        .foregroundColor(.white)
                        .font(Font.callout.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Button(action: {
                    viewModel.send(action: .login)
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.purple.opacity(0.9))
                .cornerRadius(22)
                .padding(.top)
                .opacity(!viewModel.canLogin ? 0.7 : 1)
                .disabled(!viewModel.canLogin)
                
            }
            .frame(width: screen.width - 30)
            
            Spacer()
        }
        .animation(.easeIn)
        
    }
}
