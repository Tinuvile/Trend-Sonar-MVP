//
//  SubmissionModel.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

// MARK: - 提交记录数据模型
struct SubmittedTrend: Identifiable {
    let id = UUID()
    let name: String
    let category: FashionCategory
    let description: String
    let inspiration: String
    let submitDate: Date
    let status: SubmissionStatus
    let supportCount: Int
}

// MARK: - 提交状态枚举
enum SubmissionStatus {
    case pending       // 待审核
    case approved      // 已通过
    case rejected      // 被拒绝
    case trending      // 已成为趋势
    
    var title: String {
        switch self {
        case .pending: return "待审核"
        case .approved: return "已通过"
        case .rejected: return "被拒绝"
        case .trending: return "已爆火"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .neonYellow
        case .approved: return .neonGreen
        case .rejected: return .red
        case .trending: return .neonPurple
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .approved: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        case .trending: return "flame.fill"
        }
    }
}
