# Flutter 请求封装约定

状态：active，描述模板客户端当前行为，不表示示例接口已部署。

- `Request.get/post` 拼接 Config.apiPrefix，并使用 Config.serverUrl。
- 默认发送 JSON 和 Token 请求头。应用在首屏前从已有 token/userinfo 缓存恢复 GlobalAppState。页面和请求均读取这份内存状态。登录、更新资料和退出分别调用并等待 GlobalAppState.setToken、setUserinfo 和 clear 完成持久化。
- 自定义 Options 保留其配置，并与默认 Token 合并；显式提供的 Token 可覆盖默认值。
- HTTP 2xx 响应按现有 code/msg/data 结构返回；非 Map 响应转换为 code=0，msg 使用应用当前语言提示响应格式错误。
- 默认非 2xx HTTP 状态、网络错误、超时、取消抛出 DioException。调用方负责展示网络错误；取消通常无需提示。
- HTTP 401 或业务 code=401 统一清除 token/userinfo，保留其他偏好，并提示、跳转登录。每次登录都有独立的会话版本，即使 Token 字符串相同，旧响应也不会清除新会话。同一会话只提示一次。显式覆盖为其他 Token 的请求不影响当前登录。
- 业务 code=401 的原始包仍会完成返回，其他业务失败由服务层按接口契约处理。
- showLoading=true 会通过传入 context 或根 Navigator 的 Overlay 显示 loading；无有效 Overlay 时继续请求。每个请求在 finally 中独立关闭自己的 loading。
- Debug 模式的 Request 日志记录 HTTP 方法、路径、状态码、耗时与 Dio 异常类型。日志字段仅来自请求元数据。
- Request.token 或方法参数 t 可取消请求；一个已取消的 CancelToken 不能复用。

示例服务先检查 code。业务失败时保留服务端 msg，忽略未约定结构的 data。列表和分页抛出 ApiException，详情沿用返回 null 的约定，登录过期由请求层统一提示。成功响应具备对应的数据结构时才解析，缺失或类型错误的列表、分页对象或分页明细会抛出带本地化格式提示的 ApiException。
