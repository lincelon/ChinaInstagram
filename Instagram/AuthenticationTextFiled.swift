//
//  AuthenticationTextFiled.swift
//  Instagram
//
//  Created by Maxim Soroka on 16.04.2021.
//

import SwiftUI

struct AuthenticationTextField: View {
    let image: Image
    let placeHolder: String
    let errorMessage: String
    var isSecureFiled = false
    var show: Bool
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                image
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 25)
                
                VStack {
                    if isSecureFiled {
                        SecureField("", text: $text)
                        
                    } else { TextField("", text: $text) }
                }
                .foregroundColor(.white)
                .placeHolder(
                    Text(placeHolder)
                        .foregroundColor(.white)
                        .font(Font.callout.weight(.semibold)),
                    show: show)
            }
            .opacity(0.85)
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(Color.red)
                    .font(Font.footnote.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .transition(AnyTransition.opacity.animation(.easeIn))
            }
            
        }
    }
}

struct PlaceHolder<T: View>: ViewModifier {
    var placeHolder: T
    var show: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if show { placeHolder }
            content
        }
    }
}

extension View {
    func placeHolder<T:View>(_ holder: T, show: Bool) -> some View {
        self.modifier(PlaceHolder(placeHolder:holder, show: show))
    }
}


struct AuthenticationTextFiled_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AuthenticationTextField(image: Image(systemName: "envelope"), placeHolder: "Email", errorMessage: "An error occured", show: true, text: .constant(""))
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom))
    }
}
