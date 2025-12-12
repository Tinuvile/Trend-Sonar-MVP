//
//  RadarView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct RadarView: View {
    @State private var trends: [TrendItem] = TrendItem.sampleData
    @State private var selectedTrend: TrendItem?
    @State private var isScanning = false
    @State private var scanAngle: Double = 0
    @State private var selectedCategory: FashionCategory?
    @State private var styleProfile = UserStyleProfile()
    @State private var showingStyleSetup = false
    @State private var isPersonalized = false
    
    // 动画状态
    @State private var pulseScale: CGFloat = 1.0
    
    var filteredTrends: [TrendItem] {
        var baseTrends = trends
        
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
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9 // 稍微放大一点
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 1. 全局背景 (使用 DesignSystem)
                Color.clear.appBackground()
                
                // 2. 雷达主体层
                ZStack {
                    // 雷达网格
                    RadarGrid(center: center, size: size)
                    
                    // 扫描线
                    ScanningEffect(center: center, size: size, angle: scanAngle)
                    
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
                if let trend = selectedTrend {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { withAnimation { selectedTrend = nil } }
                    
                    trendDetailCard(trend: trend)
                        .padding()
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .zIndex(100)
                }
            }
        }
        .onAppear {
            startScanning()
        }
        .sheet(isPresented: $showingStyleSetup) {
            StyleSetupView(styleProfile: $styleProfile)
                .preferredColorScheme(.dark) // 强制暗黑模式
        }
    }
    
    // MARK: - Subviews
    
    // 趋势点层
    private func trendsLayer(center: CGPoint, size: CGFloat) -> some View {
        ForEach(filteredTrends) { trend in
            let position = calculateTrendPosition(trend: trend, center: center, size: size)
            let compatibilityScore = styleProfile.compatibilityScore(for: trend)
            let isSelected = selectedTrend?.id == trend.id
            
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
                    .frame(width: trendPointSize(trend: trend), height: trendPointSize(trend: trend))
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 2 : 1)
                    )
                    // 霓虹发光
                    .glow(color: trend.zone.color, radius: isSelected ? 15 : 5)
                
                // 个性化兼容性指示环
                if isPersonalized && !styleProfile.preferredStyles.isEmpty {
                    Circle()
                        .trim(from: 0, to: 0.8) // 缺口环设计
                        .stroke(
                            compatibilityColor(for: compatibilityScore),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: trendPointSize(trend: trend) + 10, height: trendPointSize(trend: trend) + 10)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: compatibilityColor(for: compatibilityScore), radius: 3)
                }
            }
            .position(position)
            .scaleEffect(isSelected ? 1.5 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedTrend = selectedTrend?.id == trend.id ? nil : trend
                }
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
                        withAnimation(.easeInOut) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedCategory == category ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? Color.neonBlue : Color.white.opacity(0.1))
                        )
                        // 选中时发光
                        .shadow(color: selectedCategory == category ? .neonBlue.opacity(0.6) : .clear, radius: 10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // 个性化控制面板
    private var personalizationControls: some View {
        HStack {
            HStack(spacing: 16) {
                // 个性化开关
                Button(action: {
                    withAnimation(.easeInOut) {
                        if !styleProfile.preferredStyles.isEmpty {
                            isPersonalized.toggle()
                        } else {
                            showingStyleSetup = true
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isPersonalized ? "person.fill.checkmark" : "person")
                        Text(isPersonalized ? "个性雷达 ON" : "全部趋势")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isPersonalized ? .black : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(isPersonalized ? Color.neonPurple : Color.black.opacity(0.5))
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    )
                    .glow(color: isPersonalized ? .neonPurple : .clear, radius: 10)
                }
                
                // 设置按钮
                Button(action: { showingStyleSetup = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
            
            Spacer()
            
            // 兼容性图例 (仅在个性化模式显示)
            if isPersonalized {
                HStack(spacing: 12) {
                    LegendItem(color: .green, text: "High")
                    LegendItem(color: .orange, text: "Mid")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.black.opacity(0.4)))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // 趋势详情卡片 (悬浮样式)
    private func trendDetailCard(trend: TrendItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题行
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trend.name)
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .glow(color: .white, radius: 2)
                    
                    Text("#\(trend.category.rawValue)")
                        .font(.caption.bold())
                        .foregroundColor(trend.zone.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().stroke(trend.zone.color, lineWidth: 1))
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
            
            // 数据行
            HStack(spacing: 20) {
                DataBadge(icon: "chart.line.uptrend.xyaxis", value: "+\(String(format: "%.1f", trend.growthRate))%", color: .neonGreen)
                DataBadge(icon: "target", value: trend.zone.rawValue, color: trend.zone.color)
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                Button("我看好它") {
                    withAnimation { selectedTrend = nil }
                    // 触发震动反馈
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                .buttonStyle(NeonSolidButtonStyle(color: .neonGreen))
                
                Button(action: { withAnimation { selectedTrend = nil } }) {
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
    private func calculateTrendPosition(trend: TrendItem, center: CGPoint, size: CGFloat) -> CGPoint {
        let radius = (size / 2) * trend.distance
        let x = center.x + cos(trend.angle * .pi / 180) * radius
        let y = center.y + sin(trend.angle * .pi / 180) * radius
        return CGPoint(x: x, y: y)
    }
    
    private func trendPointSize(trend: TrendItem) -> CGFloat {
        return 8 + CGFloat(trend.heatScore) / 8
    }
    
    private func startScanning() {
        isScanning = true
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            scanAngle = 360
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
    
    private func compatibilityColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

// MARK: - Components

struct RadarGrid: View {
    let center: CGPoint
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // 背景深色圆
            Circle()
                .fill(RadialGradient(colors: [Color.deepBackground, .black], center: .center, startRadius: 0, endRadius: size/2))
                .frame(width: size, height: size)
                .position(center)
            
            // 同心圆 (虚线科技感)
            ForEach([0.3, 0.6, 1.0], id: \.self) { scale in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.05), .white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: size * scale, height: size * scale)
                    .position(center)
            }
            
            // 十字线
            Path { path in
                path.move(to: CGPoint(x: center.x - size/2, y: center.y))
                path.addLine(to: CGPoint(x: center.x + size/2, y: center.y))
                path.move(to: CGPoint(x: center.x, y: center.y - size/2))
                path.addLine(to: CGPoint(x: center.x, y: center.y + size/2))
            }
            .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            
            // 区域标签
            ZoneLabel(text: "NICHE", color: TrendZone.niche.color, yOffset: -size * 0.45)
            ZoneLabel(text: "TRENDING", color: TrendZone.trending.color, yOffset: -size * 0.25)
            ZoneLabel(text: "HOT", color: TrendZone.mainstream.color, yOffset: -size * 0.1)
        }
    }
    
    @ViewBuilder
    func ZoneLabel(text: String, color: Color, yOffset: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(color.opacity(0.7))
            .position(x: center.x, y: center.y + yOffset)
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
