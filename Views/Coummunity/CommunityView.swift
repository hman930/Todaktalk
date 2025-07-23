//
//  CommunityView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 4/23/25.
//

import Foundation
import SwiftUI

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: 상단 로고 + 아이콘
                    HStack {
                        Image("todaktok_logo_vertical")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 36)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Image(systemName: "bell")
                            Image(systemName: "line.3.horizontal")
                        }
                        .font(.title3)
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // MARK: 타이틀
                    Text("커뮤니티")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor")) // 진핑크
                        .padding(.horizontal)
                    
                    // MARK: 태그 필터
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(["육아 정보", "건강", "살림", "놀이", "중고거래", "일상"], id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.pink.opacity(0.1))
                                    .foregroundColor(.pink)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: 게시글 리스트
                    VStack(spacing: 16) {
                        CommunityItem(
                            title: "최근에 아이랑 다녀온 키즈카페 추천해요~!",
                            nickname: "미소맘", tag: "산책동", views: 300, likes: 100, comments: 16, timeAgo: "3시간 전")
                        
                        CommunityItem(
                            title: "아이 장난감 너무 비싸네요",
                            nickname: "별빛맘", tag: "잠실동", views: 255, likes: 58, comments: 20, timeAgo: "1시간 전")
                        
                        CommunityItem(
                            title: "아이가 너무 편식하네요. 선배님들 조언 구합니다..",
                            nickname: "진이맘", tag: "거여동", views: 434, likes: 34, comments: 56, timeAgo: "1시간 전")
                        
                        CommunityItem(
                            title: "아기 예방접종 어디서 맞히셨어요?",
                            nickname: "서현맘", tag: "송파동", views: 192, likes: 22, comments: 9, timeAgo: "5시간 전")
                        
                        CommunityItem(
                            title: "중고 장난감 나눔해요! 필요하신 분?",
                            nickname: "하람맘", tag: "수서동", views: 78, likes: 12, comments: 3, timeAgo: "10시간 전")
                        
                        CommunityItem(
                            title: "요즘 키즈카페 중 추천 부탁드려요",
                            nickname: "별하맘", tag: "강남동", views: 320, likes: 44, comments: 18, timeAgo: "2일 전")
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 12)
                }
                .padding(.top)
                .navigationTitle("커뮤니티")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct CommunityItem: View {
    var title: String
    var nickname: String
    var tag: String
    var views: Int
    var likes: Int
    var comments: Int
    var timeAgo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text("\(nickname) | \(tag)")
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text(timeAgo)
                Spacer()
                Text("뷰 \(views) 좋아요 \(likes) 댓글 \(comments)")
            }
            .font(.caption2)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.05), radius: 4, x:2, y:4)
    }
}
