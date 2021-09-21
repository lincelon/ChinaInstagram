//
//  NotificationCell.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct NotificationCell: View {
    let notify: Notify
    
    var body: some View {
        HStack {
            Image("Data7")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            Text("mx.srk")
                .font(Font.callout.weight(.semibold))

            content(for: notify.type)
        }
        .padding(8)
    }
    
    
    @ViewBuilder
    private func content(for notificationType: Notify.NotificationType) -> some View {
        switch notificationType {
        case .like:
            Text("liked one of your posts")
                .font(.callout)
            Spacer()
            Image("Data6")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
        case .comment:
            Text("")
        case .follow:
            Text("started following you")
            Spacer()
            Button(action: {}) {
                Text("Follow")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .font(Font.callout.weight(.semibold))
            }
        }
    }
}

struct NotificationCell_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCell(notify: .init(type: .follow))
    }
}
