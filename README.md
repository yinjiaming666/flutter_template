# Flutter Template

这是基于 `feige_client` 的 Flutter 项目模板，保留通用工程骨架，删除了房间、IM、商城、家族等业务代码。

## 包含内容

- `lib/main.dart`：应用初始化、全局实例、Provider、ScreenUtil、路由接入。
- `lib/router.dart` 集中维护 `AppRoute`、页面构建器、路由参数和启动路由栈。
- `lib/tool/route_helper.dart`：统一跳转、无 context 跳转、返回封装。
- `lib/request/request.dart`：基于 `dio` 的请求封装、Token 注入、统一登录过期处理。
- `lib/model/response`：普通对象、列表、分页响应包装对象。
- `lib/generated/json/base`：FlutterJsonBeanFactory 风格的基础 JSON 转换文件。
- `lib/widget/base_page_state.dart` 提供 `BasePage` 和 `BasePageState`，支持通用页面布局、骨架屏、刷新和路由。
- `lib/widget/base_load_page_state.dart` 提供整页加载、空态、失败重试和刷新结果。
- `lib/widget/app_skeleton.dart`：基于当前主题的骨架占位，支持局部组合。
- `lib/tool/page_route_aware_mixin.dart`：自动订阅和释放页面路由生命周期。
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
- 业务页面放在 `lib/pages/<module>/`，在 `Routes.configureRoutes` 为对应的 `AppRoute` 注册构建器。普通布局可继承 `BasePage`，整页加载可使用 `BaseLoadPageState`。
- 请求封装放在 `lib/services/<module>_services.dart`。
- 响应实体放在 `lib/model/response/`，对应生成文件放在 `lib/generated/json/`。
- 新增或修改接口调用时，同步维护 `.api` 目录。

## 页面父类与路由

进入模板首页，点击“骨架屏与路由示例”，可体验首次骨架、下拉刷新、空数据、失败重试及编辑后的路由返回值。示例使用本地数据。

接入方法和刷新边界见 [页面状态与路由](docs/page-state.md)。新增组件沿用 Flutter 当前主题，无业务项目配色和资源，也不依赖第三方骨架屏包。

项目新增了 Flutter SDK 自带的 `flutter_test` 开发依赖。首次使用测试前，请先手动执行 `flutter pub get`，再运行：

```bash
flutter test --no-pub
```

## 其他通用能力

- 输入弹层、确认弹窗、操作菜单、自定义底部层：原生控件、主题样式与类型化返回值。
- AppEasyRefresh：普通列表、网格、Sliver / NestedScrollView 的刷新交互。
- PaginationController / PagedListView：类型化分页、去重、失败重试和旧响应保护。
- Request 支持 HTTP 错误处理、登录过期清理、loading 收尾和 Debug 请求诊断。
- 媒体与权限示例支持系统选图、选视频、相机权限查询和全屏图片预览。
- ARB 提供简体中文和 English。登录页及首页顶部可切换语言或选择跟随系统。

从首页进入“通用交互示例”或“刷新分页示例”。接入方法见 [通用能力文档](docs/common-features.md)，接口行为见 [.api 请求约定](.api/request-behavior.md)。
