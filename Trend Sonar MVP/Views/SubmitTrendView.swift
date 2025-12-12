//
//  SubmitTrendView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI

struct SubmitTrendView: View {
    @State private var trendName = ""
    @State private var selectedCategory: FashionCategory = .style
    @State private var description = ""
    @State private var inspiration = ""
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var submittedTrends: [SubmittedTrend] = []
    @State private var showingSubmissionSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部说明
                    headerSection
                    
                    // 趋势信息表单
                    trendForm
                    
                    // 灵感来源
                    inspirationSection
                    
                    // 图片上传
                    imageSection
                    
                    // 提交按钮
                    submitButton
                    
                    // 我的提名记录
                    mySubmissions
                }
                .padding()
            }
            .navigationTitle("提名新趋势")
            .alert("提名成功!", isPresented: $showingSubmissionSuccess) {
                Button("确定") {
                    clearForm()
                }
            } message: {
                Text("你的趋势提名已提交，等待审核中。如果被采纳，你将获得趋势捕手勋章！")
            }
        }
    }
    
    // 头部说明
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("发现新趋势")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("成为时尚先锋，捕获下一个潮流")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                InfoCard(
                    icon: "eye.fill",
                    title: "5人提名",
                    subtitle: "进入观察区",
                    color: .blue
                )
                
                InfoCard(
                    icon: "flame.fill",
                    title: "趋势爆发",
                    subtitle: "获得200积分",
                    color: .orange
                )
                
                InfoCard(
                    icon: "crown.fill",
                    title: "趋势捕手",
                    subtitle: "专属勋章",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }
    
    // 趋势表单
    private var trendForm: some View {
        VStack(spacing: 16) {
            // 趋势名称
            VStack(alignment: .leading, spacing: 8) {
                Text("趋势名称")
                    .font(.headline)
                
                TextField("例如：奶奶灰针织、爷爷风背心", text: $trendName)
                    .textFieldStyle(CustomTextFieldStyle())
                
                Text("给这个趋势起个朗朗上口的名字")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 类别选择
            VStack(alignment: .leading, spacing: 8) {
                Text("类别")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FashionCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // 描述
            VStack(alignment: .leading, spacing: 8) {
                Text("趋势描述")
                    .font(.headline)
                
                TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3))
                    )
                
                Text("详细描述这个趋势的特点、搭配方式等")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 灵感来源
    private var inspirationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("灵感来源")
                .font(.headline)
            
            TextField("在哪里看到的？小红书、街拍、明星同款...", text: $inspiration)
                .textFieldStyle(CustomTextFieldStyle())
            
            Text("帮助其他人了解这个趋势的背景")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // 图片区域
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("参考图片")
                .font(.headline)
            
            Button(action: {
                showingCamera = true
            }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("添加参考图片")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("（可选）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 200, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("上传一张能展现这个趋势特点的图片")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // 提交按钮
    private var submitButton: some View {
        Button(action: submitTrend) {
            HStack {
                Image(systemName: "paperplane.fill")
                Text("提交趋势")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        canSubmit ? 
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
        .disabled(!canSubmit)
    }
    
    // 我的提名
    private var mySubmissions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我的提名记录")
                .font(.headline)
                .fontWeight(.bold)
            
            if submittedTrends.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("还没有提名记录")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("提名你发现的新趋势，成为时尚先锋！")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(submittedTrends) { submission in
                        SubmissionCard(submission: submission)
                    }
                }
            }
        }
    }
    
    // 表单验证
    private var canSubmit: Bool {
        !trendName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // 提交趋势
    private func submitTrend() {
        let newSubmission = SubmittedTrend(
            name: trendName.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            description: description.trimmingCharacters(in: .whitespaces),
            inspiration: inspiration.trimmingCharacters(in: .whitespaces),
            submitDate: Date(),
            status: .pending,
            supportCount: 1
        )
        
        submittedTrends.insert(newSubmission, at: 0)
        showingSubmissionSuccess = true
    }
    
    // 清空表单
    private func clearForm() {
        trendName = ""
        description = ""
        inspiration = ""
        selectedImage = nil
        selectedCategory = .style
    }
}

// 信息卡片
struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 类别按钮
struct CategoryButton: View {
    let category: FashionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 自定义文本框样式
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3))
            )
    }
}

// 提交记录数据模型
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
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .trending: return .purple
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

// 提名卡片
struct SubmissionCard: View {
    let submission: SubmittedTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(submission.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(submission.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(.systemGray5)))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: submission.status.icon)
                            .foregroundColor(submission.status.color)
                        Text(submission.status.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(submission.status.color)
                    }
                    
                    Text("\(submission.supportCount) 人支持")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(submission.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text("提交时间: \(submission.submitDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if submission.status == .trending {
                    Text("+200积分")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2)
        )
    }
}

#Preview {
    SubmitTrendView()
}
