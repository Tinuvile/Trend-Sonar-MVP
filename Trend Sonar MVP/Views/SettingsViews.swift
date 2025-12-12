//
//  SettingsViews.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

// MARK: - 通知设置页面
struct NotificationSettingsView: View {
    @State private var trendAlerts = true
    @State private var predictionUpdates = true
    @State private var weeklyDigest = false
    @State private var newFollowers = true
    
    var body: some View {
        ZStack {
            Color.clear.appBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 推送控制
                    VStack(spacing: 0) {
                        NotificationToggle(title: "趋势预警", subtitle: "当关注的趋势进入红区时通知", isOn: $trendAlerts, icon: "flame.fill", color: .neonPink)
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        NotificationToggle(title: "预测结果", subtitle: "当你的预测结算时通知", isOn: $predictionUpdates, icon: "target", color: .neonGreen)
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        NotificationToggle(title: "周报推送", subtitle: "每周一推送个性化趋势周报", isOn: $weeklyDigest, icon: "newspaper.fill", color: .neonBlue)
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        NotificationToggle(title: "新关注者", subtitle: "有人关注你或点赞你的提名时", isOn: $newFollowers, icon: "person.2.fill", color: .neonYellow)
                    }
                    .glassCard()
                    
                    Text("请在系统设置中开启 TrendSonar 的通知权限以确保接收重要提醒。")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationTitle("通知设置")
    }
}

// 通用开关组件
struct NotificationToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                    .glow(color: isOn ? color : .clear, radius: 5)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.bold())
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: color))
        .padding()
    }
}

// MARK: - 通用设置页面
struct GeneralSettingsView: View {
    @State private var selectedLanguage = "简体中文"
    @State private var clearCache = false
    @State private var appVersion = "1.0.0 (Beta)"
    
    var body: some View {
        ZStack {
            Color.clear.appBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 语言与地区
                    VStack(spacing: 0) {
                        SettingsRowLink(icon: "globe", title: "语言", value: selectedLanguage, color: .neonBlue) {
                            // 语言选择逻辑
                        }
                    }
                    .glassCard()
                    
                    // 存储与数据
                    VStack(spacing: 0) {
                        Button(action: { clearCache = true }) {
                            SettingsRowAction(icon: "trash", title: "清除缓存", subtitle: "24.5 MB", color: .white)
                        }
                    }
                    .glassCard()
                    
                    // 关于与帮助
                    VStack(spacing: 0) {
                        SettingsRowLink(icon: "doc.text", title: "用户协议", color: .white.opacity(0.8)) {}
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        SettingsRowLink(icon: "shield", title: "隐私政策", color: .white.opacity(0.8)) {}
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        SettingsRowLink(icon: "info.circle", title: "关于我们", value: appVersion, color: .white.opacity(0.8)) {}
                    }
                    .glassCard()
                    
                    // 退出登录
                    Button(action: {}) {
                        Text("退出登录")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("通用设置")
        .alert("缓存已清除", isPresented: $clearCache) {
            Button("确定", role: .cancel) { }
        }
    }
}

// 设置行组件 (带箭头)
struct SettingsRowLink: View {
    let icon: String
    let title: String
    var value: String? = nil
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
        }
    }
}

// 设置行组件 (操作类)
struct SettingsRowAction: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
    }
}

