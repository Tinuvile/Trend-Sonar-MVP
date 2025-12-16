//
//  ProfileViewModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/16.
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var styleProfile: UserStyleProfile = UserStyleProfile()
    @Published var showingEditProfile = false
    
    // MARK: - Editable User Properties
    @Published var editableUsername: String = ""
    @Published var editableBio: String = ""
    
    // MARK: - Data Manager
    private let trendManager = TrendDataManager.shared
    
    // MARK: - Initialization
    init() {
        loadUserEditableData()
    }
    
    // MARK: - Computed Properties
    var user: UserProfile {
        // 动态计算用户数据，基于TrendDataManager的实时统计
        UserProfile(
            username: editableUsername.isEmpty ? "时尚探索者" : editableUsername,
            bio: editableBio.isEmpty ? "追寻下一个时尚风潮，享受发现的乐趣" : editableBio,
            level: calculateLevel(for: trendManager.calculateUserPoints()),
            totalPoints: trendManager.calculateUserPoints(),
            successfulPredictions: trendManager.getUserPredictionHistory().filter { $0.isCorrect == true }.count,
            accuracyRate: trendManager.calculateAccuracyRate(),
            achievements: Achievement.sampleAchievements, // 简化处理，使用固定成就
            recentPredictions: Array(trendManager.getUserPredictionHistory().prefix(5))
        )
    }
    
    // MARK: - Computed Properties
    
    /// 获取用户等级标题
    func getLevelTitle() -> String {
        switch user.level {
        case 1: return "新手探索者"
        case 2: return "趋势观察员"
        case 3: return "时尚预测师"
        case 4: return "潮流引领者"
        case 5: return "时尚大师"
        default: return "传奇预言家"
        }
    }
    
    /// 获取下一等级所需经验
    func getExperienceToNextLevel() -> Int {
        let requiredPoints = getRequiredPointsForLevel(user.level + 1)
        return max(0, requiredPoints - user.totalPoints)
    }
    
    /// 获取当前等级进度 (0.0-1.0)
    func getLevelProgress() -> Double {
        let currentLevelPoints = getRequiredPointsForLevel(user.level)
        let nextLevelPoints = getRequiredPointsForLevel(user.level + 1)
        let currentProgress = user.totalPoints - currentLevelPoints
        let totalNeeded = nextLevelPoints - currentLevelPoints
        
        return totalNeeded > 0 ? Double(currentProgress) / Double(totalNeeded) : 1.0
    }
    
    /// 获取解锁的成就数量
    func getUnlockedAchievementsCount() -> Int {
        user.achievements.filter { $0.isUnlocked }.count
    }
    
    /// 获取总成就数量
    func getTotalAchievementsCount() -> Int {
        user.achievements.count
    }
    
    // MARK: - Methods
    
    /// 显示编辑资料页面
    func showEditProfile() {
        showingEditProfile = true
    }
    
    /// 隐藏编辑资料页面
    func hideEditProfile() {
        showingEditProfile = false
    }
    
    /// 加载用户可编辑数据
    private func loadUserEditableData() {
        editableUsername = UserDefaults.standard.string(forKey: "userName") ?? "时尚探索者"
        editableBio = UserDefaults.standard.string(forKey: "userBio") ?? "追寻下一个时尚风潮，享受发现的乐趣"
    }
    
    /// 更新用户资料（保存到本地存储）
    func updateUserProfile() {
        UserDefaults.standard.set(editableUsername, forKey: "userName")
        UserDefaults.standard.set(editableBio, forKey: "userBio")
        
        // 触发UI更新
        objectWillChange.send()
    }
    
    
    // MARK: - Private Methods
    
    /// 计算等级
    private func calculateLevel(for points: Int) -> Int {
        switch points {
        case 0..<100: return 1
        case 100..<300: return 2
        case 300..<600: return 3
        case 600..<1000: return 4
        case 1000..<1500: return 5
        default: return 6
        }
    }
    
    /// 获取特定等级所需积分
    private func getRequiredPointsForLevel(_ level: Int) -> Int {
        switch level {
        case 1: return 0
        case 2: return 100
        case 3: return 300
        case 4: return 600
        case 5: return 1000
        case 6: return 1500
        default: return 2000
        }
    }
    
    /// 计算准确率
    private func calculateAccuracyRate(successful: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(successful) / Double(total)) * 100)
    }
    
}

// MARK: - Sample Data Extensions
extension ProfileViewModel {
    /// 创建样本数据用于测试
    static func createSampleViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel()
        
        // 可以在这里设置测试数据
        viewModel.styleProfile = UserStyleProfile()
        viewModel.styleProfile.preferredStyles = [.minimalist, .streetwear, .casual]
        viewModel.styleProfile.favoriteBrands = [.uniqlo, .nike, .zara]
        
        return viewModel
    }
}