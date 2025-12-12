//
//  ContentView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        // 配置 TabBar 全局样式
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // 透明背景
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark) // 毛玻璃效果
        appearance.backgroundColor = UIColor(Color.deepBackground.opacity(0.8))
        
        // 选中状态
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.neonGreen)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.neonGreen)
        ]
        
        // 未选中状态
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 趋势雷达
            RadarView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("RADAR")
                }
                .tag(0)
            
            // 趋势预测
            PredictionView()
                .tabItem {
                    Image(systemName: "scope")
                    Text("PREDICT")
                }
                .tag(1)
            
            // 提名新趋势
            SubmitTrendView()
                .tabItem {
                    Image(systemName: "plus.diamond.fill")
                    Text("SCOUT")
                }
                .tag(2)
            
            // 个人资料
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("PROFILE")
                }
                .tag(3)
        }
        .accentColor(.neonGreen)
        .preferredColorScheme(.dark) // 强制全应用暗黑模式
    }
}

#Preview {
    ContentView()
}
