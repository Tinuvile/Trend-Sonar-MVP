//
//  StyleProfileModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

// 风格类型
enum StyleType: String, CaseIterable {
    case minimalist = "简约风"
    case streetwear = "街头风"
    case preppy = "学院风"
    case bohemian = "波西米亚"
    case elegant = "优雅风"
    case casual = "休闲风"
    case vintage = "复古风"
    case sporty = "运动风"
    case romantic = "浪漫风"
    case edgy = "前卫风"
    
    var icon: String {
        switch self {
        case .minimalist: return "minus.circle"
        case .streetwear: return "building.2"
        case .preppy: return "graduationcap"
        case .bohemian: return "leaf"
        case .elegant: return "sparkles"
        case .casual: return "house"
        case .vintage: return "camera.vintage"
        case .sporty: return "figure.run"
        case .romantic: return "heart"
        case .edgy: return "bolt"
        }
    }
    
    var color: Color {
        switch self {
        case .minimalist: return .gray
        case .streetwear: return .orange
        case .preppy: return .blue
        case .bohemian: return .green
        case .elegant: return .purple
        case .casual: return .cyan
        case .vintage: return .brown
        case .sporty: return .red
        case .romantic: return .pink
        case .edgy: return .yellow
        }
    }
    
    var description: String {
        switch self {
        case .minimalist: return "简洁干净，不繁复"
        case .streetwear: return "个性张扬，潮流前沿"
        case .preppy: return "知性优雅，英伦气质"
        case .bohemian: return "自由随性，艺术气息"
        case .elegant: return "精致优雅，气质出众"
        case .casual: return "舒适自在，日常百搭"
        case .vintage: return "复古怀旧，经典永恒"
        case .sporty: return "活力动感，运动健康"
        case .romantic: return "温柔甜美，浪漫情怀"
        case .edgy: return "前卫大胆，个性突出"
        }
    }
}

// 喜欢的品牌
enum FavoriteBrand: String, CaseIterable {
    case uniqlo = "优衣库"
    case zara = "Zara"
    case hm = "H&M"
    case nike = "Nike"
    case adidas = "Adidas"
    case muji = "无印良品"
    case chanel = "Chanel"
    case gucci = "Gucci"
    case converse = "匡威"
    case vans = "Vans"
    case celine = "Celine"
    case acneStudios = "Acne Studios"
    case lemaire = "Lemaire"
    case jilSander = "Jil Sander"
    case anta = "安踏"
    case lining = "李宁"
    case peacebird = "太平鸟"
    case jnby = "江南布衣"
    
    var logo: String {
        // 这里使用系统图标代替真实logo
        switch self {
        case .nike, .adidas, .anta, .lining: return "sportscourt"
        case .uniqlo, .muji: return "minus.circle"
        case .zara, .hm, .peacebird: return "bag"
        case .chanel, .gucci, .celine: return "crown"
        case .converse, .vans: return "shoe"
        case .acneStudios, .lemaire, .jilSander: return "triangle"
        case .jnby: return "leaf"
        }
    }
    
    var associatedStyles: [StyleType] {
        switch self {
        case .uniqlo, .muji: return [.minimalist, .casual]
        case .zara, .hm: return [.casual, .elegant]
        case .nike, .adidas, .anta, .lining: return [.sporty, .streetwear]
        case .chanel, .gucci, .celine: return [.elegant, .romantic]
        case .converse, .vans: return [.streetwear, .casual]
        case .acneStudios, .lemaire, .jilSander: return [.minimalist, .edgy]
        case .peacebird: return [.casual, .preppy]
        case .jnby: return [.bohemian, .vintage]
        }
    }
}

// 用户风格档案
struct UserStyleProfile {
    let id = UUID()
    var preferredStyles: [StyleType]
    var favoriteBrands: [FavoriteBrand]
    var bodyType: BodyType
    var colorPreferences: [Color]
    var budgetRange: BudgetRange
    var personalPhoto: UIImage?
    var isPhotoBased: Bool
    var lastUpdated: Date
    
    init() {
        self.preferredStyles = []
        self.favoriteBrands = []
        self.bodyType = .balanced
        self.colorPreferences = []
        self.budgetRange = .medium
        self.personalPhoto = nil
        self.isPhotoBased = false
        self.lastUpdated = Date()
    }
    
    // 计算趋势兼容性分数 (0-100)
    func compatibilityScore(for trend: TrendItem) -> Int {
        var score = 50 // 基础分数
        
        // 基于品牌偏好
        if !favoriteBrands.isEmpty {
            let brandBonus = calculateBrandCompatibility(trend: trend)
            score += brandBonus
        }
        
        // 基于风格偏好
        if !preferredStyles.isEmpty {
            let styleBonus = calculateStyleCompatibility(trend: trend)
            score += styleBonus
        }
        
        // 基于预算考虑
        let budgetBonus = calculateBudgetCompatibility(trend: trend)
        score += budgetBonus
        
        return max(0, min(100, score))
    }
    
    private func calculateBrandCompatibility(trend: TrendItem) -> Int {
        // 模拟品牌兼容性计算
        let compatibleBrands = favoriteBrands.filter { brand in
            brand.associatedStyles.contains { style in
                isStyleCompatible(style, with: trend)
            }
        }
        return compatibleBrands.isEmpty ? -10 : 15
    }
    
    private func calculateStyleCompatibility(trend: TrendItem) -> Int {
        // 模拟风格兼容性计算
        for style in preferredStyles {
            if isStyleCompatible(style, with: trend) {
                return 20
            }
        }
        return -15
    }
    
    private func calculateBudgetCompatibility(trend: TrendItem) -> Int {
        // 根据趋势的热度推断价格（热度越高，相关商品越贵）
        let estimatedCost = trend.heatScore > 80 ? BudgetRange.high : 
                          trend.heatScore > 50 ? BudgetRange.medium : BudgetRange.low
        
        return budgetRange.rawValue >= estimatedCost.rawValue ? 5 : -5
    }
    
    private func isStyleCompatible(_ style: StyleType, with trend: TrendItem) -> Bool {
        // 简化的风格匹配逻辑
        switch (style, trend.name) {
        case (.minimalist, let name) where name.contains("简约") || name.contains("基础"): return true
        case (.streetwear, let name) where name.contains("街头") || name.contains("潮"): return true
        case (.vintage, let name) where name.contains("复古") || name.contains("奶奶") || name.contains("爷爷"): return true
        case (.elegant, let name) where name.contains("优雅") || name.contains("珍珠") || name.contains("丝巾"): return true
        case (.sporty, let name) where name.contains("运动") || name.contains("帽"): return true
        default: return false
        }
    }
    
    static let defaultProfile = UserStyleProfile()
}

// 体型类型
enum BodyType: String, CaseIterable {
    case petite = "娇小型"
    case tall = "高挑型"
    case curvy = "曲线型"
    case athletic = "运动型"
    case balanced = "均衡型"
    
    var icon: String {
        switch self {
        case .petite: return "person.crop.circle"
        case .tall: return "person.crop.circle.badge.plus"
        case .curvy: return "heart.circle"
        case .athletic: return "figure.run.circle"
        case .balanced: return "circle.circle"
        }
    }
}

// 预算范围
enum BudgetRange: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case luxury = 4
    
    var title: String {
        switch self {
        case .low: return "经济型 (¥50-200)"
        case .medium: return "中等型 (¥200-500)"
        case .high: return "品质型 (¥500-1500)"
        case .luxury: return "奢华型 (¥1500+)"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .luxury: return .purple
        }
    }
}
