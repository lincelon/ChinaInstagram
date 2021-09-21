//
//  CommentView.swift
//  Instagram
//
//  Created by Maxim Soroka on 02.05.2021.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct CommentView: View {
    @EnvironmentObject private var viewModel: CommentsViewModel
    let comment: Comment
    
    var body: some View {
        VStack(spacing: 0) {
            CommentSkeleton(comment: comment, imageWidth: 35, imageHeight: 35) {
                Button(action: {
                    withAnimation {
                        viewModel.isLiked
                            ? viewModel.send(action: .unlike)
                            : viewModel.send(action: .like)
                    }
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isLiked ? .red : .black)
                        .foregroundColor(.black)
                        .font(.callout)
                        .scaleEffect(viewModel.isLiked ? 1.2 : 1)
                        .padding()
                }
            } text: {
                Text(comment.owner.username)
                    .bold()
                    + Text(" ")
                    + Text(comment.text)
            }
            .font(.callout)
            
            if viewModel.subcomments.count > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.send(action: .showAnswers)
                    }
                }) {
                    HStack {
                        ExDivider(color: .gray, height: 2)
                            .frame(maxWidth: 20)
                        
                        Group {
                            Text(viewModel.showAnswers ? "Hide answers " : "Show answers ")
                            + Text("(\(viewModel.subcomments.count))")
                        }
                        .font(Font.footnote.weight(viewModel.showAnswers ? .medium : .regular))
                        .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.leading, 55)
                }
            }
            
            if viewModel.showAnswers {
                ForEach(viewModel.subcomments) { comment in
                    HStack {
                        Spacer(minLength: 50)
                        Subcomment(comment: comment)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct ExDivider: View {
    let color: Color
    let height: CGFloat
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct Subcomment: View {
    @StateObject var viewModel = SubcommentViewModel()
    let comment: Comment
    
    var body: some View {
        
        CommentSkeleton(comment: comment, imageWidth: 35, imageHeight: 35) {
            Button(action: {
                withAnimation {
                    viewModel.isLiked
                        ? viewModel.send(action: .unlike)
                        : viewModel.send(action: .like)
                }
            }) {
                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isLiked ? .red : .black)
                    .foregroundColor(.black)
                    .font(.callout)
                    .scaleEffect(viewModel.isLiked ? 1.2 : 1)
                    .padding()
            }
        } text: {
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text(comment.owner.username)
                        .bold()
                        + Text(" ")
                        + Text(comment.text)
                }
                .lineLimit(comment.text.count > 50 && !viewModel.showMore ? 3 : nil)
                
                if comment.text.count > 50 {
                    Button(action: {
                        withAnimation {
                            viewModel.showMore.toggle()
                        }
                    }) {
                        Text(viewModel.showMore ? "Show less" : "Show more")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .font(.subheadline)
    }
}

struct CommentSkeleton<ButtonContent: View, TextContent: View >: View  {
    let likeButton: ButtonContent
    let text: TextContent
    let comment: Comment
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    
    init(comment: Comment,
         imageWidth: CGFloat,
         imageHeight: CGFloat,
         @ViewBuilder likeButton: @escaping () -> ButtonContent,
         @ViewBuilder text: @escaping () -> TextContent){
        
        self.comment = comment
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.text = text()
        self.likeButton = likeButton()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 5) {
                WebImage(url: URL(string: comment.owner.profileImageURL))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: imageWidth, height: imageHeight)
                
                VStack(alignment:.leading, spacing: 6) {
                    text
                    
                    HStack {
                        Text("6h")
                        
                        if comment.likes > 0 {
                            Text("Likes: \(comment.likes)")
                        }
                        
                        Button(action: {}) {
                            Text("Ответить")
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    
                }
                
                Spacer(minLength: 15)
                
                likeButton
            }
        }
        .padding()
    }
}

//struct CommentView_Previews: PreviewProvider {
//    static let comment = Comment(id: "", timestamp: Timestamp(date: Date()), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!", likes: 0,
//                                 owner: User(id: "", username: "mx.srk", fullname: "Maxim Soroka", email: "", profileImageURL: "https://firebasestorage.googleapis.com/v0/b/instagram-97288.appspot.com/o/images_profile%2FE679B3B6-32D9-4026-9D62-A8F8AE4B6563?alt=media&token=cf318b63-87dd-438c-9d09-4b84fb3f84c6" ),
//                                 postOwnerID: "",
//                                 subcomments: [])
//
//    static var previews: some View {
//        let subcomments = (0...2).map { _ in comment }
//        CommentView(comment: Comment(id: "", timestamp: Timestamp(date: Date()), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", likes: 0,
//                                     owner: User(id: "", username: "mx.srk", fullname: "Maxim Soroka", email: "", profileImageURL: "https://firebasestorage.googleapis.com/v0/b/instagram-97288.appspot.com/o/images_profile%2FE679B3B6-32D9-4026-9D62-A8F8AE4B6563?alt=media&token=cf318b63-87dd-438c-9d09-4b84fb3f84c6" ),
//                                     postOwnerID: "",
//                                     subcomments: subcomments))
//            .environmentObject(CommentsViewModel())
//    }
//}
