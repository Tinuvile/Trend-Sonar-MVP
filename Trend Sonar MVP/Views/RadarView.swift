//
//  RadarView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct RadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    
    // 现在使用 ViewModel 的计算属性
    var filteredTrends: [TrendItem] {
        viewModel.filteredTrends
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9 // 稍微放大一点
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 1. 全局背景 (使用 DesignSystem)
                Color.clear.appBackground()
                
                // 2. 雷达主体层
                ZStack {
                    // 雷达网格（传入个性化状态）
                    RadarGrid(center: center, size: size, isPersonalized: viewModel.isPersonalized, styleProfile: viewModel.styleProfile)
                    
                    // 扫描线
                    ScanningEffect(center: center, size: size, angle: viewModel.scanAngle)
                    
                    // 趋势点
                    trendsLayer(center: center, size: size)
                    
                    // 中心Logo
                    centerLabel(center: center)
                }
                
                // 3. UI 控制层 (浮层)
                VStack {
                    // 顶部类别过滤器
                    categoryFilter
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // 底部控制面板
                    personalizationControls
                        .padding(.bottom, 20)
                }
                
                // 4. 详情弹窗
                if let trend = viewModel.selectedTrend {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { viewModel.closeTrendDetail() }
                    
                    trendDetailCard(trend: trend)
                        .padding()
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .zIndex(100)
                }
            }
        }
        .onAppear {
            // 确保动画在View出现时启动
            viewModel.startScanning()
        }
        .sheet(isPresented: $viewModel.showingStyleSetup) {
            StyleSetupView(styleProfile: $viewModel.styleProfile)
                .preferredColorScheme(.dark) // 强制暗黑模式
        }
    }
    
    // MARK: - Subviews
    
    // 趋势点层
    private func trendsLayer(center: CGPoint, size: CGFloat) -> some View {
        ForEach(filteredTrends) { trend in
            let position = viewModel.calculateTrendPosition(trend: trend, center: center, size: size)
            let compatibilityScore = viewModel.styleProfile.compatibilityScore(for: trend)
            let isSelected = viewModel.selectedTrend?.id == trend.id
            
            ZStack {
                // 外发光晕 (选中或高热度时更明显)
                if isSelected || trend.heatScore > 80 {
                    Circle()
                        .fill(trend.zone.color.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .blur(radius: 5)
                }
                
                // 核心点
                Circle()
                    .fill(trend.zone.color)
                    .frame(width: viewModel.trendPointSize(trend: trend), height: viewModel.trendPointSize(trend: trend))
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 2 : 1)
                    )
                    // 霓虹发光
                    .glow(color: trend.zone.color, radius: isSelected ? 15 : 5)
                
                // 个性化兼容性指示环（增强版）
                if viewModel.isPersonalized && !viewModel.styleProfile.preferredStyles.isEmpty {
                    // 主兼容性环
                    Circle()
                        .trim(from: 0, to: CGFloat(compatibilityScore) / 100.0) // 根据兼容性比例显示
                        .stroke(
                            LinearGradient(
                                colors: [
                                    viewModel.compatibilityColor(for: compatibilityScore),
                                    viewModel.compatibilityColor(for: compatibilityScore).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: viewModel.trendPointSize(trend: trend) + 15, height: viewModel.trendPointSize(trend: trend) + 15)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: viewModel.compatibilityColor(for: compatibilityScore), radius: 5)
                    
                    // 高兼容性的额外光环
                    if compatibilityScore >= 80 {
                        Circle()
                            .stroke(
                                viewModel.compatibilityColor(for: compatibilityScore).opacity(0.4),
                                lineWidth: 1
                            )
                            .frame(width: viewModel.trendPointSize(trend: trend) + 25, height: viewModel.trendPointSize(trend: trend) + 25)
                            .scaleEffect(viewModel.pulseScale)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.pulseScale)
                    }
                    
                    // 兼容性分数标签
                    if compatibilityScore >= 70 {
                        Text("\(compatibilityScore)%")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(viewModel.compatibilityColor(for: compatibilityScore))
                                    .frame(width: 20, height: 20)
                            )
                            .offset(x: viewModel.trendPointSize(trend: trend) / 2 + 15, y: -viewModel.trendPointSize(trend: trend) / 2 - 15)
                    }
                }
            }
            .position(position)
            .scaleEffect(isSelected ? 1.5 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
            .onTapGesture {
                viewModel.selectTrend(trend)
            }
        }
    }
    
    // 中心标签
    private func centerLabel(center: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 40, height: 40)
                .shadow(color: .neonGreen.opacity(0.5), radius: 10)
            
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.neonGreen)
                .glow(color: .neonGreen, radius: 5)
        }
        .position(center)
    }
    
    // 类别过滤器
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FashionCategory.allCases, id: \.self) { category in
                    Button(action: {
                        viewModel.toggleCategoryFilter(category)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.selectedCategory == category ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == category ? Color.neonBlue : Color.white.opacity(0.1))
                        )
                        // 选中时发光
                        .shadow(color: viewModel.selectedCategory == category ? .neonBlue.opacity(0.6) : .clear, radius: 10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // 个性化控制面板（增强版）
    private var personalizationControls: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 16) {
                    // 个性化开关（增强版）
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            viewModel.togglePersonalization()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isPersonalized ? "person.fill.checkmark" : "person")
                                .font(.system(size: 16, weight: .bold))
                            Text(viewModel.isPersonalized ? "个性雷达 ON" : "全部趋势")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(viewModel.isPersonalized ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(viewModel.isPersonalized ? 
                                    LinearGradient(colors: [.neonPurple, .neonPink], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.black.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        )
                        .glow(color: viewModel.isPersonalized ? .neonPurple : .clear, radius: 10)
                        .scaleEffect(viewModel.isPersonalized ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isPersonalized)
                    }
                    
                    // 风格档案按钮
                    NavigationLink(destination: MyStyleProfileView()) {
                        Image(systemName: "wand.and.rays")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(viewModel.isPersonalized ? Color.neonPurple.opacity(0.3) : Color.white.opacity(0.1))
                            )
                            .glow(color: viewModel.isPersonalized ? .neonPurple : .clear, radius: 5)
                    }
                    
                    // 设置按钮（增强版）
                    Button(action: { viewModel.showingStyleSetup = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(viewModel.isPersonalized ? Color.neonPurple.opacity(0.3) : Color.white.opacity(0.1))
                            )
                            .glow(color: viewModel.isPersonalized ? .neonPurple : .clear, radius: 5)
                    }
                }
                
                Spacer()
                
                // 兼容性图例 (仅在个性化模式显示)
                if viewModel.isPersonalized {
                    HStack(spacing: 12) {
                        LegendItem(color: .green, text: "匹配")
                        LegendItem(color: .orange, text: "一般")
                        LegendItem(color: .red, text: "不匹配")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.neonPurple.opacity(0.2)))
                    .overlay(Capsule().stroke(Color.neonPurple.opacity(0.5), lineWidth: 1))
                }
            }
            
            // 个性化状态提示
            if viewModel.isPersonalized && !viewModel.styleProfile.preferredStyles.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.neonYellow)
                        .font(.system(size: 12))
                    
                    Text("为你推荐 \(viewModel.filteredTrends.count) 个匹配趋势")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    // 显示用户偏好的风格标签
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(viewModel.styleProfile.preferredStyles.prefix(3)), id: \.self) { style in
                                Text(style.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(style.color.opacity(0.8)))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.3)))
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // 趋势详情卡片 (增强版)
    private func trendDetailCard(trend: TrendItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题行
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trend.name)
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .glow(color: .white, radius: 2)
                    
                    HStack(spacing: 8) {
                        Text("#\(trend.category.rawValue)")
                            .font(.caption.bold())
                            .foregroundColor(trend.zone.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().stroke(trend.zone.color, lineWidth: 1))
                        
                        // 个性化匹配度标签
                        if viewModel.isPersonalized && !viewModel.styleProfile.preferredStyles.isEmpty {
                            let compatibilityScore = viewModel.styleProfile.compatibilityScore(for: trend)
                            HStack(spacing: 4) {
                                Image(systemName: compatibilityScore >= 70 ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.compatibilityColor(for: compatibilityScore))
                                Text("\(compatibilityScore)%")
                                    .font(.caption.bold())
                                    .foregroundColor(viewModel.compatibilityColor(for: compatibilityScore))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(viewModel.compatibilityColor(for: compatibilityScore).opacity(0.2)))
                            .overlay(Capsule().stroke(viewModel.compatibilityColor(for: compatibilityScore), lineWidth: 1))
                        }
                    }
                }
                
                Spacer()
                
                // 热度仪表盘
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(trend.heatScore) / 100)
                        .stroke(trend.zone.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .glow(color: trend.zone.color, radius: 5)
                    
                    Text("\(trend.heatScore)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            
            Text(trend.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            
            // 个性化推荐理由
            if viewModel.isPersonalized && !viewModel.styleProfile.preferredStyles.isEmpty {
                let compatibilityScore = viewModel.styleProfile.compatibilityScore(for: trend)
                if compatibilityScore >= 60 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 为什么推荐给你")
                            .font(.caption.bold())
                            .foregroundColor(.neonYellow)
                        
                        Text(getPersonalizedReason(for: trend))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.neonPurple.opacity(0.1))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.neonPurple.opacity(0.3), lineWidth: 1))
                            )
                    }
                }
            }
            
            // 数据行
            HStack(spacing: 20) {
                DataBadge(icon: "chart.line.uptrend.xyaxis", value: "+\(String(format: "%.1f", trend.growthRate))%", color: .neonGreen)
                DataBadge(icon: "target", value: trend.zone.rawValue, color: trend.zone.color)
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                Button("我看好它") {
                    viewModel.predictTrend(trend)
                }
                .buttonStyle(NeonSolidButtonStyle(color: .neonGreen))
                
                Button(action: { viewModel.closeTrendDetail() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(24)
        .glassCard()
        .frame(maxWidth: 340)
    }
    
    // MARK: - Helpers
    
    /// 获取个性化推荐理由
    private func getPersonalizedReason(for trend: TrendItem) -> String {
        var reasons: [String] = []
        
        // 检查风格匹配
        for style in viewModel.styleProfile.preferredStyles {
            if isStyleMatchingTrend(style, trend: trend) {
                reasons.append("符合你的\(style.rawValue)风格")
                break
            }
        }
        
        // 检查品牌偏好
        for brand in viewModel.styleProfile.favoriteBrands {
            if brand.associatedStyles.contains(where: { style in
                viewModel.styleProfile.preferredStyles.contains(style)
            }) {
                reasons.append("与你喜欢的\(brand.rawValue)品牌风格相似")
                break
            }
        }
        
        // 检查预算匹配
        let estimatedCost = trend.heatScore > 80 ? BudgetRange.high : 
                          trend.heatScore > 50 ? BudgetRange.medium : BudgetRange.low
        if viewModel.styleProfile.budgetRange.rawValue >= estimatedCost.rawValue {
            reasons.append("价位符合你的预算范围")
        }
        
        // 检查热度
        if trend.heatScore < 60 {
            reasons.append("小众趋势，符合你的独特品味")
        }
        
        return reasons.isEmpty ? "基于你的整体偏好推荐" : reasons.joined(separator: " • ")
    }
    
    /// 检查风格是否匹配趋势
    private func isStyleMatchingTrend(_ style: StyleType, trend: TrendItem) -> Bool {
        switch (style, trend.name.lowercased()) {
        case (.minimalist, let name) where name.contains("简约") || name.contains("基础"): return true
        case (.streetwear, let name) where name.contains("街头") || name.contains("潮"): return true
        case (.vintage, let name) where name.contains("复古") || name.contains("奶奶") || name.contains("爷爷"): return true
        case (.elegant, let name) where name.contains("优雅") || name.contains("珍珠") || name.contains("丝巾"): return true
        case (.sporty, let name) where name.contains("运动") || name.contains("帽") || name.contains("鞋"): return true
        case (.casual, let name) where name.contains("休闲") || name.contains("日常"): return true
        default: return false
        }
    }
}

// MARK: - Components

struct RadarGrid: View {
    let center: CGPoint
    let size: CGFloat
    let isPersonalized: Bool
    let styleProfile: UserStyleProfile
    
    var body: some View {
        ZStack {
            // 背景深色圆
            Circle()
                .fill(RadialGradient(colors: [Color.deepBackground, .black], center: .center, startRadius: 0, endRadius: size/2))
                .frame(width: size, height: size)
                .position(center)
            
            // 个性化背景区域（仅在个性化模式显示）
            if isPersonalized && !styleProfile.preferredStyles.isEmpty {
                // 我的兴趣区域高亮
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color.neonPurple.opacity(0.05),
                            Color.neonPurple.opacity(0.02),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.8 / 2
                    ))
                    .frame(width: size * 0.8, height: size * 0.8)
                    .position(center)
                
                // 个性化标识文字
                Text("MY ZONE")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.neonPurple.opacity(0.6))
                    .position(x: center.x, y: center.y - size * 0.35)
                    .glow(color: .neonPurple, radius: 3)
            }
            
            // 同心圆 (个性化模式下用不同颜色)
            ForEach([0.3, 0.6, 1.0], id: \.self) { scale in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isPersonalized ? 
                            [.neonPurple.opacity(0.1), .neonPurple.opacity(0.3), .neonPurple.opacity(0.1)] :
                            [.white.opacity(0.05), .white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isPersonalized ? 2 : 1
                    )
                    .frame(width: size * scale, height: size * scale)
                    .position(center)
            }
            
            // 十字线（个性化模式下更明显）
            Path { path in
                path.move(to: CGPoint(x: center.x - size/2, y: center.y))
                path.addLine(to: CGPoint(x: center.x + size/2, y: center.y))
                path.move(to: CGPoint(x: center.x, y: center.y - size/2))
                path.addLine(to: CGPoint(x: center.x, y: center.y + size/2))
            }
            .stroke(
                isPersonalized ? Color.neonPurple.opacity(0.3) : Color.white.opacity(0.1),
                style: StrokeStyle(lineWidth: isPersonalized ? 2 : 1, dash: [5, 5])
            )
            
            // 区域标签
            ZoneLabel(text: "NICHE", color: TrendZone.niche.color, yOffset: -size * 0.45, isPersonalized: isPersonalized)
            ZoneLabel(text: "TRENDING", color: TrendZone.trending.color, yOffset: -size * 0.25, isPersonalized: isPersonalized)
            ZoneLabel(text: "HOT", color: TrendZone.mainstream.color, yOffset: -size * 0.1, isPersonalized: isPersonalized)
        }
    }
    
    @ViewBuilder
    func ZoneLabel(text: String, color: Color, yOffset: CGFloat, isPersonalized: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(isPersonalized ? color.opacity(0.9) : color.opacity(0.7))
            .position(x: center.x, y: center.y + yOffset)
            .glow(color: isPersonalized ? color : .clear, radius: isPersonalized ? 2 : 0)
    }
}

struct ScanningEffect: View {
    let center: CGPoint
    let size: CGFloat
    let angle: Double
    
    var body: some View {
        ZStack {
            // 扇形扫描
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [.clear, .neonGreen.opacity(0.05), .neonGreen.opacity(0.3)]),
                        center: .center,
                        startAngle: .degrees(angle - 90),
                        endAngle: .degrees(angle)
                    )
                )
                .frame(width: size, height: size)
                .position(center)
            
            // 扫描线高亮
            Path { path in
                path.move(to: center)
                let endPoint = CGPoint(
                    x: center.x + cos(angle * .pi / 180) * size / 2,
                    y: center.y + sin(angle * .pi / 180) * size / 2
                )
                path.addLine(to: endPoint)
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.neonGreen, .clear]),
                    startPoint: .center,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .shadow(color: .neonGreen, radius: 5)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .glow(color: color, radius: 4)
            Text(text)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct DataBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }
}

#Preview {
    RadarView()
        .preferredColorScheme(.dark)
}
