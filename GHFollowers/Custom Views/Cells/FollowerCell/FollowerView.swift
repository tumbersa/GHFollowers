//
//  FollowerView.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 07.01.2024.
//

import SwiftUI
import Kingfisher

@available(iOS 16.0, *)
struct FollowerView: View {
    
    var follower: Follower
    
    var body: some View {
        VStack {
            KFImage(URL(string: follower.avatarUrl))
                .placeholder({ _ in
                    Image(.avatarPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    
                })
                .resizable()
                .aspectRatio(contentMode: .fit)
            .clipShape(.circle)
            
            Text(follower.login)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }

    }
}

@available(iOS 16.0, *)
#Preview {
    FollowerView(follower: Follower(login: "Gleb K", avatarUrl: ""))
}
