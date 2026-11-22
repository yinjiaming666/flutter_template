// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Template';

  @override
  String get homeTitle => 'Template home';

  @override
  String get templateDescription =>
      'App routing, networking, models, utilities and shared widgets.';

  @override
  String get login => 'Sign in';

  @override
  String get enterAccount => 'Enter an account';

  @override
  String get openTemplateHome => 'Open template home';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get exampleRequest => 'Example request';

  @override
  String get requesting => 'Sending request…';

  @override
  String get requestFailed =>
      'Request failed. Check the server configuration and retry.';

  @override
  String get signInAgain => 'Sign in again';

  @override
  String get responseFormatError => 'Unexpected response format';

  @override
  String get exampleDetailFailed => 'Could not load details';

  @override
  String get exampleListFailed => 'Could not load the list';

  @override
  String get examplePageFailed => 'Could not load the page';

  @override
  String get loadExample => 'Loading and navigation example';

  @override
  String get loadExampleTitle => 'Page loading example';

  @override
  String get loadExampleContent => 'Page content';

  @override
  String get loadExampleHint =>
      'Pull to refresh while keeping the current content. Saving a new title updates the page.';

  @override
  String get simulateLoadFailure => 'Simulated loading failure';

  @override
  String get editTitle => 'Edit title';

  @override
  String get enterTitle => 'Enter a title';

  @override
  String get title => 'Title';

  @override
  String get save => 'Save';

  @override
  String get refresh => 'Refresh';

  @override
  String get normalContent => 'Loaded content';

  @override
  String get emptyExample => 'Empty result';

  @override
  String get loadFailureExample => 'Loading failure';

  @override
  String get commonWidgetsExample => 'Shared widgets example';

  @override
  String get asyncSubmitTitle => 'Async submission example';

  @override
  String get inputContent => 'Enter text';

  @override
  String get enterContent => 'Enter some text';

  @override
  String get hello => 'Hello';

  @override
  String get contactLater => 'Contact me later';

  @override
  String get confirmAction => 'Confirm action';

  @override
  String get confirmExampleMessage => 'Confirm to update the example text.';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get chooseAction => 'Choose an action';

  @override
  String get editContent => 'Edit text';

  @override
  String get disabledAction => 'Unavailable action';

  @override
  String get clearContent => 'Clear text';

  @override
  String get customBottomContent => 'Custom bottom sheet content';

  @override
  String get close => 'Close';

  @override
  String get noInputYet => 'No text entered yet';

  @override
  String get inputText => 'Enter text';

  @override
  String get asyncSubmit => 'Submit asynchronously';

  @override
  String get confirmDialog => 'Confirmation dialog';

  @override
  String get actionMenu => 'Action menu';

  @override
  String get bottomSheet => 'Bottom sheet';

  @override
  String get asyncSubmitHint =>
      'The first submission fails in this example. Your text stays in the form so you can retry.';

  @override
  String get paginationExample => 'Refresh and pagination example';

  @override
  String get allData => 'All data';

  @override
  String get simulateFailure => 'Simulate failure';

  @override
  String get simulatedRequestFailed => 'Simulated request failure';

  @override
  String exampleItem(int number) {
    return 'Item $number';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get submitFailed => 'Submission failed. Try again.';

  @override
  String characterLimit(int count) {
    return 'Enter up to $count characters';
  }

  @override
  String get loading => 'Loading';

  @override
  String get noData => 'No data yet';

  @override
  String get loadFailed => 'Loading failed. Try again.';

  @override
  String get refreshFailedKeepData =>
      'Refresh failed. The previous content is still available.';

  @override
  String get retry => 'Retry';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get releaseToRefresh => 'Release to refresh';

  @override
  String get refreshing => 'Refreshing';

  @override
  String get refreshComplete => 'Refresh complete';

  @override
  String get refreshFailed => 'Refresh failed';

  @override
  String get noMoreData => 'No more data';

  @override
  String get pullToLoad => 'Pull up to load more';

  @override
  String get releaseToLoad => 'Release to load more';

  @override
  String get loadComplete => 'Loading complete';

  @override
  String get language => 'App language';

  @override
  String get followSystem => 'System default';

  @override
  String get chineseLanguage => '简体中文';

  @override
  String get englishLanguage => 'English';

  @override
  String get languageSaveFailed =>
      'Could not save the language setting. Try again.';

  @override
  String get mediaExample => 'Media and permissions example';

  @override
  String get mediaSource => 'Choose a media source';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get recordVideo => 'Record a video';

  @override
  String get chooseGallery => 'Choose from library';

  @override
  String get selectPictures => 'Select images';

  @override
  String get selectVideos => 'Select videos';

  @override
  String get selectMedia => 'Images and videos';

  @override
  String get mediaPickFailed => 'Could not read the media. Choose it again.';

  @override
  String get noMedia => 'No media selected';

  @override
  String get imageLoadFailed => 'Could not load the image';

  @override
  String imagePosition(int current, int total) {
    return '$current / $total';
  }

  @override
  String get previousImage => 'Previous image';

  @override
  String get nextImage => 'Next image';

  @override
  String get cameraPermission => 'Camera permission';

  @override
  String get requestPermission => 'Request permission';

  @override
  String get openSettings => 'Open system settings';

  @override
  String get permissionUnknown => 'Status unknown';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionDenied => 'Denied';

  @override
  String get permissionPermanentlyDenied => 'Permanently denied';

  @override
  String get permissionRestricted => 'Restricted';

  @override
  String get permissionLimited => 'Limited access';

  @override
  String get permissionProvisional => 'Provisional access';

  @override
  String get permissionFailed => 'Could not read or update permission';
}
