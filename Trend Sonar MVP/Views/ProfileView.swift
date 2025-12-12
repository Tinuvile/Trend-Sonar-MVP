//
//  ProfileView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel() 
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.appBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 用户头像和基本信息
                        profileHeader
                        
                        // 统计数据
                        statsSection
                        
                        // 成就勋章
                        achievementsSection
                        
                        // 设置选项
                        settingsSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("编辑") { viewModel.showEditProfile() }
                        .foregroundColor(.neonBlue)
                }
            }
            .sheet(isPresented: $viewModel.showingEditProfile) {
                EditProfileView(user: $viewModel.user)
            }
        }
    }
    
    // 个人资料头部
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                // 动态光环
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.neonBlue, .neonPurple, .neonBlue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(0)) // 可添加旋转动画
                    .glow(color: .neonBlue, radius: 10)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 100, height: 100)
                
                Text(viewModel.user.initials)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text(viewModel.user.username)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.neonYellow)
                    Text("Lv.\(viewModel.user.level) \(viewModel.getLevelTitle())")
                        .font(.subheadline.monospaced())
                        .foregroundColor(.neonYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.neonYellow.opacity(0.1)))
                .overlay(Capsule().stroke(Color.neonYellow.opacity(0.3), lineWidth: 1))
            }
        }
    }
    
    // 统计数据
    private var statsSection: some View {
        HStack(spacing: 12) {
            ProfileStatItem(title: "成功预测", value: "\(viewModel.user.successfulPredictions)", color: .neonGreen)
            ProfileStatItem(title: "总积分", value: "\(viewModel.user.totalPoints)", color: .neonPurple)
            ProfileStatItem(title: "准确率", value: "\(viewModel.user.accuracyRate)%", color: .neonBlue)
        }
        .padding(.horizontal)
    }
    
    // 成就勋章
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("我的成就")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: AchievementsDetailView(achievements: viewModel.user.achievements)) {
                    HStack(spacing: 4) {
                        Text("查看全部")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.neonBlue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.user.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 设置选项
    private var settingsSection: some View {
        VStack(spacing: 12) {
            // 风格偏好设置
            NavigationLink(destination: StyleSetupView(styleProfile: $viewModel.styleProfile).navigationTitle("风格偏好").navigationBarTitleDisplayMode(.inline)) {
                SettingRowContent(icon: "person.crop.circle.badge.checkmark", title: "风格偏好设置", color: .neonPink)
            }
            
            // 通知设置
            NavigationLink(destination: NotificationSettingsView()) {
                SettingRowContent(icon: "bell.badge", title: "通知设置", color: .neonBlue)
            }
            
            // 通用设置
            NavigationLink(destination: GeneralSettingsView()) {
                SettingRowContent(icon: "gearshape", title: "通用设置", color: .white)
            }
        }
        .padding(.horizontal)
    }
}

// 统计项组件
struct ProfileStatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold().monospaced())
                .foregroundColor(color)
                .glow(color: color, radius: 5)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }
}

// 成就徽章组件
struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Hexagon()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 70, height: 80)
                    .overlay(
                        Hexagon()
                            .stroke(achievement.isUnlocked ? achievement.color : Color.white.opacity(0.1), lineWidth: 2)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
                    .glow(color: achievement.isUnlocked ? achievement.color : .clear, radius: 5)
            }
            
            Text(achievement.title)
                .font(.caption.bold())
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// 六边形形状
struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let x = rect.midX
        let y = rect.midY
        let side = min(width, height) / 2
        
        let points = (0..<6).map { i -> CGPoint in
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            return CGPoint(x: x + side * cos(angle), y: y + side * sin(angle))
        }
        
        path.move(to: points[0])
        for i in 1..<6 {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        return path
    }
}

// 设置行内容组件
struct SettingRowContent: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
