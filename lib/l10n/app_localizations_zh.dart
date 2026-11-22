// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Template';

  @override
  String get homeTitle => '模板首页';

  @override
  String get templateDescription => '已保留通用路由、请求、实体、工具类和组件骨架。';

  @override
  String get login => '登录';

  @override
  String get enterAccount => '请输入账号';

  @override
  String get openTemplateHome => '进入模板首页';

  @override
  String get pageNotFound => '页面不存在';

  @override
  String get exampleRequest => '示例请求';

  @override
  String get requesting => '请求中…';

  @override
  String get requestFailed => '请求失败，请检查后端配置后重试';

  @override
  String get signInAgain => '请重新登录';

  @override
  String get responseFormatError => '响应格式错误';

  @override
  String get exampleDetailFailed => '获取详情失败';

  @override
  String get exampleListFailed => '获取列表失败';

  @override
  String get examplePageFailed => '获取分页失败';

  @override
  String get loadExample => '骨架屏与路由示例';

  @override
  String get loadExampleTitle => '页面加载示例';

  @override
  String get loadExampleContent => '页面内容';

  @override
  String get loadExampleHint => '下拉刷新会保留内容。保存新标题后，页面会自动更新。';

  @override
  String get simulateLoadFailure => '示例加载失败';

  @override
  String get editTitle => '编辑标题';

  @override
  String get enterTitle => '请输入标题';

  @override
  String get title => '标题';

  @override
  String get save => '保存';

  @override
  String get refresh => '刷新';

  @override
  String get normalContent => '正常内容';

  @override
  String get emptyExample => '空数据';

  @override
  String get loadFailureExample => '加载失败';

  @override
  String get commonWidgetsExample => '通用交互示例';

  @override
  String get asyncSubmitTitle => '异步提交示例';

  @override
  String get inputContent => '输入内容';

  @override
  String get enterContent => '请输入内容';

  @override
  String get hello => '你好';

  @override
  String get contactLater => '稍后联系';

  @override
  String get confirmAction => '确认操作';

  @override
  String get confirmExampleMessage => '确认后会更新当前示例文字。';

  @override
  String get confirmed => '已确认';

  @override
  String get chooseAction => '选择操作';

  @override
  String get editContent => '编辑内容';

  @override
  String get disabledAction => '不可用操作';

  @override
  String get clearContent => '清空内容';

  @override
  String get customBottomContent => '自定义底部内容';

  @override
  String get close => '关闭';

  @override
  String get noInputYet => '尚未输入内容';

  @override
  String get inputText => '输入文字';

  @override
  String get asyncSubmit => '异步提交';

  @override
  String get confirmDialog => '确认弹窗';

  @override
  String get actionMenu => '操作菜单';

  @override
  String get bottomSheet => '底部弹层';

  @override
  String get asyncSubmitHint => '异步提交示例第一次提交会失败，保留输入后可再次提交。';

  @override
  String get paginationExample => '刷新分页示例';

  @override
  String get allData => '全部数据';

  @override
  String get simulateFailure => '模拟失败';

  @override
  String get simulatedRequestFailed => '模拟请求失败';

  @override
  String exampleItem(int number) {
    return '条目 $number';
  }

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get submitFailed => '提交失败，请重试';

  @override
  String characterLimit(int count) {
    return '最多输入 $count 个字符';
  }

  @override
  String get loading => '正在加载';

  @override
  String get noData => '暂无数据';

  @override
  String get loadFailed => '加载失败，请重试';

  @override
  String get refreshFailedKeepData => '刷新失败，已保留原内容';

  @override
  String get retry => '重试';

  @override
  String get pullToRefresh => '下拉刷新';

  @override
  String get releaseToRefresh => '释放刷新';

  @override
  String get refreshing => '正在刷新';

  @override
  String get refreshComplete => '刷新完成';

  @override
  String get refreshFailed => '刷新失败';

  @override
  String get noMoreData => '没有更多数据';

  @override
  String get pullToLoad => '上拉加载';

  @override
  String get releaseToLoad => '释放加载';

  @override
  String get loadComplete => '加载完成';

  @override
  String get language => '应用语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get chineseLanguage => '简体中文';

  @override
  String get englishLanguage => 'English';

  @override
  String get languageSaveFailed => '语言设置保存失败，请重试';

  @override
  String get mediaExample => '媒体与权限示例';

  @override
  String get mediaSource => '选择媒体来源';

  @override
  String get takePhoto => '拍照';

  @override
  String get recordVideo => '录制视频';

  @override
  String get chooseGallery => '从相册选择';

  @override
  String get selectPictures => '选图片';

  @override
  String get selectVideos => '选视频';

  @override
  String get selectMedia => '图片和视频';

  @override
  String get mediaPickFailed => '读取媒体失败，请重新选择';

  @override
  String get noMedia => '尚未选择媒体';

  @override
  String get imageLoadFailed => '图片加载失败';

  @override
  String imagePosition(int current, int total) {
    return '$current / $total';
  }

  @override
  String get previousImage => '上一张';

  @override
  String get nextImage => '下一张';

  @override
  String get cameraPermission => '相机权限';

  @override
  String get requestPermission => '申请权限';

  @override
  String get openSettings => '打开系统设置';

  @override
  String get permissionUnknown => '未读取';

  @override
  String get permissionGranted => '已授权';

  @override
  String get permissionDenied => '未授权';

  @override
  String get permissionPermanentlyDenied => '已永久拒绝';

  @override
  String get permissionRestricted => '受系统限制';

  @override
  String get permissionLimited => '有限授权';

  @override
  String get permissionProvisional => '临时授权';

  @override
  String get permissionFailed => '无法读取或修改权限状态';
}
