//
//  PredictionViewModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI
import Combine

@MainActor
class PredictionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTrend: TrendItem?
    @Published var showingPredictionSheet = false
    @Published var confidence: Double = 50
    @Published var betAmount: Int = 10 // 默认投注10声纳币
    @Published var showInsufficientFundsAlert = false
    @Published var selectedTargetZone: TrendZone = .trending // 用户选择的目标区域
    
    // MARK: - Data Manager
    private let trendManager = TrendDataManager.shared
    
    // MARK: - Computed Properties
    var nicheTrends: [TrendItem] {
        trendManager.predictableTrends
    }
    
    var predictions: [UserPrediction] {
        trendManager.getUserPredictionHistory()
    }
    
    var successfulPredictions: Int {
        predictions.filter { $0.isCorrect == true }.count
    }
    
    var accuracyRate: Int {
        trendManager.calculateAccuracyRate()
    }
    
    var totalPoints: Int {
        trendManager.calculateUserPoints()
    }
    
    var availableSonarCoins: Int {
        trendManager.getAvailableSonarCoins()
    }
    
    /// 检查是否有足够的声纳币进行投注
    var canAffordBet: Bool {
        availableSonarCoins >= betAmount
    }
    
    /// 计算潜在收益
    var potentialReward: String {
        guard let trend = selectedTrend else { return "0" }
        
        let baseMultiplier: Int
        switch (trend.zone, selectedTargetZone) {
        case (.niche, .trending): baseMultiplier = 3
        case (.niche, .mainstream): baseMultiplier = 5 // 小众直达主流，难度最高
        case (.trending, .mainstream): baseMultiplier = 2
        default: baseMultiplier = 2
        }
        
        let confidenceBonus = confidence > 80 ? 1 : 0
        let totalMultiplier = baseMultiplier + confidenceBonus
        let reward = betAmount * totalMultiplier
        
        return "\(reward)"
    }
    
    /// 收益分解说明
    var rewardBreakdown: String {
        guard let trend = selectedTrend else { return "" }
        
        let baseMultiplier: Int
        switch (trend.zone, selectedTargetZone) {
        case (.niche, .trending): baseMultiplier = 3
        case (.niche, .mainstream): baseMultiplier = 5
        case (.trending, .mainstream): baseMultiplier = 2
        default: baseMultiplier = 2
        }
        
        let confidenceBonus = confidence > 80 ? 1 : 0
        
        if confidenceBonus > 0 {
            return "\(betAmount) × \(baseMultiplier)倍(难度) + \(confidenceBonus)倍(信心≥80%)"
        } else {
            return "\(betAmount) × \(baseMultiplier)倍(难度) | 信心≥80%可获得额外奖励"
        }
    }
    
    /// 信心指数影响提示
    var confidenceImpact: (icon: String, color: Color, message: String) {
        let successRate = Int(confidence * 0.7 + 20)
        
        switch Int(confidence) {
        case 0..<50:
            return ("exclamationmark.triangle.fill", .orange, "预测成功率: \(successRate)% | 低风险低收益")
        case 50..<80:
            return ("info.circle.fill", .blue, "预测成功率: \(successRate)% | 平衡风险收益")
        case 80..<90:
            return ("star.fill", .neonGreen, "预测成功率: \(successRate)% | 获得额外收益倍数!")
        case 90...100:
            return ("flame.fill", .neonPink, "预测成功率: \(successRate)% | 高风险高收益！")
        default:
            return ("questionmark.circle", .gray, "调整信心指数")
        }
    }
    
    // MARK: - Methods
    
    /// 选择趋势进行预测
    func selectTrendForPrediction(_ trend: TrendItem) {
        selectedTrend = trend
        confidence = 50 // 重置信心指数
        selectedTargetZone = .trending // 重置为默认选择
        showingPredictionSheet = true
    }
    
    /// 选择预测目标区域
    func selectTargetZone(_ zone: TrendZone) {
        selectedTargetZone = zone
    }
    
    /// 提交预测
    func submitPrediction() {
        guard let trend = selectedTrend else { return }
        
        // 检查声纳币是否足够
        guard canAffordBet else {
            showInsufficientFundsAlert = true
            return
        }
        
        let newPrediction = UserPrediction(
            trendName: trend.name,
            predictedDate: Date(),
            currentZone: trend.zone,
            targetZone: selectedTargetZone, // 使用用户选择的目标区域
            confidence: Int(confidence),
            isCorrect: nil
        )
        
        // 添加到数据管理器（带投注）
        let success = trendManager.addUserPrediction(newPrediction, betAmount: betAmount)
        
        if success {
            closePredictionSheet()
            
            // 触发成功反馈
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } else {
            showInsufficientFundsAlert = true
        }
    }
    
    /// 关闭预测表单
    func closePredictionSheet() {
        showingPredictionSheet = false
        selectedTrend = nil
        confidence = 50
        betAmount = 10 // 重置投注金额
    }
    
    /// 调整投注金额
    func adjustBetAmount(_ amount: Int) {
        betAmount = max(5, min(availableSonarCoins, amount)) // 最少5声纳币，最多全部
    }
    
    /// 获取推荐投注金额
    func getRecommendedBets() -> [Int] {
        let available = availableSonarCoins
        let recommendations = [5, 10, 20, 50]
        return recommendations.filter { $0 <= available }
    }
    
    /// 更新信心指数
    func updateConfidence(_ value: Double) {
        confidence = value
    }
    
    
    /// 获取预测状态文本
    func getStatusText(for prediction: UserPrediction) -> String {
        guard let isCorrect = prediction.isCorrect else { return "等待中" }
        return isCorrect ? "预测成功" : "预测失败"
    }
    
    /// 获取预测状态颜色
    func getStatusColor(for prediction: UserPrediction) -> Color {
        guard let isCorrect = prediction.isCorrect else { return .neonBlue }
        return isCorrect ? .neonGreen : .red
    }
    
    /// 获取预测状态图标
    func getStatusIcon(for prediction: UserPrediction) -> String {
        guard let isCorrect = prediction.isCorrect else { return "hourglass" }
        return isCorrect ? "checkmark" : "xmark"
    }
}
