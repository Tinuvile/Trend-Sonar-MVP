//
//  ContentView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 趋势雷达 - 主页面
            RadarView()
                .tabItem {
                    Image(systemName: "radar")
                    Text("雷达")
                }
                .tag(0)
            
            // 趋势预测
            PredictionView()
                .tabItem {
                    Image(systemName: "target")
                    Text("预测")
                }
                .tag(1)
            
            // 提名新趋势
            SubmitTrendView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("提名")
                }
                .tag(2)
            
            // 个人资料
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("我的")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        // 设置 TabBar 样式
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // 设置选中和未选中的颜色
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
