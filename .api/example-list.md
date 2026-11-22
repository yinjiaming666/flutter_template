# API：示例列表

- 状态：draft。仅定义模板服务示例所需的接口形状，尚无真实后端。
- GET `/api/example/list`；Token 请求头；query 参数 `type: int = 0`。

成功响应：

```ts
type Response = {
  code: 1
  msg: string
  time?: string
  data: Array<{
    id: number
    title: string
    description: string
    create_time: number // Unix 秒
  }>
}
```

业务失败：`{code: number, msg: string, data?: unknown}`，code 不为 1。
客户端复用 `ListRespEntity<ExampleEntity>`。业务失败抛出 `ApiException`，不返回空列表冒充成功。
合法空列表为 `data: []`。成功时缺少数组或条目无法转换会抛出格式错误 `ApiException`。错误响应中的 `data` 不参与实体解析。
HTTP、网络及取消行为见 [请求封装约定](request-behavior.md)。
