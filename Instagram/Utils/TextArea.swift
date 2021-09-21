//
//  TextArea.swift
//  Instagram
//
//  Created by Maxim Soroka on 26.04.2021.
//

import SwiftUI

struct TextArea: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .padding(8)
                    .foregroundColor(Color(UIColor.placeholderText))
            }
            
            TextEditor(text: $text)
                .padding(4)
        }
        .font(.body)
    }
}

