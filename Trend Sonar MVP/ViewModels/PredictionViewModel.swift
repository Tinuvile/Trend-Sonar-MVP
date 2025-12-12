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
    @Published var predictions: [UserPrediction] = []
    @Published var selectedTrend: TrendItem?
    @Published var showingPredictionSheet = false
    @Published var confidence: Double = 50
    
    // MARK: - Computed Properties
    var nicheTrends: [TrendItem] {
        TrendItem.sampleData.filter { $0.zone == .niche }
    }
    
    var successfulPredictions: Int {
        predictions.filter { $0.isCorrect == true }.count
    }
    
    var accuracyRate: Int {
        guard !predictions.isEmpty else { return 0 }
        let completedPredictions = predictions.filter { $0.isCorrect != nil }
        guard !completedPredictions.isEmpty else { return 0 }
        let successful = completedPredictions.filter { $0.isCorrect == true }
        return Int((Double(successful.count) / Double(completedPredictions.count)) * 100)
    }
    
    var totalPoints: Int {
        predictions.filter { $0.isCorrect == true }.count * 50 // 简化计算
    }
    
    // MARK: - Methods
    
    /// 选择趋势进行预测
    func selectTrendForPrediction(_ trend: TrendItem) {
        selectedTrend = trend
        confidence = 50 // 重置信心指数
        showingPredictionSheet = true
    }
    
    /// 提交预测
    func submitPrediction() {
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
        closePredictionSheet()
        
        // 触发成功反馈
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    /// 关闭预测表单
    func closePredictionSheet() {
        showingPredictionSheet = false
        selectedTrend = nil
        confidence = 50
    }
    
    /// 更新信心指数
    func updateConfidence(_ value: Double) {
        confidence = value
    }
    
    /// 模拟预测结果更新（在真实应用中，这会是后台任务）
    func simulatePredictionResult(for predictionId: UUID, isCorrect: Bool) {
        if let index = predictions.firstIndex(where: { $0.id == predictionId }) {
            predictions[index] = UserPrediction(
                trendName: predictions[index].trendName,
                predictedDate: predictions[index].predictedDate,
                currentZone: predictions[index].currentZone,
                targetZone: predictions[index].targetZone,
                confidence: predictions[index].confidence,
                isCorrect: isCorrect
            )
        }
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
