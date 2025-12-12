//
//  DesignSystem.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

// MARK: - 颜色系统
extension Color {
    static let deepBackground = Color(red: 0.05, green: 0.05, blue: 0.08) // 深邃黑蓝
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.6) // 卡片底色
    
    // 霓虹色系
    static let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    static let neonPurple = Color(red: 0.8, green: 0.2, blue: 1.0)
    static let neonBlue = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let neonPink = Color(red: 1.0, green: 0.2, blue: 0.7)
    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.2)
    
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
}

// MARK: - 视图修饰符

// 发光效果
struct Glow: ViewModifier {
    var color: Color
    var radius: CGFloat
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius / 3, x: 0, y: 0)
            .shadow(color: color.opacity(opacity * 0.7), radius: radius, x: 0, y: 0)
    }
}

// 毛玻璃卡片样式
struct GlassCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial) // 使用系统材质
            .background(Color.deepBackground.opacity(0.5)) // 混合一层深色
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// 霓虹边框按钮样式
struct NeonButtonStyle: ButtonStyle {
    var color: Color = .neonBlue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    Color.black.opacity(0.6)
                    
                    if configuration.isPressed {
                        color.opacity(0.2)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: 2)
                    .glow(color: color, radius: 10, opacity: configuration.isPressed ? 0.8 : 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 实心霓虹按钮样式
struct NeonSolidButtonStyle: ButtonStyle {
    var color: Color = .neonGreen
    var textColor: Color = .black
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glow(color: color, radius: 15, opacity: 0.6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 20, opacity: Double = 1.0) -> some View {
        self.modifier(Glow(color: color, radius: radius, opacity: opacity))
    }
    
    func glassCard() -> some View {
        self.modifier(GlassCardStyle())
    }
    
    func appBackground() -> some View {
        self.background(
            ZStack {
                Color.deepBackground.ignoresSafeArea()
                
                // 氛围光
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.neonPurple.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .position(x: 0, y: 0)
                    
                    Circle()
                        .fill(Color.neonBlue.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .position(x: proxy.size.width, y: proxy.size.height * 0.4)
                }
                .ignoresSafeArea()
            }
        )
    }
}

