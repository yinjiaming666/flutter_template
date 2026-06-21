# API：示例详情

## 摘要
- 用途：演示模板项目中如何描述接口契约。
- 状态：draft

## 调用方式
- 方法：GET
- 路径：/api/example/detail
- 鉴权：需要 Token
- Content-Type：application/json

## 请求
```ts
type Request = {
  id: number
}
```

## 成功响应
```ts
type Response = {
  code: 1
  msg: string
  data: {
    id: number
    title: string
    description: string
    create_time: number
  }
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
