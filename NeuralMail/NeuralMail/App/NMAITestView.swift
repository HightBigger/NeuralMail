//
//  NMAITestView.swift
//  NeuralMail
//
//  Created by 小大 on 2025/12/19.
//

import SwiftUI
import NMAIModule // 引入你的本地包

struct AITestView: View {
    @State private var prompt: String = "你好，请自我介绍一下。"
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    @State private var modelLoaded: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔮 AI 模型测试")
                .font(.title)
                .bold()
            
            // 状态显示
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            } else if modelLoaded {
                Text("✅ 模型已就绪")
                    .foregroundStyle(.green)
            } else {
                Text("⏳ 等待加载模型...")
                    .foregroundStyle(.gray)
            }
            
            // 输入框
            TextField("输入提示词...", text: $prompt)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            // 输出区域
            ScrollView {
                Text(response)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // 按钮
            Button(action: generateText) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("🚀 生成回复")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || !modelLoaded)
        }
        .padding()
        .task {
            // 视图显示时自动加载模型
            await loadModel()
        }
    }
    
    // 加载逻辑
    func loadModel() async {
        do {
            let modelName = "LLM"
                        
            guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: nil) else {
                errorMessage = "❌ 找不到模型文件！请检查 Bundle Resources"
                return
            }
            
            try await NMAIManager.shared.loadModel(at: modelURL)
            
            // 预热一下（可选）
            _ = await NMAIManager.shared.generate(prompt: "hi", maxTokens: 1)
            
            modelLoaded = true
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
        }
    }
    
    // 生成逻辑
    func generateText() {
        isLoading = true
        response = "" // 清空旧回复
        
        Task {
            let result = await NMAIManager.shared.generate(prompt: prompt)
            DispatchQueue.main.async {
                self.response = result
                self.isLoading = false
            }
        }
    }
}

//#Preview {
//    AITestView()
//}
