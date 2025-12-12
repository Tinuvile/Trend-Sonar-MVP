//
//  ProfileView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct ProfileView: View {
    @State private var user = UserProfile.sampleUser
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 用户头像和基本信息
                    profileHeader
                    
                    // 统计数据
                    statsSection
                    
                    // 成就勋章
                    achievementsSection
                    
                    // 我的预测
                    myPredictionsSection
                    
                    // 设置选项
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("我的")
            .navigationBarItems(trailing: 
                Button("编辑") {
                    showingEditProfile = true
                }
            )
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: $user)
            }
        }
    }
    
    // 个人资料头部
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // 头像
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(user.initials)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(user.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("Lv.\(user.level) 时尚探索者")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(Color(.systemGray6))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // 统计数据
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(
                title: "预测成功",
                value: "\(user.successfulPredictions)",
                subtitle: "次"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                title: "总积分",
                value: "\(user.totalPoints)",
                subtitle: "分"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                title: "准确率",
                value: "\(user.accuracyRate)%",
                subtitle: "率"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2)
        )
    }
    
    // 成就勋章
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我的成就")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(user.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
    
    // 我的预测概览
    private var myPredictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("近期预测")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink("查看全部") {
                    PredictionView()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if user.recentPredictions.isEmpty {
                Text("暂无预测记录")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(user.recentPredictions.prefix(3), id: \.id) { prediction in
                        RecentPredictionRow(prediction: prediction)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2)
        )
    }
    
    // 设置选项
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("设置")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                SettingRow(
                    icon: "bell.fill",
                    title: "推送通知",
                    subtitle: "趋势提醒和预测结果",
                    action: {}
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingRow(
                    icon: "heart.fill",
                    title: "我的收藏",
                    subtitle: "收藏的趋势和搭配",
                    action: {}
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingRow(
                    icon: "questionmark.circle.fill",
                    title: "帮助与反馈",
                    subtitle: "常见问题和意见反馈",
                    action: {}
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingRow(
                    icon: "info.circle.fill",
                    title: "关于我们",
                    subtitle: "版本信息和使用条款",
                    action: {}
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 1)
            )
        }
    }
}

// 统计项
struct StatItem: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 成就卡片
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// 近期预测行
struct RecentPredictionRow: View {
    let prediction: UserPrediction
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: statusIcon)
                        .font(.caption)
                        .foregroundColor(statusColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(prediction.trendName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(prediction.predictedDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        guard let isCorrect = prediction.isCorrect else { return .orange }
        return isCorrect ? .green : .red
    }
    
    private var statusIcon: String {
        guard let isCorrect = prediction.isCorrect else { return "clock" }
        return isCorrect ? "checkmark" : "xmark"
    }
    
    private var statusText: String {
        guard let isCorrect = prediction.isCorrect else { return "等待中" }
        return isCorrect ? "成功" : "失败"
    }
}

// 设置行
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 用户资料数据模型
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

// 成就数据模型
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

// 编辑资料视图
struct EditProfileView: View {
    @Binding var user: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("用户名", text: $username)
                    TextField("个人简介", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("偏好设置") {
                    // 这里可以添加风格偏好设置
                    Text("风格偏好设置")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            username = user.username
            bio = user.bio
        }
    }
    
    private func saveChanges() {
        // 这里保存更改，实际项目中会更新真实数据
    }
}

#Preview {
    ProfileView()
}
