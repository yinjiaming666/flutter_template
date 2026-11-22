# 通用交互、刷新和分页

通用组件沿用当前 Theme。页面可在 `BasePageState.buildPageBody` 中按需组合这些组件。

## 输入与弹层

`lib/widget/app_modal.dart`：

- `showAppConfirmDialog`：原生 Cupertino 确认弹窗，确定返回 true，取消或返回 false。
- `showAppActionSheet<T>`：菜单返回所选值，取消返回 null；支持禁用项、危险操作标记。
- `showAppBottomSheet<T>`：自定义底部内容，统一安全区、键盘避让和类型化返回值。

`lib/widget/app_input_popup.dart`：

```dart
final text = await showAppInputPopup(
  context,
  title: '修改名称',
  initialValue: name,
  maxLength: 40,
  quickReplies: const ['你好', '稍后联系'],
  validator: (value) => value.length < 2 ? '至少两个字' : null,
);
if (!mounted || text == null) return;
setState(() => name = text);
```

支持单行/多行、格式化器、密码、空值、初始值和快捷输入。默认去除首尾空白；密码默认保留空白，可通过 trimInput 指定。

可提供 `onSubmit: (value) async => bool`。返回 true 才关闭；false 或异常会保留输入、显示错误并允许重试。提交期间禁用输入和关闭，屏蔽系统返回。为保护提交，提供 onSubmit 时不启用遮罩和拖拽关闭，空闲时使用关闭按钮或系统返回。菜单和输入都防止重复关闭误弹出下层路由。

## 通用刷新容器

`AppEasyRefresh` 只统一刷新 Header、Footer 和滚动物理效果，数据由页面或 PaginationController 管理。

```dart
AppEasyRefresh(
  onRefresh: () => controller.refresh(),
  onLoad: () async {
    await controller.loadMore();
    if (controller.error != null) return IndicatorResult.fail;
    return controller.hasMore ? IndicatorResult.success : IndicatorResult.noMore;
  },
  childBuilder: (context, physics) => GridView.builder(
    physics: physics,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
    itemCount: controller.items.length,
    itemBuilder: (context, index) => Text('${controller.items[index]}'),
  ),
)
```

页面需通过 ListenableBuilder / Provider 等订阅 controller 才能更新数据。onRefresh/onLoad 支持普通 Future<void> 或原生 IndicatorResult。
禁用回调时使用同位置且零额外拖拽的 NotRefreshHeader / NotLoadFooter，避免切换状态时重建 Scrollable。

Sliver / NestedScrollView 使用 `useLocator: true`，并放置原生占位：

```dart
AppEasyRefresh(
  useLocator: true,
  onRefresh: reload,
  childBuilder: (context, physics) => CustomScrollView(
    physics: physics,
    slivers: [
      const HeaderLocator.sliver(clearExtent: false),
      // 页面自己的 SliverList / SliverGrid。
      const FooterLocator.sliver(),
    ],
  ),
)
```

NestedScrollView 中将 HeaderLocator 放入 headerSliverBuilder，FooterLocator 放入对应的内层滚动内容。空数据和失败状态也应放在刷新区域内。

## 分页控制器

`PaginationController<T>` 复用模板已有的 `PageData<T>`，不另建响应包装或 JSON 生成文件：

```dart
late final controller = PaginationController<ExampleEntity>(
  pageSize: 20,
  loadPage: (page, limit) => ExampleServices.getPage(page: page, limit: limit),
  itemKey: (item) => item.id,
);

@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

- `refresh()` 合并重复刷新，成功后替换列表；失败保留旧列表。
- `refresh(clear: true)` 切换筛选条件，清空列表并使旧请求失效。
- `refresh(force: true)` 替代正在进行的刷新；刷新也会替代旧分页请求。
- `loadMore()` 防止并发加载，仅在成功后推进页码。
- `retry()` 重试刚才失败的刷新或当前页。
- 可按 itemKey 去重；总条数判断使用收到的原始记录数，避免重复 ID 造成无限加载。
- 优先使用 lastPage、total 判断结束；二者未提供时使用本页条数与 perPage/pageSize 判断。
- items 为只读快照；销毁后忽略迟到结果，不代替 HTTP CancelToken。
- loader 的网络或业务失败必须抛出异常，不能把失败转为空页。

常规列表可选用：

```dart
PagedListView<ExampleEntity>(
  controller: controller,
  itemBuilder: (context, item, index) => ListTile(title: Text(item.title)),
)
```

它提供首次加载、空状态、错误重试、追加失败后的行内重试和下拉/上拉交互。controller 由创建方释放。网格等特殊布局直接组合 AppEasyRefresh 与控制器，无需增加页面父类。

旧 `EasyRefreshWidget` 保留，回调返回值明确为“本页条数”，不再兼作累计条数；页码只在成功后推进。新页面推荐使用类型化控制器。

## 媒体选择和图片预览

在模板首页打开“媒体与权限示例”，可以选择图片、视频或混选，点选图片进入全屏预览。

$$$dart
final media = await AppMediaPicker.show(
  context,
  filter: AppMediaFilter.all,
  maxItems: 6,
);
if (!context.mounted || media == null) return;
for (final item in media) {
  // item.file 为 XFile，item.kind 标识图片或视频。
}
$$$

选择取消时返回 null。平台或读取异常由调用方处理。可通过 $source$ 直达相册或相机，$maxItems$ 控制相册选择上限，相机每次返回一个文件。相册在 iOS 13 上会走系统单选。需要长期保存时，将临时文件复制到应用自己的存储。Android 可在恢复对应选择流程时调用 $AppMediaPicker.recoverLostMedia()$ 读取中断前的结果。macOS、Windows 和 Linux 使用平台文件选择能力。

$$$dart
await AppImagePreview.show(
  context,
  images: const [NetworkImage('https://example.com/photo.jpg')],
);
$$$

$AppImagePreview$ 接收 $ImageProvider$ 列表，支持指定起始图片、横向翻页、双指或双击缩放，以及未放大时下拉关闭。提供本地文件、资源或网络图片所用的现有 provider 即可。

## 权限状态

$PermissionHelper.status(permission)$ 查询系统状态，$request(permission)$ 返回同类型状态并合并重复申请，不同权限的系统弹窗按顺序执行。页面可以根据返回结果主动调用 $openSettings()$。示例展示相机权限并在回到前台时刷新。新增其他权限时按用途添加对应平台声明。

## ARB 多语言

默认跟随系统。系统语言不受支持时使用简体中文。可以从登录页或首页切换语言，手动选择由本地偏好保存。页面使用 $context.l10n$ 读取文案。修改 $lib/l10n/app_zh.arb$ 与 $app_en.arb$ 后执行 $flutter gen-l10n$。

## 请求与示例

请求错误和分页协议见 [.api/request-behavior.md](../.api/request-behavior.md)、[示例分页](../.api/example-page.md)。

模板首页新增“通用交互示例”和“刷新分页示例”。两页均使用本地数据，无需真实后端；分页示例可演示失败后保留旧数据和重试。
