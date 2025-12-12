//
//  ProfileViewModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: UserProfile = UserProfile.sampleUser
    @Published var showingEditProfile = false
    @Published var styleProfile = UserStyleProfile.defaultProfile
    
    // MARK: - Computed Properties
    var unlockedAchievements: [Achievement] {
        user.achievements.filter { $0.isUnlocked }
    }
    
    var achievementProgress: Double {
        let totalAchievements = user.achievements.count
        let unlockedCount = unlockedAchievements.count
        guard totalAchievements > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalAchievements)
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
    
    /// 更新用户信息
    func updateUser(username: String, bio: String) {
        // 在真实应用中，这里会调用API更新用户信息
        // 现在只是模拟更新
        user = UserProfile(
            username: username,
            bio: bio,
            level: user.level,
            totalPoints: user.totalPoints,
            successfulPredictions: user.successfulPredictions,
            accuracyRate: user.accuracyRate,
            achievements: user.achievements,
            recentPredictions: user.recentPredictions
        )
    }
    
    /// 更新风格配置
    func updateStyleProfile(_ newProfile: UserStyleProfile) {
        styleProfile = newProfile
    }
    
    /// 获取用户等级标题
    func getLevelTitle() -> String {
        switch user.level {
        case 1...2:
            return "时尚新手"
        case 3...5:
            return "时尚探索者"
        case 6...10:
            return "时尚达人"
        default:
            return "时尚大师"
        }
    }
    
    /// 计算距离下一等级的经验值
    func getExperienceToNextLevel() -> Int {
        let nextLevelThreshold = user.level * 500 // 每级需要500积分
        return max(0, nextLevelThreshold - user.totalPoints)
    }
    
    /// 检查是否解锁新成就
    func checkForNewAchievements() {
        // 在真实应用中，这里会根据用户行为检查是否解锁新成就
        // 比如：
        // - 预测成功达到一定次数
        // - 连续登录天数
        // - 提名趋势被采纳等
    }
    
    /// 模拟解锁成就
    func unlockAchievement(_ achievementId: String) {
        if let index = user.achievements.firstIndex(where: { achievement in
            achievement.title == achievementId && !achievement.isUnlocked
        }) {
            let updatedAchievement = Achievement(
                title: user.achievements[index].title,
                icon: user.achievements[index].icon,
                color: user.achievements[index].color,
                description: user.achievements[index].description,
                isUnlocked: true
            )
            
            var updatedAchievements = user.achievements
            updatedAchievements[index] = updatedAchievement
            
            user = UserProfile(
                username: user.username,
                bio: user.bio,
                level: user.level,
                totalPoints: user.totalPoints,
                successfulPredictions: user.successfulPredictions,
                accuracyRate: user.accuracyRate,
                achievements: updatedAchievements,
                recentPredictions: user.recentPredictions
            )
        }
    }
    
    /// 获取成就完成百分比文本
    func getAchievementProgressText() -> String {
        let completed = unlockedAchievements.count
        let total = user.achievements.count
        return "\(completed)/\(total)"
    }
}
