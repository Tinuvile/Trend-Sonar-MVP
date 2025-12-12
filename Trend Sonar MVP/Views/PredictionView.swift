//
//  PredictionView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct PredictionView: View {
    @StateObject private var viewModel = PredictionViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.clear.appBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 头部统计
                        headerStats
                        
                        // 可预测的趋势列表
                        trendsList
                        
                        // 我的预测记录
                        myPredictions
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("趋势预测")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingPredictionSheet) {
                if let trend = viewModel.selectedTrend {
                    predictionSheet(trend: trend)
                        .preferredColorScheme(.dark)
                }
            }
        }
    }
    
    // 头部统计信息
    private var headerStats: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "预测准确率", 
                value: "\(viewModel.accuracyRate)%", 
                color: .neonGreen,
                icon: "target"
            )
            
            StatCard(
                title: "获得积分", 
                value: "\(viewModel.totalPoints)", 
                color: .neonYellow,
                icon: "star.fill"
            )
            
            StatCard(
                title: "成功预测", 
                value: "\(viewModel.successfulPredictions)", 
                color: .neonBlue,
                icon: "checkmark.seal.fill"
            )
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // 趋势列表
    private var trendsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("小众潜力股")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("BET ON TRENDS")
                    .font(.caption.monospaced())
                    .foregroundColor(.neonBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().stroke(Color.neonBlue, lineWidth: 1))
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.nicheTrends) { trend in
                        TrendPredictionCard(trend: trend) {
                            viewModel.selectTrendForPrediction(trend)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 我的预测记录
    private var myPredictions: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("我的预测记录")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.predictions.count) RECORDS")
                    .font(.caption.monospaced())
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal)
            
            if viewModel.predictions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "crystal.ball")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.2))
                    
                    Text("还没有预测记录")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Button("开始预测") {
                        // 引导用户点击上方
                    }
                    .buttonStyle(NeonButtonStyle(color: .neonPurple))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .glassCard()
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.predictions) { prediction in
                        PredictionHistoryCard(prediction: prediction, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 预测表单
    private func predictionSheet(trend: TrendItem) -> some View {
        ZStack {
            Color.deepBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 拖动条
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top)
                
                // 趋势信息
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(trend.name)
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(trend.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(trend.zone.color))
                    }
                    
                    HStack {
                        Label("热度: \(trend.heatScore)", systemImage: "flame.fill")
                            .foregroundColor(.neonPink)
                        Spacer()
                        Label("增长: +\(String(format: "%.1f", trend.growthRate))%", 
                              systemImage: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.neonGreen)
                    }
                    .font(.subheadline.monospaced())
                }
                .padding()
                .glassCard()
                
                Text("你认为这个趋势会走向何方？")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 预测选项
                VStack(spacing: 12) {
                    PredictionOption(
                        title: "冲进先锋区",
                        subtitle: "热度 > 60",
                        points: "50 PTS",
                        isSelected: true
                    )
                    
                    PredictionOption(
                        title: "直达主流区",
                        subtitle: "热度 > 80",
                        points: "200 PTS",
                        isSelected: false
                    )
                }
                
                // 信心指数
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("信心指数")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(confidence))%")
                            .font(.title3.bold().monospaced())
                            .foregroundColor(trend.zone.color)
                    }
                    
                    Slider(value: $viewModel.confidence, in: 0...100, step: 10)
                        .accentColor(trend.zone.color)
                }
                .padding()
                .glassCard()
                
                Spacer()
                
                // 提交按钮
                Button(action: { viewModel.submitPrediction() }) {
                    Text("提交预测")
                }
                .buttonStyle(NeonSolidButtonStyle(color: trend.zone.color))
            }
            .padding()
        }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .glow(color: color, radius: 5)
            
            Text(value)
                .font(.title3.bold().monospaced())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }
}

// 趋势预测卡片
struct TrendPredictionCard: View {
    let trend: TrendItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: trend.category.icon)
                        .font(.title2)
                        .foregroundColor(trend.zone.color)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(trend.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text("+\(String(format: "%.1f", trend.growthRate))%")
                        .font(.caption.monospaced())
                        .foregroundColor(.neonGreen)
                    
                    Spacer()
                    
                    Text("预测")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white))
                }
            }
            .padding()
            .frame(width: 160, height: 140)
            .glassCard()
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.bold())
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(points)
                .font(.caption.bold().monospaced())
                .foregroundColor(.neonYellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.neonYellow.opacity(0.2)))
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.neonBlue)
                    .font(.title3)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.neonBlue.opacity(0.1) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.neonBlue : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// 预测历史卡片
struct PredictionHistoryCard: View {
    let prediction: UserPrediction
    let viewModel: PredictionViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(viewModel.getStatusColor(for: prediction).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: viewModel.getStatusIcon(for: prediction))
                    .foregroundColor(viewModel.getStatusColor(for: prediction))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prediction.trendName)
                    .font(.body.bold())
                    .foregroundColor(.white)
                
                Text(prediction.predictedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.getStatusText(for: prediction))
                    .font(.caption.bold())
                    .foregroundColor(viewModel.getStatusColor(for: prediction))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(viewModel.getStatusColor(for: prediction).opacity(0.1)))
                
                Text("信心 \(prediction.confidence)%")
                    .font(.caption2.monospaced())
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding()
        .glassCard()
    }
    
    private var statusColor: Color {
        guard let isCorrect = prediction.isCorrect else { return .neonBlue }
        return isCorrect ? .neonGreen : .red
    }
    
    private var statusIcon: String {
        guard let isCorrect = prediction.isCorrect else { return "hourglass" }
        return isCorrect ? "checkmark" : "xmark"
    }
    
    private var statusText: String {
        guard let isCorrect = prediction.isCorrect else { return "WAITING" }
        return isCorrect ? "SUCCESS" : "FAILED"
    }
}

#Preview {
    PredictionView()
        .preferredColorScheme(.dark)
}
