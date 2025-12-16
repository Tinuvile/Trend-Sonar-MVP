//
//  TrendDetailSheet.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/16.
//

import SwiftUI

struct TrendDetailSheet: View {
    let trend: TrendItem
    let styleProfile: UserStyleProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部信息
                    headerSection
                    
                    // 匹配度
                    compatibilitySection
                    
                    // 详细数据
                    statsSection
                    
                    // 描述
                    descriptionSection
                }
                .padding()
            }
            .navigationTitle("趋势详情")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(trend.zone.color.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: trend.category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(trend.zone.color)
            }
            
            VStack(spacing: 8) {
                Text(trend.name)
                    .font(.title.bold())
                
                Text(trend.zone.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(trend.zone.color.opacity(0.2)))
                    .foregroundColor(trend.zone.color)
            }
        }
    }
    
    private var compatibilitySection: some View {
        let score = styleProfile.compatibilityScore(for: trend)
        
        return VStack(spacing: 12) {
            Text("与你的匹配度")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(compatibilityColorForScore(score))
                
                Text("%")
                    .font(.title2.bold())
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
            }
            
            ProgressView(value: Double(score), total: 100)
                .accentColor(compatibilityColorForScore(score))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 40)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "热度",
                value: "\(trend.heatScore)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "增长率",
                value: "+\(String(format: "%.1f", trend.growthRate))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("趋势简介")
                .font(.headline)
            
            Text(trend.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
    }
    
    private func compatibilityColorForScore(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .yellow
        case 40...59: return .orange
        default: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
    }
}
