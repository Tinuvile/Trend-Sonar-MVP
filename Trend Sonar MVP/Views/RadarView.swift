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
            let size = min(geometry.size.width, geometry.size.height) * 0.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 背景渐变
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.7),
                        Color.black
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
                .ignoresSafeArea()
                
                // 雷达圆环
                radarRings(center: center, size: size)
                
                // 扫描线
                scanningLine(center: center, size: size)
                
                // 趋势点
                trendsLayer(center: center, size: size)
                
                // 中心标题
                centerLabel(center: center)
                
                // 类别过滤器
                categoryFilter
                
                // 个性化过滤器
                personalizationControls
                
                // 趋势详情卡片
                if let trend = selectedTrend {
                    trendDetailCard(trend: trend)
                }
            }
        }
        .onAppear {
            startScanning()
        }
        .sheet(isPresented: $showingStyleSetup) {
            StyleSetupView(styleProfile: $styleProfile)
        }
    }
    
    // 雷达圆环
    private func radarRings(center: CGPoint, size: CGFloat) -> some View {
        ZStack {
            // 蓝区 - 小众
            Circle()
                .stroke(TrendZone.niche.color, lineWidth: 2)
                .frame(width: size, height: size)
                .position(center)
            
            Circle()
                .fill(TrendZone.niche.color.opacity(0.1))
                .frame(width: size, height: size)
                .position(center)
            
            // 黄区 - 先锋
            Circle()
                .stroke(TrendZone.trending.color, lineWidth: 2)
                .frame(width: size * 0.6, height: size * 0.6)
                .position(center)
            
            Circle()
                .fill(TrendZone.trending.color.opacity(0.15))
                .frame(width: size * 0.6, height: size * 0.6)
                .position(center)
            
            // 红区 - 主流
            Circle()
                .stroke(TrendZone.mainstream.color, lineWidth: 3)
                .frame(width: size * 0.3, height: size * 0.3)
                .position(center)
            
            Circle()
                .fill(TrendZone.mainstream.color.opacity(0.2))
                .frame(width: size * 0.3, height: size * 0.3)
                .position(center)
            
            // 十字线
            Path { path in
                path.move(to: CGPoint(x: center.x - size/2, y: center.y))
                path.addLine(to: CGPoint(x: center.x + size/2, y: center.y))
                path.move(to: CGPoint(x: center.x, y: center.y - size/2))
                path.addLine(to: CGPoint(x: center.x, y: center.y + size/2))
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
    
    // 扫描线
    private func scanningLine(center: CGPoint, size: CGFloat) -> some View {
        Path { path in
            path.move(to: center)
            let endPoint = CGPoint(
                x: center.x + cos(scanAngle * .pi / 180) * size / 2,
                y: center.y + sin(scanAngle * .pi / 180) * size / 2
            )
            path.addLine(to: endPoint)
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 2
        )
        .opacity(isScanning ? 0.8 : 0)
    }
    
    // 趋势点层
    private func trendsLayer(center: CGPoint, size: CGFloat) -> some View {
        ForEach(filteredTrends) { trend in
            let position = calculateTrendPosition(trend: trend, center: center, size: size)
            let compatibilityScore = styleProfile.compatibilityScore(for: trend)
            
            ZStack {
                // 主趋势点
                Circle()
                    .fill(trend.zone.color)
                    .frame(width: trendPointSize(trend: trend), height: trendPointSize(trend: trend))
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: selectedTrend?.id == trend.id ? 2 : 1)
                    )
                
                // 个性化兼容性指示环
                if isPersonalized && !styleProfile.preferredStyles.isEmpty {
                    Circle()
                        .stroke(
                            compatibilityColor(for: compatibilityScore),
                            lineWidth: 3
                        )
                        .frame(width: trendPointSize(trend: trend) + 6, height: trendPointSize(trend: trend) + 6)
                        .opacity(0.8)
                }
            }
            .position(position)
            .scaleEffect(selectedTrend?.id == trend.id ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedTrend?.id)
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedTrend = selectedTrend?.id == trend.id ? nil : trend
                }
            }
        }
    }
    
    // 中心标签
    private func centerLabel(center: CGPoint) -> some View {
        VStack {
            Image(systemName: "radar")
                .font(.title2)
                .foregroundColor(.green)
            
            Text("TrendSonar")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .position(center)
    }
    
    // 类别过滤器
    private var categoryFilter: some View {
        VStack {
            HStack {
                ForEach(FashionCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16))
                            Text(category.rawValue)
                                .font(.caption2)
                        }
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory == category ? 
                                     Color.blue.opacity(0.3) : 
                                     Color.black.opacity(0.3))
                        )
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
    
    // 个性化控制面板
    private var personalizationControls: some View {
        VStack {
            Spacer()
            
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
                            .font(.system(size: 16))
                        Text(isPersonalized ? "个性化" : "全部")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isPersonalized ? .white : .gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isPersonalized ? 
                                 Color.purple.opacity(0.8) : 
                                 Color.black.opacity(0.3))
                    )
                }
                
                // 设置按钮
                Button(action: {
                    showingStyleSetup = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                        )
                }
                
                Spacer()
                
                // 兼容性说明
                if isPersonalized && !styleProfile.preferredStyles.isEmpty {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("适合")
                        
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("一般")
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("不适合")
                    }
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    // 趋势详情卡片
    private func trendDetailCard(trend: TrendItem) -> some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trend.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(trend.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(trend.heatScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(trend.zone.color)
                        
                        Text("热度")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(trend.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Label("\(trend.growthRate > 0 ? "+" : "")\(String(format: "%.1f", trend.growthRate))%", 
                          systemImage: trend.growthRate > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                        .foregroundColor(trend.growthRate > 0 ? .green : .red)
                    
                    Spacer()
                    
                    // 个性化兼容性分数
                    if isPersonalized && !styleProfile.preferredStyles.isEmpty {
                        let compatibilityScore = styleProfile.compatibilityScore(for: trend)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(compatibilityColor(for: compatibilityScore))
                                .frame(width: 8, height: 8)
                            Text("匹配度 \(compatibilityScore)%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                        )
                    }
                    
                    Text(trend.zone.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(trend.zone.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().stroke(trend.zone.color, lineWidth: 1))
                }
                
                HStack(spacing: 8) {
                    Button("我看好它") {
                        // 预测功能
                        withAnimation {
                            selectedTrend = nil
                        }
                    }
                    .buttonStyle(TrendButtonStyle(color: .green))
                    
                    Button("不感兴趣") {
                        withAnimation {
                            selectedTrend = nil
                        }
                    }
                    .buttonStyle(TrendButtonStyle(color: .gray))
                    
                    Spacer()
                    
                    Button("关闭") {
                        withAnimation {
                            selectedTrend = nil
                        }
                    }
                    .buttonStyle(TrendButtonStyle(color: .blue))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(trend.zone.color.opacity(0.5), lineWidth: 1)
                    )
            )
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // 计算趋势在雷达上的位置
    private func calculateTrendPosition(trend: TrendItem, center: CGPoint, size: CGFloat) -> CGPoint {
        let radius = (size / 2) * trend.distance
        let x = center.x + cos(trend.angle * .pi / 180) * radius
        let y = center.y + sin(trend.angle * .pi / 180) * radius
        return CGPoint(x: x, y: y)
    }
    
    // 趋势点大小
    private func trendPointSize(trend: TrendItem) -> CGFloat {
        return 8 + CGFloat(trend.heatScore) / 10
    }
    
    // 开始扫描动画
    private func startScanning() {
        isScanning = true
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            scanAngle = 360
        }
    }
    
    // 兼容性颜色
    private func compatibilityColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

// 自定义按钮样式
struct TrendButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(configuration.isPressed ? 0.8 : 0.6))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    RadarView()
}
