//
//  StyleSetupView.swift
//  Trend Sonar MVP
//
//  Created by admin on 2025/12/12.
//

import SwiftUI
import PhotosUI

struct StyleSetupView: View {
    @Binding var styleProfile: UserStyleProfile
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedStyles: Set<StyleType> = []
    @State private var selectedBrands: Set<FavoriteBrand> = []
    @State private var selectedBodyType: BodyType = .balanced
    @State private var selectedBudget: BudgetRange = .medium
    @State private var setupMethod: SetupMethod = .questionnaire
    @State private var showingImagePicker = false
    @State private var selectedPhoto: UIImage?
    
    enum SetupMethod: String, CaseIterable {
        case questionnaire = "问卷调研"
        case photo = "照片分析"
        case brands = "品牌偏好"
        
        var icon: String {
            switch self {
            case .questionnaire: return "list.clipboard"
            case .photo: return "camera.fill"
            case .brands: return "bag.fill"
            }
        }
        
        var description: String {
            switch self {
            case .questionnaire: return "通过问卷了解你的风格偏好"
            case .photo: return "上传照片，AI分析你的风格"
            case .brands: return "选择喜欢的品牌，匹配风格"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部介绍
                    headerSection
                    
                    // 设置方法选择
                    setupMethodSection
                    
                    // 根据选择的方法显示不同内容
                    switch setupMethod {
                    case .questionnaire:
                        questionnaireSection
                    case .photo:
                        photoAnalysisSection
                    case .brands:
                        brandSelectionSection
                    }
                    
                    // 完成按钮
                    completeButton
                }
                .padding()
            }
            .navigationTitle("风格设置")
            .navigationBarItems(
                leading: Button("跳过") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadCurrentProfile()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedPhoto)
        }
    }
    
    // 头部说明
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "wand.and.rays")
                .font(.system(size: 48))
                .foregroundColor(.purple)
            
            Text("个性化你的雷达")
                .font(.title)
                .fontWeight(.bold)
            
            Text("让 TrendSonar 更懂你的风格，过滤不适合的趋势，专注于你会喜欢的潮流")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }
    
    // 设置方法选择
    private var setupMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择设置方式")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(SetupMethod.allCases, id: \.self) { method in
                    SetupMethodCard(
                        method: method,
                        isSelected: setupMethod == method
                    ) {
                        setupMethod = method
                    }
                }
            }
        }
    }
    
    // 问卷调研部分
    private var questionnaireSection: some View {
        VStack(spacing: 20) {
            // 风格偏好
            stylePreferenceSection
            
            // 体型选择
            bodyTypeSection
            
            // 预算范围
            budgetSection
        }
    }
    
    // 照片分析部分
    private var photoAnalysisSection: some View {
        VStack(spacing: 16) {
            Text("上传你的日常照片")
                .font(.headline)
                .fontWeight(.bold)
            
            Button(action: {
                showingImagePicker = true
            }) {
                if let photo = selectedPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("点击上传照片")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("我们将分析你的穿搭风格")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 200, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
            
            if selectedPhoto != nil {
                VStack(spacing: 12) {
                    Text("AI 分析结果")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        AnalysisResultTag(style: .minimalist, confidence: 85)
                        AnalysisResultTag(style: .casual, confidence: 72)
                        AnalysisResultTag(style: .elegant, confidence: 45)
                    }
                    
                    Text("基于照片分析，我们推测你偏好简约和休闲风格")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // 品牌选择部分
    private var brandSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择你喜欢的品牌")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("选择 3-5 个你经常购买或喜欢的品牌")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(FavoriteBrand.allCases, id: \.self) { brand in
                    BrandSelectionCard(
                        brand: brand,
                        isSelected: selectedBrands.contains(brand)
                    ) {
                        if selectedBrands.contains(brand) {
                            selectedBrands.remove(brand)
                        } else {
                            selectedBrands.insert(brand)
                        }
                    }
                }
            }
        }
    }
    
    // 风格偏好选择
    private var stylePreferenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你的风格偏好")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("选择 2-4 个最符合你的风格")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(StyleType.allCases, id: \.self) { style in
                    StyleSelectionCard(
                        style: style,
                        isSelected: selectedStyles.contains(style)
                    ) {
                        if selectedStyles.contains(style) {
                            selectedStyles.remove(style)
                        } else {
                            selectedStyles.insert(style)
                        }
                    }
                }
            }
        }
    }
    
    // 体型选择
    private var bodyTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体型特征")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(BodyType.allCases, id: \.self) { bodyType in
                    BodyTypeCard(
                        bodyType: bodyType,
                        isSelected: selectedBodyType == bodyType
                    ) {
                        selectedBodyType = bodyType
                    }
                }
            }
        }
    }
    
    // 预算范围
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预算范围")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(BudgetRange.allCases, id: \.self) { budget in
                    BudgetCard(
                        budget: budget,
                        isSelected: selectedBudget == budget
                    ) {
                        selectedBudget = budget
                    }
                }
            }
        }
    }
    
    // 完成按钮
    private var completeButton: some View {
        Button(action: saveProfile) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("完成设置")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        canComplete ?
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
        .disabled(!canComplete)
    }
    
    // 是否可以完成设置
    private var canComplete: Bool {
        switch setupMethod {
        case .questionnaire:
            return !selectedStyles.isEmpty
        case .photo:
            return selectedPhoto != nil
        case .brands:
            return selectedBrands.count >= 2
        }
    }
    
    // 加载当前配置
    private func loadCurrentProfile() {
        selectedStyles = Set(styleProfile.preferredStyles)
        selectedBrands = Set(styleProfile.favoriteBrands)
        selectedBodyType = styleProfile.bodyType
        selectedBudget = styleProfile.budgetRange
        selectedPhoto = styleProfile.personalPhoto
    }
    
    // 保存配置
    private func saveProfile() {
        styleProfile.preferredStyles = Array(selectedStyles)
        styleProfile.favoriteBrands = Array(selectedBrands)
        styleProfile.bodyType = selectedBodyType
        styleProfile.budgetRange = selectedBudget
        styleProfile.personalPhoto = selectedPhoto
        styleProfile.isPhotoBased = setupMethod == .photo
        styleProfile.lastUpdated = Date()
        
        presentationMode.wrappedValue.dismiss()
    }
}

// 设置方法卡片
struct SetupMethodCard: View {
    let method: StyleSetupView.SetupMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(method.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 风格选择卡片
struct StyleSelectionCard: View {
    let style: StyleType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : style.color)
                
                Text(style.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(minHeight: 100)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? style.color : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? style.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 品牌选择卡片
struct BrandSelectionCard: View {
    let brand: FavoriteBrand
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: brand.logo)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(brand.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 体型卡片
struct BodyTypeCard: View {
    let bodyType: BodyType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: bodyType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(bodyType.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 预算卡片
struct BudgetCard: View {
    let budget: BudgetRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(isSelected ? Color.white : budget.color)
                    .frame(width: 16, height: 16)
                
                Text(budget.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? budget.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// AI分析结果标签
struct AnalysisResultTag: View {
    let style: StyleType
    let confidence: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(style.rawValue)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("\(confidence)%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(style.color.opacity(0.2))
        )
        .overlay(
            Capsule()
                .stroke(style.color, lineWidth: 1)
        )
    }
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    StyleSetupView(styleProfile: .constant(UserStyleProfile()))
}
