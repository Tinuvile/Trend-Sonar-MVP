//
//  SubmitTrendViewModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI
import Combine

@MainActor
class SubmitTrendViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var trendName = ""
    @Published var selectedCategory: FashionCategory = .style
    @Published var description = ""
    @Published var inspiration = ""
    @Published var showingCamera = false
    @Published var selectedImage: UIImage?
    @Published var showingSubmissionSuccess = false
    @Published var isSubmitting = false
    
    // MARK: - Data Manager
    private let trendManager = TrendDataManager.shared
    
    // MARK: - Computed Properties
    var canSubmit: Bool {
        !trendName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !isSubmitting
    }
    
    var submittedTrends: [SubmittedTrend] {
        trendManager.getUserSubmissionHistory()
    }
    
    var pendingSubmissions: [SubmittedTrend] {
        trendManager.pendingSubmissions
    }
    
    var approvedSubmissions: [SubmittedTrend] {
        trendManager.approvedSubmissions
    }
    
    var trendingSubmissions: [SubmittedTrend] {
        trendManager.trendingSubmissions
    }
    
    // MARK: - Methods
    
    /// 提交趋势
    func submitTrend() {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        let newSubmission = SubmittedTrend(
            name: trendName.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            description: description.trimmingCharacters(in: .whitespaces),
            inspiration: inspiration.trimmingCharacters(in: .whitespaces),
            submitDate: Date(),
            status: .pending,
            supportCount: 1
        )
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 添加到数据管理器
            self.trendManager.addUserSubmission(newSubmission)
            self.showingSubmissionSuccess = true
            self.isSubmitting = false
            
            // 触发成功反馈
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    /// 清空表单
    func clearForm() {
        trendName = ""
        description = ""
        inspiration = ""
        selectedImage = nil
        selectedCategory = .style
    }
    
    /// 显示相机
    func showCamera() {
        showingCamera = true
    }
    
    /// 隐藏相机
    func hideCamera() {
        showingCamera = false
    }
    
    /// 设置选中的图片
    func setSelectedImage(_ image: UIImage?) {
        selectedImage = image
    }
    
    /// 更新趋势名称
    func updateTrendName(_ name: String) {
        trendName = name
    }
    
    /// 更新描述
    func updateDescription(_ desc: String) {
        description = desc
    }
    
    /// 更新灵感来源
    func updateInspiration(_ insp: String) {
        inspiration = insp
    }
    
    /// 选择类别
    func selectCategory(_ category: FashionCategory) {
        selectedCategory = category
    }
    
    /// 获取提交统计信息
    func getSubmissionStats() -> (total: Int, pending: Int, approved: Int, trending: Int) {
        return (
            total: submittedTrends.count,
            pending: pendingSubmissions.count,
            approved: approvedSubmissions.count,
            trending: trendingSubmissions.count
        )
    }
    
    /// 获取总积分
    func getTotalPoints() -> Int {
        trendManager.calculateUserPoints()
    }
    
    /// 验证表单输入
    func validateForm() -> [String] {
        var errors: [String] = []
        
        if trendName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("请输入趋势名称")
        }
        
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("请输入趋势描述")
        }
        
        if description.count > 500 {
            errors.append("描述不能超过500字")
        }
        
        return errors
    }
}
