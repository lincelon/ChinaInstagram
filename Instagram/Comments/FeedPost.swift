//
//  FeedPost.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

let screen = UIScreen.main.bounds
let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets

struct FeedPost: View {
    @StateObject private var viewModel: FeedPostViewModel
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: FeedPostViewModel(post: post))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let username = viewModel.postOwner?.username,
                let profileImage = viewModel.postOwner?.profileImageURL {
                    
                    WebImage(url: URL(string: profileImage))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 36, height: 36)
                    
                    Text(username)
                        .font(Font.callout.weight(.semibold))
                }
            }
            .padding([.leading, .bottom], 8)
            
            ZStack {
                WebImage(url: URL(string:viewModel.post.image))
                    .resizable()
                    .scaledToFit()
                    .onTapGesture(count: 2) {
                        if !viewModel.isLiked {
                            withAnimation {
                                viewModel.send(action: .like)
                                showHeart()
                            }
                            
                        } else {
                            showHeart()
                        }
                    }
                    .zIndex(0)
                
                VStack {
                    if viewModel.applyAnimation {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                }
                .zIndex(1)
                .transition(AnyTransition.opacity.animation(.easeInOut))
            }

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        viewModel.isLiked
                            ? viewModel.send(action: .unlike)
                            : viewModel.send(action: .like)
                        
                        viewModel.scaleHeart = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            viewModel.scaleHeart = false
                        }
                    }
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isLiked ? .red : .black)
                }
                .scaleEffect(viewModel.scaleHeart ? 1.4 : 1)
                
                
                ForEach(["bubble.right", "paperplane"], id: \.self) { systemName in
                    Button(action: {
                        
                    }) {
                        Image(systemName: systemName)
                            .foregroundColor(.black)
                    }
                }
                
            }
            .font(.title2)
            .padding(4)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    if viewModel.post.likes > 0 {
                    
                        Text("\(viewModel.post.likes) ") +
                            Text(viewModel.post.likes == 1 ? "like" : "likes") 
                    }
                }
                .font(Font.callout.weight(.semibold))
                
                if let postOwner = viewModel.postOwner, let caption = viewModel.post.caption {
                    if !caption.isEmpty {
                        Text(postOwner.username)
                            .fontWeight(.semibold) +
                        Text(" " + caption)
                    }
                }
                NavigationLink(destination: CommentsView(post: viewModel.post)) {
                    if viewModel.commentsCount > 0 {
                        Text("Show all comments (\(viewModel.commentsCount))")
                        
                    } else { Text("Add a comment") }
                }
                .font(Font.callout.weight(.medium))
                .foregroundColor(.secondary)
                
                Text("\(viewModel.post.timestamp.dateValue())")
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
            }
            .font(.callout)
            .padding(.horizontal, 8)
            
                
        }
        .frame(width: screen.width)
    }
    
    fileprivate func showHeart() {
        withAnimation {
            viewModel.applyAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                viewModel.applyAnimation = false
            }
        }
    }
}


struct FeedPost_Previews: PreviewProvider {
    static var previews: some View {
        FeedPost(post: Post(id: "a", image: "https://firebasestorage.googleapis.com/v0/b/instagram-97288.appspot.com/o/images_profile%2FE679B3B6-32D9-4026-9D62-A8F8AE4B6563?alt=media&token=cf318b63-87dd-438c-9d09-4b84fb3f84c6", caption: "pop like that", timestamp: Timestamp(date: Date()), likes: 0, ownerID: "s"))
    }
}
