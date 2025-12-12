//
//  TrendModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import Foundation
import SwiftUI

// 趋势类型枚举
enum TrendZone: String, CaseIterable {
    case mainstream = "主流"    // 红区 - 圆心
    case trending = "先锋"      // 黄区 - 中间
    case niche = "小众"        // 蓝区 - 边缘
    
    var color: Color {
        switch self {
        case .mainstream: return .red.opacity(0.8)
        case .trending: return .yellow.opacity(0.8)
        case .niche: return .blue.opacity(0.8)
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .mainstream: return 0.3
        case .trending: return 0.6
        case .niche: return 1.0
        }
    }
}

// 时尚类别
enum FashionCategory: String, CaseIterable {
    case tops = "上装"
    case bottoms = "下装"
    case shoes = "鞋履"
    case accessories = "配饰"
    case style = "风格"
    
    var icon: String {
        switch self {
        case .tops: return "tshirt"
        case .bottoms: return "square.and.line.vertical.and.square.filled"
        case .shoes: return "shoe"
        case .accessories: return "bag"
        case .style: return "sparkles"
        }
    }
}

// 趋势数据模型
struct TrendItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: FashionCategory
    let zone: TrendZone
    let angle: Double // 在雷达图中的角度 (0-360度)
    let distance: CGFloat // 从中心的距离 (0-1)
    let heatScore: Int // 热度分数 (0-100)
    let growthRate: Double // 增长率 (%)
    let description: String
    let isUserPredicted: Bool // 用户是否预测过
    
    init(name: String, category: FashionCategory, zone: TrendZone, angle: Double, heatScore: Int, growthRate: Double, description: String, isUserPredicted: Bool = false) {
        self.name = name
        self.category = category
        self.zone = zone
        self.angle = angle
        self.distance = zone.radius + CGFloat.random(in: -0.1...0.1)
        self.heatScore = heatScore
        self.growthRate = growthRate
        self.description = description
        self.isUserPredicted = isUserPredicted
    }
}

// 用户预测记录
struct UserPrediction: Identifiable {
    let id = UUID()
    let trendName: String
    let predictedDate: Date
    let currentZone: TrendZone
    let targetZone: TrendZone
    let confidence: Int // 信心指数 (0-100)
    let isCorrect: Bool?
}

// 示例数据
extension TrendItem {
    static let sampleData: [TrendItem] = [
        // 红区 - 主流热门
        TrendItem(name: "千鸟格", category: .style, zone: .mainstream, angle: 45, heatScore: 95, growthRate: 2.3, description: "经典复古图案，永不过时的优雅选择"),
        TrendItem(name: "阔腿裤", category: .bottoms, zone: .mainstream, angle: 120, heatScore: 92, growthRate: 1.8, description: "舒适显瘦，职场与日常的完美平衡"),
        TrendItem(name: "马丁靴", category: .shoes, zone: .mainstream, angle: 200, heatScore: 88, growthRate: 0.5, description: "街头必备，硬朗风格的代表单品"),
        TrendItem(name: "棒球帽", category: .accessories, zone: .mainstream, angle: 280, heatScore: 90, growthRate: -1.2, description: "运动休闲风的经典配饰"),
        
        // 黄区 - 上升趋势
        TrendItem(name: "Y2K风格", category: .style, zone: .trending, angle: 30, heatScore: 75, growthRate: 15.2, description: "千禧年复古风回潮，科技感与怀旧并存"),
        TrendItem(name: "工装短裤", category: .bottoms, zone: .trending, angle: 80, heatScore: 68, growthRate: 22.1, description: "实用主义美学，街头风格的新宠"),
        TrendItem(name: "芭蕾平底鞋", category: .shoes, zone: .trending, angle: 150, heatScore: 72, growthRate: 18.7, description: "优雅回归，法式浪漫的代表"),
        TrendItem(name: "珍珠配饰", category: .accessories, zone: .trending, angle: 210, heatScore: 70, growthRate: 12.4, description: "轻奢质感，提升整体造型档次"),
        TrendItem(name: "薄荷曼波", category: .style, zone: .trending, angle: 300, heatScore: 65, growthRate: 25.8, description: "清新甜美风，夏日氛围感拉满"),
        TrendItem(name: "丝巾上衣", category: .tops, zone: .trending, angle: 340, heatScore: 63, growthRate: 19.3, description: "法式优雅的现代演绎"),
        
        // 蓝区 - 小众潜力
        TrendItem(name: "奶奶灰针织", category: .tops, zone: .niche, angle: 60, heatScore: 42, growthRate: 45.2, description: "温柔复古色调，慢生活美学"),
        TrendItem(name: "爷爷风背心", category: .tops, zone: .niche, angle: 110, heatScore: 38, growthRate: 38.9, description: "中性风格兴起，打破性别界限"),
        TrendItem(name: "帆布鞋改造", category: .shoes, zone: .niche, angle: 170, heatScore: 35, growthRate: 52.1, description: "DIY个性化趋势，独一无二的表达"),
        TrendItem(name: "渔夫帽", category: .accessories, zone: .niche, angle: 240, heatScore: 40, growthRate: 41.7, description: "户外风格兴起，实用与时尚并重"),
        TrendItem(name: "学院风马甲", category: .tops, zone: .niche, angle: 290, heatScore: 44, growthRate: 36.3, description: "英伦学院风复兴，知识分子气质"),
        TrendItem(name: "渐变染发", category: .style, zone: .niche, angle: 330, heatScore: 47, growthRate: 28.9, description: "个性色彩表达，艺术感造型")
    ]
}
