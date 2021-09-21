//
//  SearchBar.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            TextField("Type text for searching here", text: $text)
                .padding(12)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .overlay(
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 12),
                    alignment: .leading
                )
                .onTapGesture {
                    withAnimation {
                        isEditing = true
                    }
                }
              
                
            if isEditing {
                Button(action: {
                    withAnimation {
                        isEditing = false
                        text = ""
                        
                        UIApplication.shared.endEditing()
                    }
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
                .transition(AnyTransition.offset(x: screen.width).animation(.easeIn))
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Mock text data"), isEditing: .constant(true))
    }
}
