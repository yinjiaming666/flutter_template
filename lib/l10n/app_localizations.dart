import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Flutter Template'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'模板首页'**
  String get homeTitle;

  /// No description provided for @templateDescription.
  ///
  /// In zh, this message translates to:
  /// **'已保留通用路由、请求、实体、工具类和组件骨架。'**
  String get templateDescription;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @enterAccount.
  ///
  /// In zh, this message translates to:
  /// **'请输入账号'**
  String get enterAccount;

  /// No description provided for @openTemplateHome.
  ///
  /// In zh, this message translates to:
  /// **'进入模板首页'**
  String get openTemplateHome;

  /// No description provided for @pageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'页面不存在'**
  String get pageNotFound;

  /// No description provided for @exampleRequest.
  ///
  /// In zh, this message translates to:
  /// **'示例请求'**
  String get exampleRequest;

  /// No description provided for @requesting.
  ///
  /// In zh, this message translates to:
  /// **'请求中…'**
  String get requesting;

  /// No description provided for @requestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败，请检查后端配置后重试'**
  String get requestFailed;

  /// No description provided for @signInAgain.
  ///
  /// In zh, this message translates to:
  /// **'请重新登录'**
  String get signInAgain;

  /// No description provided for @responseFormatError.
  ///
  /// In zh, this message translates to:
  /// **'响应格式错误'**
  String get responseFormatError;

  /// No description provided for @exampleDetailFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取详情失败'**
  String get exampleDetailFailed;

  /// No description provided for @exampleListFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取列表失败'**
  String get exampleListFailed;

  /// No description provided for @examplePageFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取分页失败'**
  String get examplePageFailed;

  /// No description provided for @loadExample.
  ///
  /// In zh, this message translates to:
  /// **'骨架屏与路由示例'**
  String get loadExample;

  /// No description provided for @loadExampleTitle.
  ///
  /// In zh, this message translates to:
  /// **'页面加载示例'**
  String get loadExampleTitle;

  /// No description provided for @loadExampleContent.
  ///
  /// In zh, this message translates to:
  /// **'页面内容'**
  String get loadExampleContent;

  /// No description provided for @loadExampleHint.
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新会保留内容。保存新标题后，页面会自动更新。'**
  String get loadExampleHint;

  /// No description provided for @simulateLoadFailure.
  ///
  /// In zh, this message translates to:
  /// **'示例加载失败'**
  String get simulateLoadFailure;

  /// No description provided for @editTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑标题'**
  String get editTitle;

  /// No description provided for @enterTitle.
  ///
  /// In zh, this message translates to:
  /// **'请输入标题'**
  String get enterTitle;

  /// No description provided for @title.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get title;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @normalContent.
  ///
  /// In zh, this message translates to:
  /// **'正常内容'**
  String get normalContent;

  /// No description provided for @emptyExample.
  ///
  /// In zh, this message translates to:
  /// **'空数据'**
  String get emptyExample;

  /// No description provided for @loadFailureExample.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailureExample;

  /// No description provided for @commonWidgetsExample.
  ///
  /// In zh, this message translates to:
  /// **'通用交互示例'**
  String get commonWidgetsExample;

  /// No description provided for @asyncSubmitTitle.
  ///
  /// In zh, this message translates to:
  /// **'异步提交示例'**
  String get asyncSubmitTitle;

  /// No description provided for @inputContent.
  ///
  /// In zh, this message translates to:
  /// **'输入内容'**
  String get inputContent;

  /// No description provided for @enterContent.
  ///
  /// In zh, this message translates to:
  /// **'请输入内容'**
  String get enterContent;

  /// No description provided for @hello.
  ///
  /// In zh, this message translates to:
  /// **'你好'**
  String get hello;

  /// No description provided for @contactLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后联系'**
  String get contactLater;

  /// No description provided for @confirmAction.
  ///
  /// In zh, this message translates to:
  /// **'确认操作'**
  String get confirmAction;

  /// No description provided for @confirmExampleMessage.
  ///
  /// In zh, this message translates to:
  /// **'确认后会更新当前示例文字。'**
  String get confirmExampleMessage;

  /// No description provided for @confirmed.
  ///
  /// In zh, this message translates to:
  /// **'已确认'**
  String get confirmed;

  /// No description provided for @chooseAction.
  ///
  /// In zh, this message translates to:
  /// **'选择操作'**
  String get chooseAction;

  /// No description provided for @editContent.
  ///
  /// In zh, this message translates to:
  /// **'编辑内容'**
  String get editContent;

  /// No description provided for @disabledAction.
  ///
  /// In zh, this message translates to:
  /// **'不可用操作'**
  String get disabledAction;

  /// No description provided for @clearContent.
  ///
  /// In zh, this message translates to:
  /// **'清空内容'**
  String get clearContent;

  /// No description provided for @customBottomContent.
  ///
  /// In zh, this message translates to:
  /// **'自定义底部内容'**
  String get customBottomContent;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @noInputYet.
  ///
  /// In zh, this message translates to:
  /// **'尚未输入内容'**
  String get noInputYet;

  /// No description provided for @inputText.
  ///
  /// In zh, this message translates to:
  /// **'输入文字'**
  String get inputText;

  /// No description provided for @asyncSubmit.
  ///
  /// In zh, this message translates to:
  /// **'异步提交'**
  String get asyncSubmit;

  /// No description provided for @confirmDialog.
  ///
  /// In zh, this message translates to:
  /// **'确认弹窗'**
  String get confirmDialog;

  /// No description provided for @actionMenu.
  ///
  /// In zh, this message translates to:
  /// **'操作菜单'**
  String get actionMenu;

  /// No description provided for @bottomSheet.
  ///
  /// In zh, this message translates to:
  /// **'底部弹层'**
  String get bottomSheet;

  /// No description provided for @asyncSubmitHint.
  ///
  /// In zh, this message translates to:
  /// **'异步提交示例第一次提交会失败，保留输入后可再次提交。'**
  String get asyncSubmitHint;

  /// No description provided for @paginationExample.
  ///
  /// In zh, this message translates to:
  /// **'刷新分页示例'**
  String get paginationExample;

  /// No description provided for @allData.
  ///
  /// In zh, this message translates to:
  /// **'全部数据'**
  String get allData;

  /// No description provided for @simulateFailure.
  ///
  /// In zh, this message translates to:
  /// **'模拟失败'**
  String get simulateFailure;

  /// No description provided for @simulatedRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'模拟请求失败'**
  String get simulatedRequestFailed;

  /// No description provided for @exampleItem.
  ///
  /// In zh, this message translates to:
  /// **'条目 {number}'**
  String exampleItem(int number);

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @submitFailed.
  ///
  /// In zh, this message translates to:
  /// **'提交失败，请重试'**
  String get submitFailed;

  /// No description provided for @characterLimit.
  ///
  /// In zh, this message translates to:
  /// **'最多输入 {count} 个字符'**
  String characterLimit(int count);

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get loadFailed;

  /// No description provided for @refreshFailedKeepData.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，已保留原内容'**
  String get refreshFailedKeepData;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @pullToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新'**
  String get pullToRefresh;

  /// No description provided for @releaseToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'释放刷新'**
  String get releaseToRefresh;

  /// No description provided for @refreshing.
  ///
  /// In zh, this message translates to:
  /// **'正在刷新'**
  String get refreshing;

  /// No description provided for @refreshComplete.
  ///
  /// In zh, this message translates to:
  /// **'刷新完成'**
  String get refreshComplete;

  /// No description provided for @refreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败'**
  String get refreshFailed;

  /// No description provided for @noMoreData.
  ///
  /// In zh, this message translates to:
  /// **'没有更多数据'**
  String get noMoreData;

  /// No description provided for @pullToLoad.
  ///
  /// In zh, this message translates to:
  /// **'上拉加载'**
  String get pullToLoad;

  /// No description provided for @releaseToLoad.
  ///
  /// In zh, this message translates to:
  /// **'释放加载'**
  String get releaseToLoad;

  /// No description provided for @loadComplete.
  ///
  /// In zh, this message translates to:
  /// **'加载完成'**
  String get loadComplete;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'应用语言'**
  String get language;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @chineseLanguage.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get chineseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @languageSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'语言设置保存失败，请重试'**
  String get languageSaveFailed;

  /// No description provided for @mediaExample.
  ///
  /// In zh, this message translates to:
  /// **'媒体与权限示例'**
  String get mediaExample;

  /// No description provided for @mediaSource.
  ///
  /// In zh, this message translates to:
  /// **'选择媒体来源'**
  String get mediaSource;

  /// No description provided for @takePhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get takePhoto;

  /// No description provided for @recordVideo.
  ///
  /// In zh, this message translates to:
  /// **'录制视频'**
  String get recordVideo;

  /// No description provided for @chooseGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chooseGallery;

  /// No description provided for @selectPictures.
  ///
  /// In zh, this message translates to:
  /// **'选图片'**
  String get selectPictures;

  /// No description provided for @selectVideos.
  ///
  /// In zh, this message translates to:
  /// **'选视频'**
  String get selectVideos;

  /// No description provided for @selectMedia.
  ///
  /// In zh, this message translates to:
  /// **'图片和视频'**
  String get selectMedia;

  /// No description provided for @mediaPickFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取媒体失败，请重新选择'**
  String get mediaPickFailed;

  /// No description provided for @noMedia.
  ///
  /// In zh, this message translates to:
  /// **'尚未选择媒体'**
  String get noMedia;

  /// No description provided for @imageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get imageLoadFailed;

  /// No description provided for @imagePosition.
  ///
  /// In zh, this message translates to:
  /// **'{current} / {total}'**
  String imagePosition(int current, int total);

  /// No description provided for @previousImage.
  ///
  /// In zh, this message translates to:
  /// **'上一张'**
  String get previousImage;

  /// No description provided for @nextImage.
  ///
  /// In zh, this message translates to:
  /// **'下一张'**
  String get nextImage;

  /// No description provided for @cameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'相机权限'**
  String get cameraPermission;

  /// No description provided for @requestPermission.
  ///
  /// In zh, this message translates to:
  /// **'申请权限'**
  String get requestPermission;

  /// No description provided for @openSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开系统设置'**
  String get openSettings;

  /// No description provided for @permissionUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未读取'**
  String get permissionUnknown;

  /// No description provided for @permissionGranted.
  ///
  /// In zh, this message translates to:
  /// **'已授权'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'未授权'**
  String get permissionDenied;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In zh, this message translates to:
  /// **'已永久拒绝'**
  String get permissionPermanentlyDenied;

  /// No description provided for @permissionRestricted.
  ///
  /// In zh, this message translates to:
  /// **'受系统限制'**
  String get permissionRestricted;

  /// No description provided for @permissionLimited.
  ///
  /// In zh, this message translates to:
  /// **'有限授权'**
  String get permissionLimited;

  /// No description provided for @permissionProvisional.
  ///
  /// In zh, this message translates to:
  /// **'临时授权'**
  String get permissionProvisional;

  /// No description provided for @permissionFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法读取或修改权限状态'**
  String get permissionFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
