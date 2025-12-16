//
//  SettingsViews.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/16.
//

import SwiftUI

// MARK: - 通知设置页面
struct NotificationSettingsView: View {
    @State private var trendNotifications = true
    @State private var predictionNotifications = true
    @State private var achievementNotifications = true
    @State private var dailyReminder = false
    @State private var weeklyReport = true
    
    var body: some View {
        ZStack {
            Color.clear.appBackground()
            
            Form {
                Section("趋势通知") {
                    Toggle("新趋势提醒", isOn: $trendNotifications)
                    Toggle("预测结果通知", isOn: $predictionNotifications)
                    Toggle("成就解锁通知", isOn: $achievementNotifications)
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section("定期提醒") {
                    Toggle("每日探索提醒", isOn: $dailyReminder)
                    Toggle("周报推送", isOn: $weeklyReport)
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section("推送时间") {
                    HStack {
                        Text("提醒时间")
                            .foregroundColor(.white)
                        Spacer()
                        Text("19:00")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("通知设置")
        .preferredColorScheme(.dark)
    }
}

// MARK: - 通用设置页面
struct GeneralSettingsView: View {
    @State private var hapticFeedback = true
    @State private var soundEffects = true
    @State private var autoSync = true
    @State private var dataUsage = "WiFi"
    @State private var language = "简体中文"
    @State private var theme = "自动"
    
    var body: some View {
        ZStack {
            Color.clear.appBackground()
            
            Form {
                Section("交互设置") {
                    Toggle("触觉反馈", isOn: $hapticFeedback)
                    Toggle("音效", isOn: $soundEffects)
                    Toggle("自动同步", isOn: $autoSync)
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section("数据和网络") {
                    HStack {
                        Text("数据使用")
                            .foregroundColor(.white)
                        Spacer()
                        Text(dataUsage)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack {
                        Text("缓存大小")
                            .foregroundColor(.white)
                        Spacer()
                        Button("清理缓存") {
                            // 清理缓存逻辑
                        }
                        .font(.caption)
                        .foregroundColor(.neonBlue)
                    }
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section("应用设置") {
                    HStack {
                        Text("语言")
                            .foregroundColor(.white)
                        Spacer()
                        Text(language)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack {
                        Text("主题")
                            .foregroundColor(.white)
                        Spacer()
                        Text(theme)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section("关于") {
                    HStack {
                        Text("版本")
                            .foregroundColor(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack {
                        Text("开发者")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Trend Sonar Team")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Button("用户协议") {
                        // 显示用户协议
                    }
                    .foregroundColor(.neonBlue)
                    
                    Button("隐私政策") {
                        // 显示隐私政策
                    }
                    .foregroundColor(.neonBlue)
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("通用设置")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
    .preferredColorScheme(.dark)
}

#Preview {
    NavigationView {
        GeneralSettingsView()
    }
    .preferredColorScheme(.dark)
}