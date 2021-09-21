//
//  LoginView.swift
//  Instagram
//
//  Created by Maxim Soroka on 16.04.2021.
//

import SwiftUI

struct LoginRegistarionView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State private var showRegisterView = false
    @State private var applyOpacity = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ZStack(alignment: .bottom) {
                
                if showRegisterView {
                    RegistrationView(showRegisterView: $showRegisterView, applyOpacity: $applyOpacity)
                        .transition(.offset(x: screen.width, y: screen.height / 3))
                    noAccountContent
                }
                
                if !showRegisterView {
                    LoginView()
                        .opacity(applyOpacity ? 0 : 1)
                        .transition(.offset(x: -screen.width))
                    haveAccountContent
                }
            }
            .padding(.top, 64)
        }
        .environmentObject(viewModel)
    }
    
    var haveAccountContent: some View {
        HStack {
            Text("Don`t have an account?")
                .opacity(0.9)
            
            Button(action: {
                withAnimation {
                    viewModel.email = ""
                    viewModel.password = ""
                    
                    applyOpacity = true
                }
                
                withAnimation(Animation.easeInOut.speed(0.8)) {
                    showRegisterView = true
                }
            }) {
                Text("Register")
                    .fontWeight(.semibold)
            }
        }
        .font(.callout)
        .foregroundColor(.white)
        .opacity(applyOpacity ? 0 : 1)
    }
    
    var noAccountContent: some View {
        HStack {
            Text("Already have an account?")
                .opacity(0.9)
            
            Button(action: {
                withAnimation {
                    viewModel.email = ""
                    viewModel.password = ""
                    viewModel.username = ""
                    viewModel.fullName = ""
                    
                    applyOpacity = false
                }
                
                withAnimation(Animation.easeInOut.speed(0.7)) {
                    showRegisterView = false
                }
            }) {
                Text("Sign In")
                    .fontWeight(.semibold)
            }
        }
        .font(.callout)
        .foregroundColor(.white)
        .opacity(applyOpacity ? 1 : 0)
        
    }
}

struct LoginRegistarionView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegistarionView()
    }
}
