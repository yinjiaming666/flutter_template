# API：示例分页

- 状态：draft。仅定义模板服务示例所需的接口形状，尚无真实后端。
- GET `/api/example/page`；Token 请求头。
- Query：`page: int = 1`、`limit: int = 20`，均为正整数，实际上限由接入项目约定。

成功响应：

```ts
type Response = {
  code: 1
  msg: string
  data: {
    total: number
    per_page: number
    current_page: number
    last_page: number
    data: Array<{
      id: number
      title: string
      description: string
      create_time: number // Unix 秒
    }>
  }
}
```

空结果：total 为 0、data.data 为空数组。业务失败：
`{code: number, msg: string, data?: unknown}`，code 不为 1。

客户端复用 `PageRespEntity<ExampleEntity>` / `PageData<ExampleEntity>`。
`ExampleServices.getPage` 在业务失败时抛出 `ApiException`，以便分页控制器保留旧数据和页码。
成功时 `data` 应为分页对象，`data.data` 应为数组。结构缺失、类型错误或条目无法转换时抛出格式错误 `ApiException`，已有列表和页码可用于重试。错误响应中的 `data` 不参与实体解析。HTTP、网络及取消行为见 [请求封装约定](request-behavior.md)。
