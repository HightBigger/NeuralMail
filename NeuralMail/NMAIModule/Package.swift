// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NMAIModule",
    platforms: [
        .iOS(.v16),      // MLX 至少需要 iOS 16
        .macOS(.v13)
    ],
    products: [
        // 对外暴露的库名称
        .library(
            name: "NMAIModule",
            targets: ["NMAIModule"]),
    ],
    dependencies: [
        // 这里声明依赖 MLX-Swift
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.29.1"),
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", from: "2.29.2"),
    ],
    targets: [
        // 你的模块目标
        .target(
            name: "NMAIModule",
            dependencies: [
                // 链接 MLX 的核心库
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"), // 神经网络层
                // 3. 引入这两个新拆分出来的库
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ]),
        .testTarget(
            name: "NMAIModuleTests",
            dependencies: ["NMAIModule"]),
    ]
)
