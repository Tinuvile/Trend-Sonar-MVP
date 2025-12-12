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
    
    var filteredTrends: [TrendItem] {
        if let category = selectedCategory {
            return trends.filter { $0.category == category }
        }
        return trends
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
                
                // 趋势详情卡片
                if let trend = selectedTrend {
                    trendDetailCard(trend: trend)
                }
            }
        }
        .onAppear {
            startScanning()
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
            
            Circle()
                .fill(trend.zone.color)
                .frame(width: trendPointSize(trend: trend), height: trendPointSize(trend: trend))
                .position(position)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: selectedTrend?.id == trend.id ? 2 : 1)
                        .frame(width: trendPointSize(trend: trend), height: trendPointSize(trend: trend))
                        .position(position)
                )
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
