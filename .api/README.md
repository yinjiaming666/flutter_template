# API 契约目录

新增或修改任何后端接口调用前，先在本目录补齐契约，再写 Flutter 请求代码。

推荐每个接口一个文件，文件名使用 kebab-case，例如：

```text
.api/example-detail.md
.api/user-login.md
.api/order-list.md
```

契约模板：

```markdown
# API：<业务域 动作>

## 摘要
- 用途：
- 状态：draft | active | deprecated

## 调用方式
- 方法：GET | POST
- 路径：/api/...
- 鉴权：需要 Token | 不需要
- Content-Type：application/json

## 请求
```ts
type Request = {
  // 字段、可选性、枚举、校验说明
}
```

## 成功响应
```ts
type Response = {
  code: number
  msg: string
  data: unknown
}
```

## 错误响应
```ts
type ErrorResponse = {
  code: number
  msg: string
  data?: unknown
}
```

## 备注
- 分页：
- 副作用：
```
