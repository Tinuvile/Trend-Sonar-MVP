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
            ZStack {
                Color.clear.appBackground()
                
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
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("发现新趋势")
            .navigationBarTitleDisplayMode(.inline)
            .alert("提名成功!", isPresented: $showingSubmissionSuccess) {
                Button("确定") { clearForm() }
            } message: {
                Text("你的趋势提名已提交，等待审核中。如果被采纳，你将获得趋势捕手勋章！")
            }
        }
    }
    
    // 头部说明
    private var headerSection: some View {
        HStack(spacing: 16) {
            InfoCard(
                icon: "eye.fill",
                title: "5人提名",
                subtitle: "进入观察区",
                color: .neonBlue
            )
            
            InfoCard(
                icon: "flame.fill",
                title: "趋势爆发",
                subtitle: "+200 PTS",
                color: .neonPink
            )
            
            InfoCard(
                icon: "crown.fill",
                title: "趋势捕手",
                subtitle: "专属勋章",
                color: .neonYellow
            )
        }
        .padding(.vertical)
    }
    
    // 趋势表单
    private var trendForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("趋势详情")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                CustomTextField(title: "趋势名称", placeholder: "例如：奶奶灰针织", text: $trendName)
                
                // 类别选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("所属类别")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(FashionCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.neonBlue : Color.white.opacity(0.1))
                                        )
                                        .foregroundColor(selectedCategory == category ? .black : .white)
                                }
                            }
                        }
                    }
                }
                
                // 描述
                VStack(alignment: .leading, spacing: 8) {
                    Text("趋势描述")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .glassCard()
        }
    }
    
    // 灵感来源
    private var inspirationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomTextField(title: "灵感来源", placeholder: "小红书、TikTok、街拍...", text: $inspiration)
        }
        .padding()
        .glassCard()
    }
    
    // 图片区域
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("参考图片")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: { showingCamera = true }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundColor(.white.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.neonBlue)
                            Text("上传参考图")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .frame(height: 160)
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    // 提交按钮
    private var submitButton: some View {
        Button(action: submitTrend) {
            HStack {
                Image(systemName: "paperplane.fill")
                Text("提交发现")
            }
        }
        .buttonStyle(NeonSolidButtonStyle(color: canSubmit ? .neonPurple : .gray.opacity(0.3), textColor: .white))
        .disabled(!canSubmit)
    }
    
    // 我的提名
    private var mySubmissions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("我的提名")
                .font(.headline)
                .foregroundColor(.white)
            
            if submittedTrends.isEmpty {
                Text("暂无提名记录")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(submittedTrends) { submission in
                        SubmissionCard(submission: submission)
                    }
                }
            }
        }
    }
    
    // Helpers
    private var canSubmit: Bool {
        !trendName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
    
    private func clearForm() {
        trendName = ""
        description = ""
        inspiration = ""
        selectedImage = nil
        selectedCategory = .style
    }
}

// MARK: - Components

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(.white.opacity(0.3))
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .glow(color: color, radius: 5)
            
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassCard()
    }
}

struct SubmissionCard: View {
    let submission: SubmittedTrend
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(submission.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.white.opacity(0.1)))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(submission.status.title)
                    .font(.caption.bold())
                    .foregroundColor(submission.status.color)
                
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.caption2)
                    Text("\(submission.supportCount)")
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    SubmitTrendView()
        .preferredColorScheme(.dark)
}
