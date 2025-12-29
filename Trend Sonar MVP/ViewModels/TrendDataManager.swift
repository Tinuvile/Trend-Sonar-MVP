//
//  TrendDataManager.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/16.
//

import SwiftUI
import Combine

// MARK: - 带投注信息的预测
struct UserPredictionWithBet {
    let prediction: UserPrediction
    let betAmount: Int
    
    var id: UUID { prediction.id }
    var isCorrect: Bool? { prediction.isCorrect }
}

@MainActor
class TrendDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var allTrends: [TrendItem] = []
    @Published var userSubmissions: [SubmittedTrend] = []
    @Published var userPredictions: [UserPrediction] = []
    @Published var sonarCoins: Int = 100 // 声纳币，初始100个
    
    // MARK: - Private Properties
    private var userPredictionsWithBets: [UserPredictionWithBet] = []
    
    // MARK: - Singleton Instance
    static let shared = TrendDataManager()
    
    // MARK: - Computed Properties
    
    /// 雷达中显示的趋势（包含原始数据 + 已通过的用户提交）
    var radarTrends: [TrendItem] {
        allTrends.filter { trend in
            // 只显示热度大于30的趋势，避免雷达过于拥挤
            trend.heatScore >= 30
        }
    }
    
    /// 可预测的小众趋势
    var predictableTrends: [TrendItem] {
        allTrends.filter { trend in
            trend.zone == .niche && trend.heatScore >= 35
        }
    }
    
    /// 待审核的用户提交
    var pendingSubmissions: [SubmittedTrend] {
        userSubmissions.filter { $0.status == .pending }
    }
    
    /// 已通过的提交
    var approvedSubmissions: [SubmittedTrend] {
        userSubmissions.filter { $0.status == .approved }
    }
    
    /// 已成为趋势的提交
    var trendingSubmissions: [SubmittedTrend] {
        userSubmissions.filter { $0.status == .trending }
    }
    
    // MARK: - Private Properties
    private var trendUpdateTimer: Timer?
    private var submissionTimer: Timer?
    
    // MARK: - Initialization
    private init() {
        loadInitialData()
        startTrendSimulation()
        startSubmissionSimulation()
    }
    
    // MARK: - Public Methods
    
    /// 添加用户提交的趋势
    func addUserSubmission(_ submission: SubmittedTrend) {
        userSubmissions.insert(submission, at: 0)
        
        // 模拟自动审核过程（实际项目中这会是后台处理）
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 10...30)) {
            self.simulateSubmissionReview(submissionId: submission.id)
        }
    }
    
    /// 添加用户预测（带声纳币投注）
    func addUserPrediction(_ prediction: UserPrediction, betAmount: Int = 10) -> Bool {
        // 检查声纳币是否足够
        guard sonarCoins >= betAmount else { return false }
        
        // 扣除声纳币
        spendSonarCoins(betAmount)
        
        // 创建带投注信息的预测
        let predictionWithBet = UserPredictionWithBet(
            prediction: prediction,
            betAmount: betAmount
        )
        
        userPredictionsWithBets.insert(predictionWithBet, at: 0)
        userPredictions.insert(prediction, at: 0)
        
        // 模拟预测结果验证（演示用2秒，实际是7天）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulatePredictionResult(predictionId: prediction.id)
        }
        
        return true
    }
    
    /// 获取用户可用声纳币
    func getAvailableSonarCoins() -> Int {
        return sonarCoins
    }
    
    /// 奖励声纳币（完成任务、成功预测等）
    func awardSonarCoins(_ amount: Int, reason: String) {
        sonarCoins += amount
        saveSonarCoins()
        
        // 这里可以添加通知或日志
        print("🪙 获得 \(amount) 声纳币: \(reason)")
    }
    
    /// 消费声纳币
    private func spendSonarCoins(_ amount: Int) {
        sonarCoins = max(0, sonarCoins - amount)
        saveSonarCoins()
    }
    
    /// 获取趋势的预测统计
    func getPredictionStats(for trendId: UUID) -> (totalPredictions: Int, bullishPredictions: Int) {
        let predictions = userPredictions.filter { prediction in
            // 简化处理，实际需要更精确的匹配
            allTrends.contains { $0.name == prediction.trendName }
        }
        
        let bullish = predictions.filter { $0.confidence > 60 }.count
        return (predictions.count, bullish)
    }
    
    /// 更新趋势热度
    func updateTrendHeat(trendId: UUID, newHeat: Int) {
        if let index = allTrends.firstIndex(where: { $0.id == trendId }) {
            let oldTrend = allTrends[index]
            let newZone = calculateZone(for: newHeat)
            
            let updatedTrend = TrendItem(
                name: oldTrend.name,
                category: oldTrend.category,
                zone: newZone,
                angle: oldTrend.angle,
                heatScore: newHeat,
                growthRate: calculateGrowthRate(oldHeat: oldTrend.heatScore, newHeat: newHeat),
                description: oldTrend.description,
                isUserPredicted: oldTrend.isUserPredicted
            )
            
            allTrends[index] = updatedTrend
        }
    }
    
    /// 获取用户的预测历史
    func getUserPredictionHistory() -> [UserPrediction] {
        userPredictions
    }
    
    /// 获取用户的提交历史
    func getUserSubmissionHistory() -> [SubmittedTrend] {
        userSubmissions
    }
    
    /// 计算用户积分（奖励系统）
    func calculateUserPoints() -> Int {
        var points = 0
        
        // 基础预测积分
        let successfulPredictions = userPredictions.filter { $0.isCorrect == true }
        let failedPredictions = userPredictions.filter { $0.isCorrect == false }
        
        for prediction in successfulPredictions {
            var basePoints = calculatePredictionPoints(prediction)
            
            // 时间奖励（距离预测时间越短，奖励越高）
            let timeBonus = calculateTimeBonus(for: prediction)
            
            // 信心奖励（高信心预测成功获得更多积分）
            let confidenceBonus = calculateConfidenceBonus(for: prediction)
            
            // 难度奖励（预测小众趋势成功奖励更高）
            let difficultyBonus = calculateDifficultyBonus(for: prediction)
            
            points += basePoints + timeBonus + confidenceBonus + difficultyBonus
        }
        
        // 失败预测的风险扣分
        for prediction in failedPredictions {
            let penalty = calculatePredictionPenalty(prediction)
            points = max(0, points - penalty) // 不会扣成负数
        }
        
        // 连击奖励（连续预测成功）
        points += calculateStreakBonus()
        
        // 提交奖励
        points += calculateSubmissionPoints()
        
        // 社区贡献奖励
        points += calculateCommunityPoints()
        
        return points
    }
    
    /// 计算基础预测积分
    private func calculatePredictionPoints(_ prediction: UserPrediction) -> Int {
        switch (prediction.currentZone, prediction.targetZone) {
        case (.niche, .trending): return 50      // 小众 → 先锋
        case (.niche, .mainstream): return 100   // 小众 → 主流（跨级）
        case (.trending, .mainstream): return 30  // 先锋 → 主流
        default: return 20
        }
    }
    
    /// 计算时间奖励
    private func calculateTimeBonus(for prediction: UserPrediction) -> Int {
        let daysSincePrediction = Calendar.current.dateComponents([.day], from: prediction.predictedDate, to: Date()).day ?? 0
        
        switch daysSincePrediction {
        case 0...2: return 20      // 48小时内验证 - 超快奖励
        case 3...7: return 15      // 一周内验证 - 快速奖励  
        case 8...14: return 10     // 两周内验证 - 标准奖励
        default: return 5          // 长期验证 - 基础奖励
        }
    }
    
    /// 计算信心奖励
    private func calculateConfidenceBonus(for prediction: UserPrediction) -> Int {
        switch prediction.confidence {
        case 90...100: return 25   // 极高信心
        case 80...89: return 15    // 高信心
        case 70...79: return 10    // 中等信心
        case 60...69: return 5     // 基础信心
        default: return 0          // 低信心不额外奖励
        }
    }
    
    /// 计算难度奖励
    private func calculateDifficultyBonus(for prediction: UserPrediction) -> Int {
        // 根据当前趋势的热度来判断预测难度
        // 热度越低的趋势，预测成功难度越高
        if let trend = allTrends.first(where: { $0.name == prediction.trendName }) {
            switch trend.heatScore {
            case 30...40: return 30    // 超冷门趋势
            case 41...50: return 20    // 冷门趋势  
            case 51...60: return 10    // 小众趋势
            default: return 0          // 热门趋势不额外奖励
            }
        }
        return 0
    }
    
    /// 计算预测失败扣分
    private func calculatePredictionPenalty(_ prediction: UserPrediction) -> Int {
        // 扣分基于信心指数，信心越高扣分越多（风险投资机制）
        switch prediction.confidence {
        case 90...100: return 20   // 高信心失败扣分多
        case 80...89: return 15    
        case 70...79: return 10    
        case 60...69: return 5     
        default: return 2          // 低信心失败扣分少
        }
    }
    
    /// 计算连击奖励
    private func calculateStreakBonus() -> Int {
        let recentPredictions = userPredictions
            .filter { $0.isCorrect != nil }
            .sorted { $0.predictedDate > $1.predictedDate } // 最新的在前
        
        var currentStreak = 0
        
        for prediction in recentPredictions {
            if prediction.isCorrect == true {
                currentStreak += 1
            } else {
                break
            }
        }
        
        // 连击奖励递增
        switch currentStreak {
        case 3...5: return 20     // 3-5连击
        case 6...9: return 50     // 6-9连击  
        case 10...15: return 100  // 10-15连击
        case 16...: return 200    // 16连击以上
        default: return 0
        }
    }
    
    /// 计算提交奖励
    private func calculateSubmissionPoints() -> Int {
        var points = 0
        
        // 基础提交奖励
        points += approvedSubmissions.count * 50
        points += trendingSubmissions.count * 200
        
        // 首个提交奖励
        if !userSubmissions.isEmpty {
            points += 30
        }
        
        // 多样性奖励（不同类别的提交）
        let uniqueCategories = Set(approvedSubmissions.map { $0.category })
        points += uniqueCategories.count * 10
        
        return points
    }
    
    /// 计算社区贡献积分
    private func calculateCommunityPoints() -> Int {
        var points = 0
        
        // 支持度奖励（其他用户对提交的支持）
        let totalSupport = approvedSubmissions.reduce(0) { $0 + $1.supportCount }
        points += min(totalSupport * 2, 100) // 最多100分
        
        // 活跃度奖励（提交和预测的总数）
        let totalActivity = userSubmissions.count + userPredictions.count
        points += min(totalActivity * 3, 150) // 最多150分
        
        return points
    }
    
    /// 获取详细的积分明细
    func getPointsBreakdown() -> [String: Int] {
        let successfulPredictions = userPredictions.filter { $0.isCorrect == true }
        let failedPredictions = userPredictions.filter { $0.isCorrect == false }
        
        var breakdown: [String: Int] = [:]
        
        // 成功预测积分
        let predictionPoints = successfulPredictions.reduce(0) { total, prediction in
            let basePoints = calculatePredictionPoints(prediction)
            let timeBonus = calculateTimeBonus(for: prediction)
            let confidenceBonus = calculateConfidenceBonus(for: prediction)
            let difficultyBonus = calculateDifficultyBonus(for: prediction)
            return total + basePoints + timeBonus + confidenceBonus + difficultyBonus
        }
        breakdown["成功预测"] = predictionPoints
        
        // 失败扣分
        let penaltyPoints = failedPredictions.reduce(0) { total, prediction in
            return total + calculatePredictionPenalty(prediction)
        }
        breakdown["预测失误"] = -penaltyPoints
        
        // 其他奖励
        breakdown["连击奖励"] = calculateStreakBonus()
        breakdown["趋势提交"] = calculateSubmissionPoints()
        breakdown["社区贡献"] = calculateCommunityPoints()
        
        return breakdown
    }
    
    /// 计算预测准确率
    func calculateAccuracyRate() -> Int {
        let completedPredictions = userPredictions.filter { $0.isCorrect != nil }
        guard !completedPredictions.isEmpty else { return 0 }
        
        let successful = completedPredictions.filter { $0.isCorrect == true }
        return Int((Double(successful.count) / Double(completedPredictions.count)) * 100)
    }
    
    // MARK: - Private Methods
    
    /// 加载初始数据
    private func loadInitialData() {
        // 加载样本趋势数据
        allTrends = TrendItem.sampleData
        
        // 加载样本用户提交数据
        userSubmissions = createSampleSubmissions()
        
        // 加载样本预测数据
        userPredictions = createSamplePredictions()
        
        // 加载声纳币数据
        loadSonarCoins()
        
        // 检查每日奖励
        checkDailyReward()
    }
    
    /// 加载声纳币数据
    private func loadSonarCoins() {
        sonarCoins = UserDefaults.standard.integer(forKey: "sonarCoins")
        if sonarCoins == 0 {
            // 新用户奖励
            sonarCoins = 100
            saveSonarCoins()
            awardSonarCoins(50, reason: "新用户奖励")
        }
    }
    
    /// 保存声纳币数据
    private func saveSonarCoins() {
        UserDefaults.standard.set(sonarCoins, forKey: "sonarCoins")
    }
    
    /// 检查每日奖励
    private func checkDailyReward() {
        let lastRewardDate = UserDefaults.standard.object(forKey: "lastDailyReward") as? Date
        let today = Date()
        
        if let lastDate = lastRewardDate {
            let calendar = Calendar.current
            if !calendar.isDate(lastDate, inSameDayAs: today) {
                // 发放每日奖励
                awardSonarCoins(20, reason: "每日登录奖励")
                UserDefaults.standard.set(today, forKey: "lastDailyReward")
                
                // 连续登录奖励
                let consecutiveDays = calculateConsecutiveDays()
                if consecutiveDays >= 7 {
                    awardSonarCoins(50, reason: "连续登录7天奖励")
                }
            }
        } else {
            // 首次登录
            awardSonarCoins(20, reason: "首次每日奖励")
            UserDefaults.standard.set(today, forKey: "lastDailyReward")
        }
    }
    
    /// 计算连续登录天数
    private func calculateConsecutiveDays() -> Int {
        // 简化实现，返回随机天数（实际项目中会计算真实的连续天数）
        return Int.random(in: 1...14)
    }
    
    /// 开始趋势模拟（热度变化）
    private func startTrendSimulation() {
        trendUpdateTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            Task { @MainActor in
                self.simulateTrendHeatChanges()
            }
        }
    }
    
    /// 开始提交审核模拟
    private func startSubmissionSimulation() {
        submissionTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { _ in
            Task { @MainActor in
                self.simulateRandomSubmissionEvents()
            }
        }
    }
    
    /// 模拟趋势热度变化
    private func simulateTrendHeatChanges() {
        guard !allTrends.isEmpty else { return }
        
        // 随机选择几个趋势进行热度更新
        let trendsToUpdate = Array(allTrends.shuffled().prefix(3))
        
        for trend in trendsToUpdate {
            let heatChange = Int.random(in: -5...8) // 小幅波动，偏向上涨
            let newHeat = max(20, min(100, trend.heatScore + heatChange))
            
            updateTrendHeat(trendId: trend.id, newHeat: newHeat)
        }
    }
    
    /// 模拟提交审核
    private func simulateSubmissionReview(submissionId: UUID) {
        guard let index = userSubmissions.firstIndex(where: { $0.id == submissionId }) else { return }
        
        let submission = userSubmissions[index]
        let isApproved = Bool.random() // 50%通过率
        
        let newStatus: SubmissionStatus = isApproved ? .approved : .rejected
        let newSupportCount = isApproved ? submission.supportCount + Int.random(in: 3...15) : submission.supportCount
        
        let updatedSubmission = SubmittedTrend(
            name: submission.name,
            category: submission.category,
            description: submission.description,
            inspiration: submission.inspiration,
            submitDate: submission.submitDate,
            status: newStatus,
            supportCount: newSupportCount
        )
        
        userSubmissions[index] = updatedSubmission
        
        // 如果通过，添加到趋势雷达中
        if isApproved {
            addApprovedSubmissionToRadar(updatedSubmission)
        }
    }
    
    /// 将通过的提交添加到雷达中
    private func addApprovedSubmissionToRadar(_ submission: SubmittedTrend) {
        let newTrend = TrendItem(
            name: submission.name,
            category: submission.category,
            zone: .niche, // 新趋势从小众区开始
            angle: Double.random(in: 0...360),
            heatScore: Int.random(in: 35...50), // 新趋势起始热度
            growthRate: Double.random(in: 10...30), // 较高的增长率
            description: submission.description,
            isUserPredicted: false
        )
        
        allTrends.append(newTrend)
        
        // 模拟趋势可能爆火
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 30...60)) {
            if Bool.random() { // 30%概率爆火
                self.simulateSubmissionBecomeTrending(submissionId: submission.id)
            }
        }
    }
    
    /// 模拟提交成为热门趋势
    private func simulateSubmissionBecomeTrending(submissionId: UUID) {
        guard let index = userSubmissions.firstIndex(where: { $0.id == submissionId }) else { return }
        
        let submission = userSubmissions[index]
        guard submission.status == .approved else { return }
        
        let updatedSubmission = SubmittedTrend(
            name: submission.name,
            category: submission.category,
            description: submission.description,
            inspiration: submission.inspiration,
            submitDate: submission.submitDate,
            status: .trending,
            supportCount: submission.supportCount + Int.random(in: 20...50)
        )
        
        userSubmissions[index] = updatedSubmission
        
        // 同时更新雷达中的趋势热度
        if let trendIndex = allTrends.firstIndex(where: { $0.name == submission.name }) {
            updateTrendHeat(trendId: allTrends[trendIndex].id, newHeat: Int.random(in: 75...95))
        }
    }
    
    /// 模拟预测结果（包含声纳币奖励）
    private func simulatePredictionResult(predictionId: UUID) {
        guard let userIndex = userPredictions.firstIndex(where: { $0.id == predictionId }),
              let betIndex = userPredictionsWithBets.firstIndex(where: { $0.id == predictionId }) else { return }
        
        let prediction = userPredictions[userIndex]
        let betInfo = userPredictionsWithBets[betIndex]
        
        // 根据信心指数计算成功概率
        let successProbability = Double(prediction.confidence) / 100.0 * 0.7 + 0.2 // 20%-90%成功率
        let isCorrect = Double.random(in: 0...1) < successProbability
        
        let updatedPrediction = UserPrediction(
            trendName: prediction.trendName,
            predictedDate: prediction.predictedDate,
            currentZone: prediction.currentZone,
            targetZone: prediction.targetZone,
            confidence: prediction.confidence,
            isCorrect: isCorrect
        )
        
        userPredictions[userIndex] = updatedPrediction
        
        // 声纳币奖励/惩罚
        if isCorrect {
            // 成功预测，获得投注金额的倍数奖励
            let multiplier = calculateRewardMultiplier(for: prediction)
            let reward = betInfo.betAmount * multiplier
            
            awardSonarCoins(reward, reason: "成功预测「\(prediction.trendName)」")
            
            // 额外的连击奖励
            let streak = getCurrentStreak()
            if streak >= 3 {
                awardSonarCoins(streak * 2, reason: "\(streak)连击奖励")
            }
        } else {
            // 预测失败，已经在投注时扣除了声纳币，这里不需要额外扣除
            print("❌ 预测失败「\(prediction.trendName)」，损失 \(betInfo.betAmount) 声纳币")
        }
    }
    
    /// 计算奖励倍数
    private func calculateRewardMultiplier(for prediction: UserPrediction) -> Int {
        var multiplier = 2 // 基础倍数
        
        // 根据预测难度调整倍数
        switch (prediction.currentZone, prediction.targetZone) {
        case (.niche, .mainstream): multiplier = 5    // 小众直达主流，超高难度
        case (.niche, .trending): multiplier = 3      // 小众到先锋，高难度  
        case (.trending, .mainstream): multiplier = 2  // 先锋到主流，中等难度
        default: multiplier = 2
        }
        
        // 根据信心指数调整（高风险高回报）
        switch prediction.confidence {
        case 90...100: multiplier += 2    // 极高信心额外奖励
        case 80...89: multiplier += 1     // 高信心额外奖励
        default: break
        }
        
        return multiplier
    }
    
    /// 获取当前连击数
    private func getCurrentStreak() -> Int {
        let recentPredictions = userPredictions
            .filter { $0.isCorrect != nil }
            .sorted { $0.predictedDate > $1.predictedDate }
        
        var streak = 0
        for prediction in recentPredictions {
            if prediction.isCorrect == true {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    /// 模拟随机提交事件
    private func simulateRandomSubmissionEvents() {
        // 模拟其他用户的提交（增加数据丰富性）
        if Bool.random() && Bool.random() { // 25%概率
            let randomSubmission = createRandomSubmission()
            addUserSubmission(randomSubmission)
        }
    }
    
    /// 计算趋势区域
    private func calculateZone(for heatScore: Int) -> TrendZone {
        switch heatScore {
        case 80...100: return .mainstream
        case 60...79: return .trending
        default: return .niche
        }
    }
    
    /// 计算增长率
    private func calculateGrowthRate(oldHeat: Int, newHeat: Int) -> Double {
        guard oldHeat > 0 else { return 0 }
        return Double(newHeat - oldHeat) / Double(oldHeat) * 100
    }
    
    // MARK: - Sample Data Creation
    
    /// 创建样本提交数据
    private func createSampleSubmissions() -> [SubmittedTrend] {
        [
            SubmittedTrend(
                name: "荧光绿运动鞋",
                category: .shoes,
                description: "超亮荧光绿配色，夜跑神器",
                inspiration: "TikTok健身达人",
                submitDate: Date().addingTimeInterval(-3600 * 24 * 2),
                status: .approved,
                supportCount: 12
            ),
            SubmittedTrend(
                name: "彩虹毛线帽",
                category: .accessories,
                description: "手工编织彩虹条纹，温暖有爱",
                inspiration: "小红书手工博主",
                submitDate: Date().addingTimeInterval(-3600 * 24 * 1),
                status: .pending,
                supportCount: 3
            ),
            SubmittedTrend(
                name: "宽松工装外套",
                category: .tops,
                description: "复古工装风格，多口袋设计",
                inspiration: "Instagram街拍",
                submitDate: Date().addingTimeInterval(-3600 * 24 * 5),
                status: .trending,
                supportCount: 48
            )
        ]
    }
    
    /// 创建样本预测数据
    private func createSamplePredictions() -> [UserPrediction] {
        [
            UserPrediction(
                trendName: "奶奶灰针织",
                predictedDate: Date().addingTimeInterval(-3600 * 24 * 3),
                currentZone: .niche,
                targetZone: .trending,
                confidence: 75,
                isCorrect: true
            ),
            UserPrediction(
                trendName: "渔夫帽",
                predictedDate: Date().addingTimeInterval(-3600 * 24 * 1),
                currentZone: .niche,
                targetZone: .trending,
                confidence: 60,
                isCorrect: nil // 还在等待结果
            )
        ]
    }
    
    /// 创建随机提交（模拟其他用户）
    private func createRandomSubmission() -> SubmittedTrend {
        let trendNames = ["流苏耳环", "厚底凉鞋", "透明包包", "拼接牛仔裤", "荧光腰带"]
        let categories = FashionCategory.allCases
        let inspirations = ["小红书", "TikTok", "Instagram", "街拍", "时装周"]
        
        return SubmittedTrend(
            name: trendNames.randomElement()!,
            category: categories.randomElement()!,
            description: "来自社区的新发现，具有很大潜力",
            inspiration: inspirations.randomElement()!,
            submitDate: Date(),
            status: .pending,
            supportCount: Int.random(in: 1...5)
        )
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let trendDataUpdated = Notification.Name("trendDataUpdated")
    static let newSubmissionApproved = Notification.Name("newSubmissionApproved")
    static let predictionResultAvailable = Notification.Name("predictionResultAvailable")
}
