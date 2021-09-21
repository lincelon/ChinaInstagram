//
//  CommentsView.swift
//  Instagram
//
//  Created by Maxim Soroka on 02.05.2021.
//

import SwiftUI

struct CommentsView: View {
    @StateObject private var viewModel: CommentsViewModel
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: CommentsViewModel(post: post))
    }
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.comments) { comment in
                CommentView(comment: comment)
                    .transition(AnyTransition.slide.animation(.spring()))
                    .environmentObject(viewModel)
            }
        }
        .padding(.top, safeAreaInsets?.top)
        .animation(.spring())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            CommentTextField(text: $viewModel.text)
                .environmentObject(viewModel)
                .padding(.bottom, keyboardHandler.keyboardHeight)
                .animation(.default),
            alignment: .bottomTrailing
        )
        .ignoresSafeArea(.keyboard)
    }
}

struct CommentTextField: View {
    @EnvironmentObject private var viewModel: CommentsViewModel
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.isTyping {
                HStack {
                    TextField("Write a comment", text: $text)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.send(action: .sendComment)
                            viewModel.send(action: .endTyping)
                        }
                    }) {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.send(action: .endTyping)
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    .rotationEffect(.init(degrees: viewModel.isTyping ? 0 : 90))
                }
                .padding()
                
            } else {
                Text("Add A Comment")
                    .font(Font.callout)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Image(systemName: "pencil")
                    .font(.title3)
                    .padding(8)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            
        }
        .frame(maxWidth: viewModel.isTyping ? screen.width : 200)
        .padding(.vertical, 4)
        .background(viewModel.isTyping ? Color.white : Color.black)
        .cornerRadius(22)
        .padding()
        .padding(.bottom)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 7)
        .onTapGesture {
            withAnimation(.spring()) {
                viewModel.send(action: .startTyping)
            }
        }
    }
}
