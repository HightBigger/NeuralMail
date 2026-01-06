import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import Tokenizers

public class NMAIManager {
    public static let shared = NMAIManager()
    
    // 使用官方定义的容器，它包含了 model, tokenizer 和处理逻辑
    private var modelContainer: ModelContainer?
    
    private init() {}
    
    /// 加载模型
    /// - Parameter modelDirectory: 模型文件夹的本地 URL
    public func loadModel(at modelDirectory: URL) async throws {
        print("🚀 [NMAIManager] 开始加载模型: \(modelDirectory.path)")
        
        // 1. 创建配置
        let configuration = ModelConfiguration(directory: modelDirectory)
        
        // 2. 使用工厂加载容器 (LLMModelFactory)
        self.modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: configuration
        ) { progress in
            // 这里可以处理加载进度
            print("Downloading/Loading: \(Int(progress.fractionCompleted * 100))%")
        }
        
        print("✅ [NMAIManager] 模型容器加载成功！")
    }
    
    /// 生成文本
    public func generate(prompt: String, maxTokens: Int = 200, temperature: Float = 0.6) async -> String {
        guard let container = modelContainer else {
            return "❌ 错误：模型未加载，请先调用 loadModel"
        }
        
        // 1. 准备生成参数
        let parameters = GenerateParameters(temperature: temperature, topP: 0.9)
        
        // 2. 使用官方的高级生成 API (MLXLMCommon.generate)
        // 这一步直接帮我们处理了 Tokenize -> 推理循环 -> Detokenize 的全过程
        // 再也不用担心 expandedDims 或 argMax 报错了！
        do {
            let result = try await container.perform { context in
                // 预处理输入
                let input = try await context.processor.prepare(input: .init(prompt: prompt))
                
                // 执行生成
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: parameters,
                    context: context
                ) { tokens in
                    // 这里是一个回调，每生成一个 token 都会调用一次
                    // 如果你想做流式输出 (打字机效果)，就在这里处理
                    if tokens.count >= maxTokens {
                        return .stop
                    }
                    return .more
                }
            }
            
            print("📝 [NMAIManager] 生成完毕")
            return result.output
            
        } catch {
            print("❌ 生成失败: \(error)")
            return "生成出错: \(error.localizedDescription)"
        }
    }
}
