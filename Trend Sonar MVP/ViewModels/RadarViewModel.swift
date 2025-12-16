//
//  RadarViewModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTrend: TrendItem?
    @Published var isScanning = false
    @Published var scanAngle: Double = 0
    @Published var selectedCategory: FashionCategory?
    @Published var styleProfile = UserStyleProfile()
    @Published var showingStyleSetup = false
    @Published var isPersonalized = false
    @Published var pulseScale: CGFloat = 1.0
    
    // MARK: - Data Manager
    private let trendManager = TrendDataManager.shared
    
    // MARK: - Computed Properties
    var filteredTrends: [TrendItem] {
        var baseTrends = trendManager.radarTrends
        
        // 按类别过滤
        if let category = selectedCategory {
            baseTrends = baseTrends.filter { $0.category == category }
        }
        
        // 按个性化风格过滤
        if isPersonalized && !styleProfile.preferredStyles.isEmpty {
            baseTrends = baseTrends.filter { trend in
                styleProfile.compatibilityScore(for: trend) > 60
            }
        }
        
        return baseTrends
    }
    
    // MARK: - Initialization
    init() {
        startScanning()
    }
    
    // MARK: - Methods
    
    /// 开始雷达扫描动画
    func startScanning() {
        // 先停止现有动画，避免冲突
        stopScanning()
        
        isScanning = true
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            scanAngle = 360
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
    
    /// 停止扫描动画
    func stopScanning() {
        isScanning = false
        scanAngle = 0
    }
    
    /// 选择/取消选择趋势
    func selectTrend(_ trend: TrendItem) {
        withAnimation(.spring()) {
            selectedTrend = selectedTrend?.id == trend.id ? nil : trend
        }
    }
    
    /// 切换类别过滤器
    func toggleCategoryFilter(_ category: FashionCategory) {
        withAnimation(.easeInOut) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }
    
    /// 切换个性化模式
    func togglePersonalization() {
        withAnimation(.easeInOut) {
            if !styleProfile.preferredStyles.isEmpty {
                isPersonalized.toggle()
            } else {
                showingStyleSetup = true
            }
        }
    }
    
    /// 关闭趋势详情
    func closeTrendDetail() {
        withAnimation {
            selectedTrend = nil
        }
    }
    
    /// 计算趋势在雷达上的位置
    func calculateTrendPosition(trend: TrendItem, center: CGPoint, size: CGFloat) -> CGPoint {
        let radius = (size / 2) * trend.distance
        let x = center.x + cos(trend.angle * .pi / 180) * radius
        let y = center.y + sin(trend.angle * .pi / 180) * radius
        return CGPoint(x: x, y: y)
    }
    
    /// 计算趋势点大小
    func trendPointSize(trend: TrendItem) -> CGFloat {
        return 8 + CGFloat(trend.heatScore) / 8
    }
    
    /// 获取兼容性颜色
    func compatibilityColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
    
    /// 预测趋势
    func predictTrend(_ trend: TrendItem) {
        // 触发震动反馈
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // 创建预测记录
        let prediction = UserPrediction(
            trendName: trend.name,
            predictedDate: Date(),
            currentZone: trend.zone,
            targetZone: .trending, // 默认预测进入trending区
            confidence: 70, // 默认信心指数
            isCorrect: nil
        )
        
        // 添加到数据管理器
        trendManager.addUserPrediction(prediction)
        
        // 关闭详情页
        closeTrendDetail()
    }
}
