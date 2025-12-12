//
//  UserModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

// MARK: - 用户资料数据模型
struct UserProfile {
    let id = UUID()
    let username: String
    let bio: String
    let level: Int
    let totalPoints: Int
    let successfulPredictions: Int
    let accuracyRate: Int
    let achievements: [Achievement]
    let recentPredictions: [UserPrediction]
    
    var initials: String {
        String(username.prefix(1))
    }
    
    static let sampleUser = UserProfile(
        username: "时尚探索者",
        bio: "追寻下一个时尚风潮，享受发现的乐趣",
        level: 3,
        totalPoints: 1240,
        successfulPredictions: 8,
        accuracyRate: 73,
        achievements: Achievement.sampleAchievements,
        recentPredictions: []
    )
}

// MARK: - 成就数据模型
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let isUnlocked: Bool
    
    static let sampleAchievements = [
        Achievement(
            title: "新手上路",
            icon: "star.fill",
            color: .blue,
            description: "完成第一次预测",
            isUnlocked: true
        ),
        Achievement(
            title: "趋势捕手",
            icon: "target",
            color: .green,
            description: "成功预测5次趋势",
            isUnlocked: true
        ),
        Achievement(
            title: "时尚达人",
            icon: "crown.fill",
            color: .purple,
            description: "连续预测成功10次",
            isUnlocked: false
        ),
        Achievement(
            title: "先知先觉",
            icon: "eye.fill",
            color: .orange,
            description: "提前2周预测成功趋势",
            isUnlocked: true
        ),
        Achievement(
            title: "社区贡献",
            icon: "heart.fill",
            color: .red,
            description: "提名趋势被采纳5次",
            isUnlocked: false
        ),
        Achievement(
            title: "雷达专家",
            icon: "radar",
            color: .cyan,
            description: "使用应用超过30天",
            isUnlocked: false
        )
    ]
}

// MARK: - 编辑资料视图
struct EditProfileView: View {
    @Binding var user: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.appBackground()
                
                Form {
                    Section("基本信息") {
                        TextField("用户名", text: $username)
                            .foregroundColor(.white)
                        TextField("个人简介", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    Section("偏好设置") {
                        Text("风格偏好设置")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonBlue)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            username = user.username
            bio = user.bio
        }
    }
    
    private func saveChanges() {
        // 这里保存更改，实际项目中会更新真实数据
    }
}
