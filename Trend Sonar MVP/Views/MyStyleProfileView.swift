//
//  MyStyleProfileView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/16.
//

import SwiftUI

struct MyStyleProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var trendManager = TrendDataManager.shared
    @State private var selectedStyleForDetail: StyleType?
    @State private var showingStyleSetup = false
    
    var body: some View {
        ZStack {
            // 背景
            Color.clear.appBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 头部 - 我的风格雷达
                    styleRadarSection
                    
                    // 风格偏好标签
                    styleTagsSection
                    
                    // 品牌偏好
                    brandPreferencesSection
                    
                    // 兼容性分析
                    compatibilityAnalysisSection
                    
                    // 个性化推荐
                    personalizedRecommendationsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("我的风格档案")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") {
                    showingStyleSetup = true
                }
                .foregroundColor(.neonBlue)
            }
        }
        .sheet(isPresented: $showingStyleSetup) {
            StyleSetupView(styleProfile: $profileViewModel.styleProfile)
                .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - 风格雷达区域
    private var styleRadarSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的风格雷达")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("基于你的偏好生成的个性化雷达")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("匹配度")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("\(averageCompatibilityScore())%")
                        .font(.headline.bold().monospaced())
                        .foregroundColor(.neonGreen)
                }
            }
            
            // 个性化雷达图
            personalizedRadarChart
        }
        .padding()
        .glassCard()
    }
    
    // 个性化雷达图
    private var personalizedRadarChart: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 背景网格
                PersonalizedRadarGrid(center: center, size: size)
                
                // 我的风格区域高亮
                if !profileViewModel.styleProfile.preferredStyles.isEmpty {
                    MyStyleZones(
                        center: center,
                        size: size,
                        preferredStyles: profileViewModel.styleProfile.preferredStyles
                    )
                }
                
                // 兼容的趋势点
                compatibleTrendsLayer(center: center, size: size)
                
                // 中心标识
                personalizedCenterLabel(center: center)
            }
        }
        .frame(height: 280)
    }
    
    // 兼容趋势点层
    private func compatibleTrendsLayer(center: CGPoint, size: CGFloat) -> some View {
        ForEach(getCompatibleTrends()) { trend in
            let position = calculateTrendPosition(trend: trend, center: center, size: size)
            let compatibilityScore = profileViewModel.styleProfile.compatibilityScore(for: trend)
            
            ZStack {
                // 兼容性光晕
                Circle()
                    .fill(compatibilityColorForScore(compatibilityScore).opacity(0.3))
                    .frame(width: 20, height: 20)
                    .blur(radius: 3)
                
                // 趋势点
                Circle()
                    .fill(compatibilityColorForScore(compatibilityScore))
                    .frame(width: 8, height: 8)
                    .glow(color: compatibilityColorForScore(compatibilityScore), radius: 4)
            }
            .position(position)
        }
    }
    
    // 个性化中心标签
    private func personalizedCenterLabel(center: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle().stroke(Color.neonPurple, lineWidth: 2)
                )
            
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundColor(.neonPurple)
                .glow(color: .neonPurple, radius: 5)
        }
        .position(center)
    }
    
    // MARK: - 风格标签区域
    private var styleTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("我的风格偏好")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(profileViewModel.styleProfile.preferredStyles.count) 种风格")
                    .font(.caption.monospaced())
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if profileViewModel.styleProfile.preferredStyles.isEmpty {
                emptyStylesPrompt
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(profileViewModel.styleProfile.preferredStyles, id: \.self) { style in
                        MyStyleTagCard(
                            style: style,
                            compatibilityCount: getCompatibleTrendsCount(for: style)
                        ) {
                            selectedStyleForDetail = style
                        }
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    // 空状态提示
    private var emptyStylesPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text("还没有设置风格偏好")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
            
            Button("立即设置") {
                showingStyleSetup = true
            }
            .buttonStyle(NeonButtonStyle(color: .neonPurple))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - 品牌偏好区域
    private var brandPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("我喜欢的品牌")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(profileViewModel.styleProfile.favoriteBrands.count) 个品牌")
                    .font(.caption.monospaced())
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if profileViewModel.styleProfile.favoriteBrands.isEmpty {
                emptyBrandsPrompt
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(profileViewModel.styleProfile.favoriteBrands, id: \.self) { brand in
                            MyBrandCard(brand: brand)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    // 品牌空状态
    private var emptyBrandsPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.3))
            
            Text("添加喜欢的品牌，获得更精准的推荐")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - 兼容性分析区域
    private var compatibilityAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("兼容性分析")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                CompatibilityStatsRow(
                    title: "高兼容度趋势",
                    count: getHighCompatibilityCount(),
                    color: .neonGreen,
                    icon: "target"
                )
                
                CompatibilityStatsRow(
                    title: "中等兼容度趋势", 
                    count: getMediumCompatibilityCount(),
                    color: .neonYellow,
                    icon: "circle.dotted"
                )
                
                CompatibilityStatsRow(
                    title: "平均匹配度",
                    count: averageCompatibilityScore(),
                    color: .neonBlue,
                    icon: "chart.bar.fill",
                    showPercentage: true
                )
            }
        }
        .padding()
        .glassCard()
    }
    
    // MARK: - 个性化推荐区域
    private var personalizedRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("为你推荐")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("基于你的风格偏好")
                    .font(.caption)
                    .foregroundColor(.neonBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().stroke(Color.neonBlue, lineWidth: 1))
            }
            
            let recommendedTrends = getPersonalizedRecommendations()
            
            if recommendedTrends.isEmpty {
                emptyRecommendationsPrompt
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendedTrends) { trend in
                            PersonalizedTrendCard(
                                trend: trend,
                                compatibilityScore: profileViewModel.styleProfile.compatibilityScore(for: trend)
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    // 推荐空状态
    private var emptyRecommendationsPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.3))
            
            Text("完善风格设置后，将为你推荐更匹配的趋势")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Methods
    
    private func getCompatibleTrends() -> [TrendItem] {
        trendManager.radarTrends.filter { trend in
            profileViewModel.styleProfile.compatibilityScore(for: trend) >= 60
        }
    }
    
    private func getCompatibleTrendsCount(for style: StyleType) -> Int {
        // 简化计算：根据风格名称匹配
        return trendManager.radarTrends.filter { trend in
            trend.name.contains(style.rawValue.dropLast()) || 
            (style == .minimalist && (trend.name.contains("简约") || trend.name.contains("基础"))) ||
            (style == .streetwear && trend.name.contains("街头")) ||
            (style == .vintage && (trend.name.contains("复古") || trend.name.contains("奶奶") || trend.name.contains("爷爷")))
        }.count
    }
    
    private func getPersonalizedRecommendations() -> [TrendItem] {
        let compatible = getCompatibleTrends()
        return Array(compatible.sorted { 
            profileViewModel.styleProfile.compatibilityScore(for: $0) > 
            profileViewModel.styleProfile.compatibilityScore(for: $1)
        }.prefix(6))
    }
    
    private func calculateTrendPosition(trend: TrendItem, center: CGPoint, size: CGFloat) -> CGPoint {
        let radius = (size / 2) * trend.distance
        let x = center.x + cos(trend.angle * .pi / 180) * radius
        let y = center.y + sin(trend.angle * .pi / 180) * radius
        return CGPoint(x: x, y: y)
    }
    
    private func compatibilityColorForScore(_ score: Int) -> Color {
        switch score {
        case 80...100: return .neonGreen
        case 60...79: return .neonYellow  
        case 40...59: return .orange
        default: return .red
        }
    }
    
    private func averageCompatibilityScore() -> Int {
        let allTrends = trendManager.radarTrends
        guard !allTrends.isEmpty else { return 0 }
        
        let totalScore = allTrends.reduce(0) { total, trend in
            total + profileViewModel.styleProfile.compatibilityScore(for: trend)
        }
        
        return totalScore / allTrends.count
    }
    
    private func getHighCompatibilityCount() -> Int {
        trendManager.radarTrends.filter { 
            profileViewModel.styleProfile.compatibilityScore(for: $0) >= 80 
        }.count
    }
    
    private func getMediumCompatibilityCount() -> Int {
        trendManager.radarTrends.filter { 
            let score = profileViewModel.styleProfile.compatibilityScore(for: $0)
            return score >= 60 && score < 80
        }.count
    }
}

// MARK: - 个性化雷达网格
struct PersonalizedRadarGrid: View {
    let center: CGPoint
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // 背景深色圆
            Circle()
                .fill(RadialGradient(
                    colors: [Color.deepBackground.opacity(0.8), .black.opacity(0.9)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size/2
                ))
                .frame(width: size, height: size)
                .position(center)
            
            // 同心圆
            ForEach([0.3, 0.6, 1.0], id: \.self) { scale in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.neonPurple.opacity(0.1), .neonPurple.opacity(0.3), .neonPurple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: size * scale, height: size * scale)
                    .position(center)
            }
            
            // 个性化网格线
            Path { path in
                path.move(to: CGPoint(x: center.x - size/2, y: center.y))
                path.addLine(to: CGPoint(x: center.x + size/2, y: center.y))
                path.move(to: CGPoint(x: center.x, y: center.y - size/2))
                path.addLine(to: CGPoint(x: center.x, y: center.y + size/2))
            }
            .stroke(Color.neonPurple.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
    }
}

// MARK: - 我的风格区域
struct MyStyleZones: View {
    let center: CGPoint
    let size: CGFloat
    let preferredStyles: [StyleType]
    
    var body: some View {
        ForEach(Array(preferredStyles.enumerated()), id: \.offset) { index, style in
            let angle = Double(index) * (360.0 / Double(preferredStyles.count))
            let zoneRadius = size * 0.25
            
            // 风格区域高亮
            Circle()
                .fill(
                    RadialGradient(
                        colors: [style.color.opacity(0.3), style.color.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: zoneRadius/2
                    )
                )
                .frame(width: zoneRadius, height: zoneRadius)
                .position(
                    x: center.x + cos(angle * .pi / 180) * size * 0.4,
                    y: center.y + sin(angle * .pi / 180) * size * 0.4
                )
            
            // 风格标签
            Text(style.rawValue)
                .font(.caption2.bold())
                .foregroundColor(style.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(style.color.opacity(0.2)))
                .position(
                    x: center.x + cos(angle * .pi / 180) * size * 0.45,
                    y: center.y + sin(angle * .pi / 180) * size * 0.45
                )
        }
    }
}

// MARK: - 风格标签卡片
struct MyStyleTagCard: View {
    let style: StyleType
    let compatibilityCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(style.color)
                    
                    Spacer()
                    
                    Text("\(compatibilityCount)")
                        .font(.caption.bold().monospaced())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(style.description)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 品牌图标组件
struct BrandIcon: View {
    let brand: FavoriteBrand
    let size: CGFloat
    
    init(brand: FavoriteBrand, size: CGFloat = 20) {
        self.brand = brand
        self.size = size
    }
    
    var body: some View {
        // 尝试加载自定义图标，失败则使用系统图标
        if let customLogoName = brand.customLogoName,
           let customImage = UIImage(named: customLogoName) {
            Image(uiImage: customImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            Image(systemName: brand.systemFallbackIcon)
                .font(.system(size: size * 0.8))
                .foregroundColor(.white)
        }
    }
}

// MARK: - 品牌卡片
struct MyBrandCard: View {
    let brand: FavoriteBrand
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                BrandIcon(brand: brand, size: 24)
            }
            
            Text(brand.rawValue)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
    }
}

// MARK: - 兼容性统计行
struct CompatibilityStatsRow: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    let showPercentage: Bool
    
    init(title: String, count: Int, color: Color, icon: String, showPercentage: Bool = false) {
        self.title = title
        self.count = count
        self.color = color
        self.icon = icon
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)\(showPercentage ? "%" : "")")
                .font(.subheadline.bold().monospaced())
                .foregroundColor(color)
        }
    }
}

// MARK: - 个性化趋势卡片
struct PersonalizedTrendCard: View {
    let trend: TrendItem
    let compatibilityScore: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: trend.category.icon)
                    .font(.title3)
                    .foregroundColor(trend.zone.color)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(compatibilityScore)%")
                        .font(.caption.bold().monospaced())
                        .foregroundColor(compatibilityColorForScore(compatibilityScore))
                    
                    Text("匹配")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Text(trend.name)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack {
                Text("+\(String(format: "%.1f", trend.growthRate))%")
                    .font(.caption.monospaced())
                    .foregroundColor(.neonGreen)
                
                Spacer()
                
                Text(trend.zone.rawValue)
                    .font(.caption2)
                    .foregroundColor(trend.zone.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(trend.zone.color.opacity(0.2)))
            }
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(compatibilityColorForScore(compatibilityScore).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func compatibilityColorForScore(_ score: Int) -> Color {
        switch score {
        case 80...100: return .neonGreen
        case 60...79: return .neonYellow  
        case 40...59: return .orange
        default: return .red
        }
    }
}

#Preview {
    NavigationView {
        MyStyleProfileView()
            .preferredColorScheme(.dark)
    }
}
