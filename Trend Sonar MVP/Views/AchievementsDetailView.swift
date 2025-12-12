//
//  AchievementsDetailView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct AchievementsDetailView: View {
    let achievements: [Achievement]
    
    // 计算统计数据
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var progress: Double {
        Double(unlockedCount) / Double(achievements.count)
    }
    
    var body: some View {
        ZStack {
            Color.clear.appBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部总进度
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    AngularGradient(
                                        colors: [.neonBlue, .neonPurple, .neonBlue],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: .neonPurple.opacity(0.5), radius: 10)
                            
                            VStack(spacing: 4) {
                                Text("\(Int(progress * 100))%")
                                    .font(.title.bold().monospaced())
                                    .foregroundColor(.white)
                                Text("\(unlockedCount)/\(achievements.count)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Text("成就总览")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // 成就列表
                    VStack(spacing: 16) {
                        ForEach(achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("我的成就")
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Hexagon()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.2) : Color.black.opacity(0.3))
                    .frame(width: 60, height: 70)
                    .overlay(
                        Hexagon()
                            .stroke(achievement.isUnlocked ? achievement.color : Color.white.opacity(0.1), lineWidth: 2)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            }
            .grayscale(achievement.isUnlocked ? 0 : 1.0)
            
            // 文本信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    
                    Spacer()
                    
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(achievement.color)
                            .glow(color: achievement.color, radius: 5)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.8) : .gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .glassCard()
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

