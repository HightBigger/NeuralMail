# NeuralMail 模块化架构设计文档 v2.0

## 🎯 核心定位

- **职责**: 全局应用骨架，负责模块的**全生命周期管理**、**服务依赖注入**及**页面路由分发**。
- **目标**:
  1. **物理隔离**: 业务模块间无代码依赖，仅依赖核心接口层。
  2. **运行时解耦**: 通过协议（Protocol）和服务定位器（Service Locator）进行动态绑定。
  3. **状态可控**: 精确控制模块启动顺序、服务生命周期及用户上下文切换。
- **原则**: 协议驱动、线程安全 (Actor Model)、显式依赖。

## 🏗️ 架构全景图

### 核心组件关系

代码段

```
graph TD
    subgraph Core Layer [核心基础层]
        MM[ModuleManager<br/>(生命周期/依赖拓扑)]
        DI[ServiceContainer<br/>(依赖注入/作用域管理)]
        Router[Router<br/>(UI导航/URL路由)]
        Event[EventBus<br/>(跨模块通知)]
    end

    subgraph Business Layer [业务模块层]
        Auth[AuthModule]
        Net[NetworkModule]
        Chat[ChatModule]
        UI[CommonUI]
    end

    MM --> Auth
    MM --> Net
    MM --> Chat
    
    Auth -.->|注册服务| DI
    Chat -.->|获取服务| DI
    Chat -.->|路由跳转| Router
    
    DI -.->|注入| Auth
    DI -.->|注入| Net
```

------

## 🔧 核心能力详解

### 1. 模块生命周期管理 (Module Lifecycle)

不仅仅是启动，而是管理模块在 App 各种状态下的行为。

**增强特性**:

- **基于优先级的启动**: 支持拓扑排序，确保依赖的基础模块（如 Log, Config）先于业务模块启动。
- **用户上下文感知**: 处理账号切换导致的数据清理和重置。
- **系统事件分发**: 统一代理 AppDelegate 的系统回调。

#### 接口定义

Swift

```
enum ModulePriority: Int {
    case critical = 1000 // 崩溃统计, 日志, 配置 (阻塞主线程)
    case high = 750      // 核心业务, 网络, 数据库 (异步高优)
    case normal = 500    // UI 模块 (异步)
    case low = 100       // 统计打点, 非核心预加载 (Idle时)
}

protocol ModuleType: AnyObject {
    // 1. 静态配置
    static var priority: ModulePriority { get }
    
    // 2. 初始化与注册
    // 在此阶段注册 Service，但不进行耗时操作
    func registerServices(registry: ServiceRegistry)
    
    // 3. 启动
    // 在此阶段进行 SDK 初始化、数据库连接等
    func start(context: LaunchContext) async
    
    // 4. 用户上下文钩子 (关键)
    func userDidLogin(userId: String)
    func userDidLogout() // 清理缓存、断开长连接
    
    // 5. 系统事件
    func applicationDidEnterBackground()
    func applicationDidReceiveMemoryWarning()
}
```

### 2. 增强型服务容器 (Service Container)

引入**作用域 (Scope)** 概念，解决内存膨胀和循环依赖问题。

**具体能力**:

- **多作用域支持**: Singleton (单例), Weak (弱引用), Transient (瞬态)。
- **线程安全**: 基于 Swift `actor` 实现，保证并发访问安全。
- **懒加载**: 避免初始化时的死锁和性能损耗。

#### 接口定义

Swift

```
enum ServiceScope {
    case singleton  // 常驻内存，直到 App 结束
    case weak       // 只要有外部持有就存在，否则释放 (推荐用于 UI 相关服务)
    case transient  // 每次 resolve 都创建新实例
}

protocol ServiceRegistry {
    // 注册服务
    func register<T>(
        service: T.Type, 
        scope: ServiceScope, 
        factory: @escaping () -> T
    )
    
    // 获取服务 (推荐使用 @Injected 包装器而非直接调用)
    func resolve<T>(_ service: T.Type) -> T?
    
    // 卸载服务 (通常用于单元测试或用户登出)
    func unregister<T>(_ service: T.Type)
}
```

### 3. UI 路由系统 (Router)

解决 ViewController 之间的耦合，实现跨模块页面跳转。

**具体能力**:

- **基于 URL/Protocol 的导航**: `nm://chat/session?id=123`
- **降级处理**: 无法识别的路由跳转到 Web 或错误页。
- **组件化资源加载**: 解决 `UIImage(named:)` 在模块 Bundle 中的路径问题。

------

## 💻 开发者体验 (DX) 设计

为了避免 Service Locator 模式代码难看的问题，提供 Swift 属性包装器。

### 1. 依赖注入语法糖

Swift

```
@propertyWrapper
struct Injected<Service> {
    private var service: Service?
    public var wrappedValue: Service {
        mutating get {
            if service == nil {
                service = ServiceContainer.shared.resolve(Service.self)
            }
            guard let s = service else {
                // DEBUG 模式下直接 Crash 提醒开发者，Release 模式下打 Log
                fatalError("Critical: Service \(Service.self) not registered!")
            }
            return s
        }
    }
}
```

### 2. 模块内资源加载隔离

防止资源命名冲突 (Resource Bundle Hell)。

Swift

```
extension ModuleType {
    // 获取当前模块的 Bundle
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func image(named: String) -> UIImage? {
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
```

------

## 🚀 集成与使用示例

### 定义一个业务模块 (如 ChatModule)

Swift

```
final class ChatModule: ModuleType {
    static var priority: ModulePriority = .normal
    
    func registerServices(registry: ServiceRegistry) {
        // 注册聊天服务，作用域为单例
        registry.register(ChatService.self, scope: .singleton) { 
            ChatManagerImpl() 
        }
        
        // 注册路由
        Router.shared.register("nm://chat/detail") { params in
            return ChatDetailViewController(id: params["id"])
        }
    }
    
    func start(context: LaunchContext) async {
        // 异步预加载表情包资源
        await EmojiLoader.preload()
    }
    
    func userDidLogout() {
        // 关键：用户登出时清理数据库连接
        let service: ChatService? = ServiceContainer.shared.resolve(ChatService.self)
        service?.disconnect()
    }
}
```

### 业务代码使用

Swift

```
class HomeViewController: UIViewController {
    // ✅ 声明式依赖注入，无需在 init 中传递
    @Injected var chatService: ChatService
    @Injected var config: ConfigurationManager
    
    func onChatButtonTapped() {
        // ✅ 使用路由跳转，不引用 ChatDetailVC 类
        Router.shared.navigate(to: "nm://chat/detail?id=10086")
    }
}
```

------

## 📊 实施阶段与注意事项

### 🛑 风险规避 (Guardrails)

1. **禁止循环依赖**: 不要在 Service 的 `init` 方法中调用 `resolve`。利用 `@Injected` 的懒加载特性来打破循环。
2. **主线程保护**: `Module.start()` 默认在后台线程执行，除非标记为 `.critical` 且涉及 UI 初始化。
3. **调试黑盒**: 实现 `ServiceContainer.dump()` 方法，在 Debug 菜单中打印当前所有已注册的 Service 和 Module 状态，便于排查问题。

### ✅ 推荐技术选型

- **并发模型**: Swift Actors (用于 Registry 内部状态保护)
- **异步处理**: Swift Concurrency (async/await)
- **接口抽象**: Pure Swift Protocols

### 📅 演进路线

1. **Phase 1 (基础)**: 实现 `ModuleManager` 和 `ServiceContainer` (支持 Scope)，完成核心模块迁移。
2. **Phase 2 (路由)**: 实现 URL Router，剥离 ViewController 强依赖。
3. **Phase 3 (健壮)**: 完善生命周期中的 System Events 和 User Context 切换逻辑，添加 Debug 可视化面板。