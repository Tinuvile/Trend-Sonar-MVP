//
//  PredictionView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct PredictionView: View {
    @State private var predictions: [UserPrediction] = []
    @State private var selectedTrend: TrendItem?
    @State private var showingPredictionSheet = false
    @State private var confidence: Double = 50
    
    private let nicheTrends = TrendItem.sampleData.filter { $0.zone == .niche }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 头部统计
                headerStats
                
                // 可预测的趋势列表
                trendsList
                
                // 我的预测记录
                myPredictions
            }
            .navigationTitle("趋势预测")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPredictionSheet) {
                if let trend = selectedTrend {
                    predictionSheet(trend: trend)
                }
            }
        }
    }
    
    // 头部统计信息
    private var headerStats: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "预测准确率", 
                value: "73%", 
                subtitle: "本月",
                color: .green,
                icon: "target"
            )
            
            StatCard(
                title: "获得积分", 
                value: "1,240", 
                subtitle: "总计",
                color: .orange,
                icon: "star.fill"
            )
            
            StatCard(
                title: "成功预测", 
                value: "8", 
                subtitle: "次数",
                color: .blue,
                icon: "checkmark.seal.fill"
            )
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // 趋势列表
    private var trendsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("小众潜力股")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("点击预测")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(nicheTrends) { trend in
                        TrendPredictionCard(trend: trend) {
                            selectedTrend = trend
                            showingPredictionSheet = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 我的预测记录
    private var myPredictions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我的预测记录")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(predictions.count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if predictions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "crystal.ball")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("还没有预测记录")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("开始预测你看好的小众趋势吧！")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(predictions) { prediction in
                            PredictionHistoryCard(prediction: prediction)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // 预测表单
    private func predictionSheet(trend: TrendItem) -> some View {
        NavigationView {
            VStack(spacing: 24) {
                // 趋势信息
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(trend.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(trend.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(trend.zone.color))
                    }
                    
                    Text(trend.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("当前热度: \(trend.heatScore)", systemImage: "thermometer")
                        Spacer()
                        Label("增长率: +\(String(format: "%.1f", trend.growthRate))%", 
                              systemImage: "arrow.up.right")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // 预测选项
                VStack(alignment: .leading, spacing: 16) {
                    Text("你认为这个趋势会：")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        PredictionOption(
                            title: "冲进先锋区（黄区）",
                            subtitle: "1-2周内热度提升至60+",
                            points: "获得50积分",
                            isSelected: true
                        )
                        
                        PredictionOption(
                            title: "直达主流区（红区）",
                            subtitle: "1个月内成为大热趋势",
                            points: "获得200积分",
                            isSelected: false
                        )
                        
                        PredictionOption(
                            title: "继续小众",
                            subtitle: "保持现有热度区间",
                            points: "获得10积分",
                            isSelected: false
                        )
                    }
                }
                
                // 信心指数
                VStack(alignment: .leading, spacing: 8) {
                    Text("信心指数: \(Int(confidence))%")
                        .font(.headline)
                    
                    Slider(value: $confidence, in: 0...100, step: 10)
                        .accentColor(trend.zone.color)
                    
                    HStack {
                        Text("随便猜猜")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("非常确定")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 提交按钮
                Button(action: submitPrediction) {
                    Text("提交预测")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(trend.zone.color)
                        )
                }
            }
            .padding()
            .navigationTitle("趋势预测")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") {
                    showingPredictionSheet = false
                }
            )
        }
    }
    
    private func submitPrediction() {
        guard let trend = selectedTrend else { return }
        
        let newPrediction = UserPrediction(
            trendName: trend.name,
            predictedDate: Date(),
            currentZone: trend.zone,
            targetZone: .trending, // 简化处理，默认预测进入trending区
            confidence: Int(confidence),
            isCorrect: nil
        )
        
        predictions.append(newPrediction)
        showingPredictionSheet = false
        selectedTrend = nil
        
        // TODO: 保存到本地或云端
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2)
        )
    }
}

// 趋势预测卡片
struct TrendPredictionCard: View {
    let trend: TrendItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 趋势图标
                Circle()
                    .fill(trend.zone.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: trend.category.icon)
                            .foregroundColor(trend.zone.color)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trend.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(trend.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("热度 \(trend.heatScore)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("+\(String(format: "%.1f", trend.growthRate))%")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.title2)
                        .foregroundColor(trend.zone.color)
                    
                    Text("预测")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 预测选项
struct PredictionOption: View {
    let title: String
    let subtitle: String
    let points: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(points)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                )
        )
    }
}

// 预测历史卡片
struct PredictionHistoryCard: View {
    let prediction: UserPrediction
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prediction.trendName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("预测时间: \(prediction.predictedDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("信心指数: \(prediction.confidence)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
                
                if prediction.isCorrect == true {
                    Text("+50积分")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1)
        )
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
        return isCorrect ? "预测成功" : "预测失败"
    }
}

#Preview {
    PredictionView()
}
