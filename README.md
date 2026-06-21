# Flutter Template

这是基于 `feige_client` 的 Flutter 项目模板，保留通用工程骨架，删除了房间、IM、商城、家族等业务代码。

## 包含内容

- `lib/main.dart`：应用初始化、全局实例、Provider、ScreenUtil、路由接入。
- `lib/router.dart`：基于 `fluro` 的集中式路由配置和安全参数读取。
- `lib/tool/route_helper.dart`：统一跳转、无 context 跳转、返回封装。
- `lib/request/request.dart`：基于 `dio` 的请求封装、Token 注入、统一登录过期处理。
- `lib/model/response`：普通对象、列表、分页响应包装对象。
- `lib/generated/json/base`：FlutterJsonBeanFactory 风格的基础 JSON 转换文件。
- `.api`：接口契约模板和示例，新增接口前先补契约。

## 开发命令

```bash
flutter pub get
dart format .
flutter analyze
flutter run
```

## 约定

- 包名默认使用 `app`，代码 import 使用 `package:app/...`。
- 业务页面放在 `lib/pages/<module>/`。
- 请求封装放在 `lib/services/<module>_services.dart`。
- 响应实体放在 `lib/model/response/`，对应生成文件放在 `lib/generated/json/`。
- 新增或修改接口调用时，同步维护 `.api` 目录。
