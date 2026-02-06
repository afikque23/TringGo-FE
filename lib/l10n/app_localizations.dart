import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Management'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information and preferences'**
  String get editProfileDescription;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+62 812-3456-7890'**
  String get phoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profilePhotoHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera icon to change your profile photo.'**
  String get profilePhotoHelp;

  /// No description provided for @profileTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for a Secure Profile'**
  String get profileTipsTitle;

  /// No description provided for @profileTipsContent.
  ///
  /// In en, this message translates to:
  /// **'Keep your profile information up to date to ensure account security and personalized experience.'**
  String get profileTipsContent;

  /// No description provided for @profileTipsEmail.
  ///
  /// In en, this message translates to:
  /// **'Make sure your email is always up-to-date for account recovery and important notifications.'**
  String get profileTipsEmail;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @statTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @statActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActive;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statPending;

  /// No description provided for @statCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statCancelled;

  /// No description provided for @editProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get editProfileSuccess;

  /// No description provided for @editProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get editProfileFailed;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @profileFooter.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Management v1.0.0\nAll rights reserved.'**
  String get profileFooter;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocation;

  /// No description provided for @profileHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileHeaderTitle;

  /// No description provided for @profileHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences'**
  String get profileHeaderSubtitle;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Statistics'**
  String get statsTitle;

  /// No description provided for @statMotor.
  ///
  /// In en, this message translates to:
  /// **'Motorcycles'**
  String get statMotor;

  /// No description provided for @statTrip.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get statTrip;

  /// No description provided for @statTotalKm.
  ///
  /// In en, this message translates to:
  /// **'Total KM'**
  String get statTotalKm;

  /// No description provided for @dangerZoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanent actions that require confirmation'**
  String get dangerZoneDescription;

  /// No description provided for @footerAppName.
  ///
  /// In en, this message translates to:
  /// **'MotoTracker v1.0.0'**
  String get footerAppName;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MotoTracker. All rights reserved.'**
  String get footerCopyright;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get serviceHistory;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @serviceDate.
  ///
  /// In en, this message translates to:
  /// **'Service Date'**
  String get serviceDate;

  /// No description provided for @serviceCost.
  ///
  /// In en, this message translates to:
  /// **'Service Cost'**
  String get serviceCost;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @serviceParts.
  ///
  /// In en, this message translates to:
  /// **'Service Parts'**
  String get serviceParts;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Select Motorcycle'**
  String get selectMotorcycle;

  /// No description provided for @motorcyclePlate.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get motorcyclePlate;

  /// No description provided for @motorcycleBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get motorcycleBrand;

  /// No description provided for @motorcycleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get motorcycleModel;

  /// No description provided for @motorcycleYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get motorcycleYear;

  /// No description provided for @addMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Add Motorcycle'**
  String get addMotorcycle;

  /// No description provided for @editMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Edit Motorcycle'**
  String get editMotorcycle;

  /// No description provided for @deleteMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Delete Motorcycle'**
  String get deleteMotorcycle;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmation;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password does not match'**
  String get passwordMismatch;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registerFailed;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update Successful'**
  String get updateSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete Successful'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete Failed'**
  String get deleteFailed;

  /// No description provided for @addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Add Successful'**
  String get addSuccess;

  /// No description provided for @addFailed.
  ///
  /// In en, this message translates to:
  /// **'Add Failed'**
  String get addFailed;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @overallStatus.
  ///
  /// In en, this message translates to:
  /// **'Overall Status'**
  String get overallStatus;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @vehicleCondition.
  ///
  /// In en, this message translates to:
  /// **'Vehicle condition 75%'**
  String get vehicleCondition;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @aboutService.
  ///
  /// In en, this message translates to:
  /// **'About Service'**
  String get aboutService;

  /// No description provided for @aboutServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'This page helps you monitor your motorcycle condition and plan maintenance based on vehicle usage patterns.'**
  String get aboutServiceDesc;

  /// No description provided for @totalComponents.
  ///
  /// In en, this message translates to:
  /// **'Total Components'**
  String get totalComponents;

  /// No description provided for @monitored.
  ///
  /// In en, this message translates to:
  /// **'monitored'**
  String get monitored;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @urgentMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Urgent Maintenance Required'**
  String get urgentMaintenance;

  /// No description provided for @urgentMaintenanceDesc.
  ///
  /// In en, this message translates to:
  /// **'1 component requires urgent maintenance for safe riding.'**
  String get urgentMaintenanceDesc;

  /// No description provided for @planMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Plan Maintenance'**
  String get planMaintenance;

  /// No description provided for @planMaintenanceDesc.
  ///
  /// In en, this message translates to:
  /// **'2 components will require maintenance soon.'**
  String get planMaintenanceDesc;

  /// No description provided for @usagePatternSummary.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Usage Pattern Summary'**
  String get usagePatternSummary;

  /// No description provided for @usagePatternDesc.
  ///
  /// In en, this message translates to:
  /// **'Classification based on mileage and frequency'**
  String get usagePatternDesc;

  /// No description provided for @lightUsage.
  ///
  /// In en, this message translates to:
  /// **'Light Usage'**
  String get lightUsage;

  /// No description provided for @lightUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Vehicle is rarely used or has low mileage. Maintenance intervals are extended.'**
  String get lightUsageDesc;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @kmPerDay.
  ///
  /// In en, this message translates to:
  /// **'km/day'**
  String get kmPerDay;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @kmTotal.
  ///
  /// In en, this message translates to:
  /// **'km total'**
  String get kmTotal;

  /// No description provided for @odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometer;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @usagePatternFooter.
  ///
  /// In en, this message translates to:
  /// **'This data is used by the system to adjust maintenance intervals based on your usage patterns.'**
  String get usagePatternFooter;

  /// No description provided for @schedulePrediction.
  ///
  /// In en, this message translates to:
  /// **'Maintenance schedule predicted based on mileage and your vehicle usage patterns.'**
  String get schedulePrediction;

  /// No description provided for @intervalAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Interval Adjusted'**
  String get intervalAdjusted;

  /// No description provided for @kmRemaining.
  ///
  /// In en, this message translates to:
  /// **'km remaining'**
  String get kmRemaining;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @currently.
  ///
  /// In en, this message translates to:
  /// **'Currently'**
  String get currently;

  /// No description provided for @addMaintenanceSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Maintenance Schedule'**
  String get addMaintenanceSchedule;

  /// No description provided for @serviceScheduleDetail.
  ///
  /// In en, this message translates to:
  /// **'Service Schedule Detail'**
  String get serviceScheduleDetail;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @currentOdometer.
  ///
  /// In en, this message translates to:
  /// **'Current Odometer'**
  String get currentOdometer;

  /// No description provided for @serviceTarget.
  ///
  /// In en, this message translates to:
  /// **'Service Target'**
  String get serviceTarget;

  /// No description provided for @towardNextService.
  ///
  /// In en, this message translates to:
  /// **'toward next service'**
  String get towardNextService;

  /// No description provided for @serviceInterval.
  ///
  /// In en, this message translates to:
  /// **'Service Interval'**
  String get serviceInterval;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @lastService.
  ///
  /// In en, this message translates to:
  /// **'Last Service'**
  String get lastService;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addServiceSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Service Schedule'**
  String get addServiceSchedule;

  /// No description provided for @setMaintenanceReminder.
  ///
  /// In en, this message translates to:
  /// **'Set motorcycle maintenance reminder'**
  String get setMaintenanceReminder;

  /// No description provided for @maintenanceName.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Name'**
  String get maintenanceName;

  /// No description provided for @exampleOilChange.
  ///
  /// In en, this message translates to:
  /// **'Example: Engine Oil Change'**
  String get exampleOilChange;

  /// No description provided for @scheduleType.
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get scheduleType;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @serviceAtKm.
  ///
  /// In en, this message translates to:
  /// **'Service at (km)'**
  String get serviceAtKm;

  /// No description provided for @enterKmForNextService.
  ///
  /// In en, this message translates to:
  /// **'Enter kilometer distance for next service'**
  String get enterKmForNextService;

  /// No description provided for @inMonths.
  ///
  /// In en, this message translates to:
  /// **'In (months)'**
  String get inMonths;

  /// No description provided for @orSelectSpecificDate.
  ///
  /// In en, this message translates to:
  /// **'Or select specific date below'**
  String get orSelectSpecificDate;

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind before'**
  String get remindBefore;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @addNotesIfNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add notes if needed…'**
  String get addNotesIfNeeded;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved successfully'**
  String get scheduleSaved;

  /// No description provided for @oilChange.
  ///
  /// In en, this message translates to:
  /// **'Engine Oil Change'**
  String get oilChange;

  /// No description provided for @brakePads.
  ///
  /// In en, this message translates to:
  /// **'Brake Pads'**
  String get brakePads;

  /// No description provided for @chainSprocket.
  ///
  /// In en, this message translates to:
  /// **'Chain & Sprocket'**
  String get chainSprocket;

  /// No description provided for @tireInspection.
  ///
  /// In en, this message translates to:
  /// **'Tire Inspection'**
  String get tireInspection;

  /// No description provided for @sparkPlug.
  ///
  /// In en, this message translates to:
  /// **'Spark Plug'**
  String get sparkPlug;

  /// No description provided for @every3000km.
  ///
  /// In en, this message translates to:
  /// **'Every 3,000 km'**
  String get every3000km;

  /// No description provided for @activeReminder.
  ///
  /// In en, this message translates to:
  /// **'Active - 200 km before target'**
  String get activeReminder;

  /// No description provided for @useFullySynthetic.
  ///
  /// In en, this message translates to:
  /// **'Use fully synthetic oil for optimal performance'**
  String get useFullySynthetic;

  /// No description provided for @kmRemainingShort.
  ///
  /// In en, this message translates to:
  /// **'km left'**
  String get kmRemainingShort;

  /// No description provided for @percentToNextService.
  ///
  /// In en, this message translates to:
  /// **'% toward next service'**
  String get percentToNextService;

  /// No description provided for @addServiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Service Record'**
  String get addServiceRecord;

  /// No description provided for @recordMaintenanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Record your motorcycle maintenance history'**
  String get recordMaintenanceHistory;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// No description provided for @selectServiceType.
  ///
  /// In en, this message translates to:
  /// **'Select service type'**
  String get selectServiceType;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @workshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get workshop;

  /// No description provided for @serviceCenter.
  ///
  /// In en, this message translates to:
  /// **'Service Center'**
  String get serviceCenter;

  /// No description provided for @workshopServiceCenter.
  ///
  /// In en, this message translates to:
  /// **'Workshop / Service Center'**
  String get workshopServiceCenter;

  /// No description provided for @receiptOptional.
  ///
  /// In en, this message translates to:
  /// **'Receipt (Optional)'**
  String get receiptOptional;

  /// No description provided for @uploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload receipt photo'**
  String get uploadReceipt;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @deleteServiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Service Record'**
  String get deleteServiceRecord;

  /// No description provided for @confirmDeleteService.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete service record'**
  String get confirmDeleteService;

  /// No description provided for @editServiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Service Record'**
  String get editServiceRecord;

  /// No description provided for @updateMaintenanceInfo.
  ///
  /// In en, this message translates to:
  /// **'Update motorcycle maintenance information'**
  String get updateMaintenanceInfo;

  /// No description provided for @serviceRecordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service record successfully updated'**
  String get serviceRecordUpdated;

  /// No description provided for @brakePadReplacement.
  ///
  /// In en, this message translates to:
  /// **'Brake Pad Replacement'**
  String get brakePadReplacement;

  /// No description provided for @tireReplacement.
  ///
  /// In en, this message translates to:
  /// **'Tire Replacement'**
  String get tireReplacement;

  /// No description provided for @chainSprocketReplacement.
  ///
  /// In en, this message translates to:
  /// **'Chain & Sprocket Replacement'**
  String get chainSprocketReplacement;

  /// No description provided for @tuneUp.
  ///
  /// In en, this message translates to:
  /// **'Tune Up'**
  String get tuneUp;

  /// No description provided for @sparkPlugReplacement.
  ///
  /// In en, this message translates to:
  /// **'Spark Plug Replacement'**
  String get sparkPlugReplacement;

  /// No description provided for @periodicService.
  ///
  /// In en, this message translates to:
  /// **'Periodic Service'**
  String get periodicService;

  /// No description provided for @engineRepair.
  ///
  /// In en, this message translates to:
  /// **'Engine Repair'**
  String get engineRepair;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @serviceRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Service record saved successfully'**
  String get serviceRecordSaved;

  /// No description provided for @addDetail.
  ///
  /// In en, this message translates to:
  /// **'Add details if needed'**
  String get addDetail;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get manageNotifications;

  /// No description provided for @accountPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Account privacy and security settings'**
  String get accountPrivacySecurity;

  /// No description provided for @displayLanguageUnits.
  ///
  /// In en, this message translates to:
  /// **'Display, language, and unit settings'**
  String get displayLanguageUnits;

  /// No description provided for @faqContactSupport.
  ///
  /// In en, this message translates to:
  /// **'FAQ and contact support'**
  String get faqContactSupport;

  /// No description provided for @appVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appVersionInfo;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @totalTrips.
  ///
  /// In en, this message translates to:
  /// **'Total Trips'**
  String get totalTrips;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @maintenanceCount.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceCount;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @updateProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Update profile photo'**
  String get updateProfilePhoto;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @profileUpdateTip.
  ///
  /// In en, this message translates to:
  /// **'Keep your profile up to date for better personalization!'**
  String get profileUpdateTip;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @distanceUnit.
  ///
  /// In en, this message translates to:
  /// **'Distance Unit'**
  String get distanceUnit;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'kilometers'**
  String get kilometers;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// No description provided for @fuelUnit.
  ///
  /// In en, this message translates to:
  /// **'Fuel Unit'**
  String get fuelUnit;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liters;

  /// No description provided for @gallons.
  ///
  /// In en, this message translates to:
  /// **'Gallons'**
  String get gallons;

  /// No description provided for @gpsAndBattery.
  ///
  /// In en, this message translates to:
  /// **'GPS & Battery'**
  String get gpsAndBattery;

  /// No description provided for @autoStartGPS.
  ///
  /// In en, this message translates to:
  /// **'Auto-start GPS Tracking'**
  String get autoStartGPS;

  /// No description provided for @autoStartGPSDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically start GPS when opening the app'**
  String get autoStartGPSDesc;

  /// No description provided for @batteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get batteryOptimization;

  /// No description provided for @batteryOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce battery usage during long trips'**
  String get batteryOptimizationDesc;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @enableDisableAll.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable all notifications'**
  String get enableDisableAll;

  /// No description provided for @maintenanceNotifications.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Notifications'**
  String get maintenanceNotifications;

  /// No description provided for @scheduleReminders.
  ///
  /// In en, this message translates to:
  /// **'Schedule Reminders'**
  String get scheduleReminders;

  /// No description provided for @scheduleRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminder for scheduled maintenance'**
  String get scheduleRemindersDesc;

  /// No description provided for @urgentMaintenanceNotif.
  ///
  /// In en, this message translates to:
  /// **'Urgent Maintenance'**
  String get urgentMaintenanceNotif;

  /// No description provided for @urgentMaintenanceNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert for components requiring urgent attention'**
  String get urgentMaintenanceNotifDesc;

  /// No description provided for @periodicServiceNotif.
  ///
  /// In en, this message translates to:
  /// **'Periodic Service'**
  String get periodicServiceNotif;

  /// No description provided for @periodicServiceNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Scheduled periodic service reminder'**
  String get periodicServiceNotifDesc;

  /// No description provided for @tripNotifications.
  ///
  /// In en, this message translates to:
  /// **'Trip Notifications'**
  String get tripNotifications;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @dailySummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily trip statistics summary'**
  String get dailySummaryDesc;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @weeklySummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekly trip activity report'**
  String get weeklySummaryDesc;

  /// No description provided for @longTripAlert.
  ///
  /// In en, this message translates to:
  /// **'Long Trip Alert'**
  String get longTripAlert;

  /// No description provided for @longTripAlertDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification for trips over 100 km'**
  String get longTripAlertDesc;

  /// No description provided for @vehicleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Notifications'**
  String get vehicleNotifications;

  /// No description provided for @vehicleSwitching.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Switching'**
  String get vehicleSwitching;

  /// No description provided for @vehicleSwitchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification when switching between vehicles'**
  String get vehicleSwitchingDesc;

  /// No description provided for @vehicleStatus.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Status'**
  String get vehicleStatus;

  /// No description provided for @vehicleStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Updates on vehicle condition'**
  String get vehicleStatusDesc;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @appUpdates.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get appUpdates;

  /// No description provided for @appUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'New features and update notifications'**
  String get appUpdatesDesc;

  /// No description provided for @syncErrors.
  ///
  /// In en, this message translates to:
  /// **'Sync Errors'**
  String get syncErrors;

  /// No description provided for @syncErrorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert when data sync fails'**
  String get syncErrorsDesc;

  /// No description provided for @recommendedSettings.
  ///
  /// In en, this message translates to:
  /// **'Recommended Settings'**
  String get recommendedSettings;

  /// No description provided for @recommendedSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'We recommend enabling schedule reminders and urgent maintenance notifications for optimal vehicle care.'**
  String get recommendedSettingsDesc;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location Data'**
  String get shareLocation;

  /// No description provided for @shareLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow app to use location for trip tracking'**
  String get shareLocationDesc;

  /// No description provided for @shareTripData.
  ///
  /// In en, this message translates to:
  /// **'Share Trip Data'**
  String get shareTripData;

  /// No description provided for @shareTripDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Share anonymized trip data for service improvement'**
  String get shareTripDataDesc;

  /// No description provided for @analyticsUsage.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Usage Data'**
  String get analyticsUsage;

  /// No description provided for @analyticsUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app by sharing usage data'**
  String get analyticsUsageDesc;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordDesc;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Add extra security layer to your account'**
  String get twoFactorAuthDesc;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @activeSessionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage devices logged into your account'**
  String get activeSessionsDesc;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @downloadMyData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// No description provided for @downloadMyDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Download all your data in JSON format'**
  String get downloadMyDataDesc;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete temporary files and cached data'**
  String get clearCacheDesc;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account and all data'**
  String get deleteAccountDesc;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'**
  String get deleteAccountConfirm;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear cache? This will free up storage space.'**
  String get clearCacheConfirm;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team'**
  String get getInTouch;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Contact us via email'**
  String get emailSupportDesc;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @whatsappSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with us on WhatsApp'**
  String get whatsappSupportDesc;

  /// No description provided for @openWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get openWhatsApp;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @phoneSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Call our support team'**
  String get phoneSupportDesc;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @findAnswers.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get findAnswers;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @helpfulLinks.
  ///
  /// In en, this message translates to:
  /// **'Helpful links and documentation'**
  String get helpfulLinks;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @userGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete guide to using the app'**
  String get userGuideDesc;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @termsConditionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsConditionsDesc;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'How we protect your data'**
  String get privacyPolicyDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ in Indonesia'**
  String get madeWithLove;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience'**
  String get preparing;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @goodCondition.
  ///
  /// In en, this message translates to:
  /// **'Good Condition'**
  String get goodCondition;

  /// No description provided for @serviceIn.
  ///
  /// In en, this message translates to:
  /// **'Service in'**
  String get serviceIn;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get startTracking;

  /// No description provided for @manualDistance.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Distance'**
  String get manualDistance;

  /// No description provided for @manualDistanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this feature if you forgot to turn on tracking'**
  String get manualDistanceDesc;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @activeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Active Vehicle'**
  String get activeVehicle;

  /// No description provided for @distanceSinceService.
  ///
  /// In en, this message translates to:
  /// **'Distance since last service'**
  String get distanceSinceService;

  /// No description provided for @untilNextService.
  ///
  /// In en, this message translates to:
  /// **'Until next service'**
  String get untilNextService;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @thisWeekYouRode.
  ///
  /// In en, this message translates to:
  /// **'This week you rode'**
  String get thisWeekYouRode;

  /// No description provided for @checkOilLevel.
  ///
  /// In en, this message translates to:
  /// **'Check Oil Level'**
  String get checkOilLevel;

  /// No description provided for @oilCheckReminder.
  ///
  /// In en, this message translates to:
  /// **'It\'s been over 2 months since the last service. Check the oil level.'**
  String get oilCheckReminder;

  /// No description provided for @generatedFromAnalysis.
  ///
  /// In en, this message translates to:
  /// **'GENERATED FROM SYSTEM ANALYSIS'**
  String get generatedFromAnalysis;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @addDistance.
  ///
  /// In en, this message translates to:
  /// **'Add Distance'**
  String get addDistance;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'trip'**
  String get trip;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get smartInsights;

  /// No description provided for @usageBasedMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Usage-Based Maintenance'**
  String get usageBasedMaintenance;

  /// No description provided for @usageBasedMaintenanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Your light usage pattern (12 km/day avg) extends maintenance intervals. Oil change recommended at 3,500 km.'**
  String get usageBasedMaintenanceDesc;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Trend'**
  String get weeklyTrend;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @thisWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekProgress;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'increase'**
  String get increase;

  /// No description provided for @systemWork.
  ///
  /// In en, this message translates to:
  /// **'How System Works'**
  String get systemWork;

  /// No description provided for @systemWorkDesc.
  ///
  /// In en, this message translates to:
  /// **'Algorithm transparency and system logic'**
  String get systemWorkDesc;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @pressStartToTrack.
  ///
  /// In en, this message translates to:
  /// **'Press \"Start\" to track'**
  String get pressStartToTrack;

  /// No description provided for @ensureGPSActive.
  ///
  /// In en, this message translates to:
  /// **'Make sure your GPS is active'**
  String get ensureGPSActive;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @maxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maxSpeed;

  /// No description provided for @viewTripHistory.
  ///
  /// In en, this message translates to:
  /// **'Viewing Trip History'**
  String get viewTripHistory;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'GPS tracking active • Recording your route'**
  String get trackingActive;

  /// No description provided for @stopAndSave.
  ///
  /// In en, this message translates to:
  /// **'Stop & Save'**
  String get stopAndSave;

  /// No description provided for @gpsActive.
  ///
  /// In en, this message translates to:
  /// **'GPS Active'**
  String get gpsActive;

  /// No description provided for @totalDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistanceLabel;

  /// No description provided for @livePerformance.
  ///
  /// In en, this message translates to:
  /// **'Live Performance'**
  String get livePerformance;

  /// No description provided for @currentSpeedFaster.
  ///
  /// In en, this message translates to:
  /// **'Current speed '**
  String get currentSpeedFaster;

  /// No description provided for @fasterThanAverage.
  ///
  /// In en, this message translates to:
  /// **'faster '**
  String get fasterThanAverage;

  /// No description provided for @thanAverage.
  ///
  /// In en, this message translates to:
  /// **'than average'**
  String get thanAverage;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @trackingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tracking Completed'**
  String get trackingCompleted;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistory;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @thisWeekFilter.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekFilter;

  /// No description provided for @thisMonthFilter.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthFilter;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @avgTrip.
  ///
  /// In en, this message translates to:
  /// **'Avg Trip'**
  String get avgTrip;

  /// No description provided for @kmPerTrip.
  ///
  /// In en, this message translates to:
  /// **'km per trip'**
  String get kmPerTrip;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @hoursRiding.
  ///
  /// In en, this message translates to:
  /// **'hours riding'**
  String get hoursRiding;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get avgSpeed;

  /// No description provided for @tripDetail.
  ///
  /// In en, this message translates to:
  /// **'Trip Detail'**
  String get tripDetail;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @speedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Speed Statistics'**
  String get speedStatistics;

  /// No description provided for @averageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average Speed'**
  String get averageSpeed;

  /// No description provided for @maxSpeedEstimate.
  ///
  /// In en, this message translates to:
  /// **'Max Speed (estimate)'**
  String get maxSpeedEstimate;

  /// No description provided for @routeInformation.
  ///
  /// In en, this message translates to:
  /// **'Route Information'**
  String get routeInformation;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @locationRecorded.
  ///
  /// In en, this message translates to:
  /// **'Location recorded'**
  String get locationRecorded;

  /// No description provided for @tripSummary.
  ///
  /// In en, this message translates to:
  /// **'This trip covered '**
  String get tripSummary;

  /// No description provided for @tripSummary2.
  ///
  /// In en, this message translates to:
  /// **' in '**
  String get tripSummary2;

  /// No description provided for @tripSummary3.
  ///
  /// In en, this message translates to:
  /// **' with an average speed of '**
  String get tripSummary3;

  /// No description provided for @inputDistance.
  ///
  /// In en, this message translates to:
  /// **'Input Distance'**
  String get inputDistance;

  /// No description provided for @addMissedTrip.
  ///
  /// In en, this message translates to:
  /// **'Add missed trip distance'**
  String get addMissedTrip;

  /// No description provided for @distanceTraveled.
  ///
  /// In en, this message translates to:
  /// **'Distance Traveled (km)'**
  String get distanceTraveled;

  /// No description provided for @distancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: 12.5'**
  String get distancePlaceholder;

  /// No description provided for @distanceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter distance in kilometers (use period for decimal)'**
  String get distanceHint;

  /// No description provided for @tripDate.
  ///
  /// In en, this message translates to:
  /// **'Trip Date'**
  String get tripDate;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle'**
  String get selectVehicle;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g.: trip back to hometown'**
  String get notesPlaceholder;

  /// No description provided for @distanceWillBeAdded.
  ///
  /// In en, this message translates to:
  /// **'This distance will be added to vehicle odometer and calculated in next service schedule.'**
  String get distanceWillBeAdded;

  /// No description provided for @distanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Distance saved successfully'**
  String get distanceSaved;

  /// No description provided for @myVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// No description provided for @selectOrManageVehicles.
  ///
  /// In en, this message translates to:
  /// **'Select or manage your motorcycles'**
  String get selectOrManageVehicles;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// No description provided for @vehicleName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicleName;

  /// No description provided for @vehicleNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g.: My Ninja'**
  String get vehicleNamePlaceholder;

  /// No description provided for @brandPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Kawasaki'**
  String get brandPlaceholder;

  /// No description provided for @modelPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Ninja 250'**
  String get modelPlaceholder;

  /// No description provided for @currentOdometerKm.
  ///
  /// In en, this message translates to:
  /// **'Current Odometer (km)'**
  String get currentOdometerKm;

  /// No description provided for @setAsMainVehicle.
  ///
  /// In en, this message translates to:
  /// **'Set as main vehicle'**
  String get setAsMainVehicle;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @switchVehicle.
  ///
  /// In en, this message translates to:
  /// **'Switch Active Vehicle'**
  String get switchVehicle;

  /// No description provided for @switchVehicleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to make \"{vehicleName}\" the active vehicle?'**
  String switchVehicleConfirm(String vehicleName);

  /// No description provided for @yesSwitch.
  ///
  /// In en, this message translates to:
  /// **'Yes, Switch'**
  String get yesSwitch;

  /// No description provided for @deleteVehicle.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicle;

  /// No description provided for @deleteVehicleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{vehicleName}\"? This action cannot be undone.'**
  String deleteVehicleConfirm(String vehicleName);

  /// No description provided for @vehicleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get vehicleUpdated;

  /// No description provided for @vehicleDeleted.
  ///
  /// In en, this message translates to:
  /// **' deleted successfully'**
  String get vehicleDeleted;

  /// No description provided for @nowActiveVehicle.
  ///
  /// In en, this message translates to:
  /// **' is now the active vehicle'**
  String get nowActiveVehicle;

  /// No description provided for @ridingInsights.
  ///
  /// In en, this message translates to:
  /// **'Riding Insights'**
  String get ridingInsights;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stats'**
  String get weeklyStats;

  /// No description provided for @patterns.
  ///
  /// In en, this message translates to:
  /// **'Patterns'**
  String get patterns;

  /// No description provided for @totalDistanceWeek.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistanceWeek;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @peakActivity.
  ///
  /// In en, this message translates to:
  /// **'Peak Activity'**
  String get peakActivity;

  /// No description provided for @mostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Your most active day is '**
  String get mostActiveDay;

  /// No description provided for @withAverage.
  ///
  /// In en, this message translates to:
  /// **' with an average of '**
  String get withAverage;

  /// No description provided for @ridingTimePatterns.
  ///
  /// In en, this message translates to:
  /// **'Riding Time Patterns'**
  String get ridingTimePatterns;

  /// No description provided for @tripsLabel.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsLabel;

  /// No description provided for @eveningCommuter.
  ///
  /// In en, this message translates to:
  /// **'Evening Commuter'**
  String get eveningCommuter;

  /// No description provided for @eveningCommuterDesc.
  ///
  /// In en, this message translates to:
  /// **'You ride most frequently around 6 PM, suggesting evening commutes or after-work activities.'**
  String get eveningCommuterDesc;

  /// No description provided for @shortTripPattern.
  ///
  /// In en, this message translates to:
  /// **'Short Trip Pattern'**
  String get shortTripPattern;

  /// No description provided for @shortTripPatternDesc.
  ///
  /// In en, this message translates to:
  /// **'Average trip distance is 39.0 km. Frequent short trips may require more regular maintenance.'**
  String get shortTripPatternDesc;

  /// No description provided for @optimalServiceWindow.
  ///
  /// In en, this message translates to:
  /// **'Optimal Service Window'**
  String get optimalServiceWindow;

  /// No description provided for @optimalServiceWindowDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on your usage pattern, plan service during weekday mornings when you ride less.'**
  String get optimalServiceWindowDesc;

  /// No description provided for @howSystemWorks.
  ///
  /// In en, this message translates to:
  /// **'How System Works'**
  String get howSystemWorks;

  /// No description provided for @transparencyAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm transparency and system logic'**
  String get transparencyAlgorithm;

  /// No description provided for @adaptiveSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Data-Based Adaptive System'**
  String get adaptiveSystemTitle;

  /// No description provided for @adaptiveSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'This app uses a data-driven analysis approach to adjust maintenance recommendations based on your vehicle usage patterns in real-time.'**
  String get adaptiveSystemDesc;

  /// No description provided for @dataAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Data Analyzed by System'**
  String get dataAnalyzed;

  /// No description provided for @mileageData.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileageData;

  /// No description provided for @mileageDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Total kilometers traveled and your daily trip patterns'**
  String get mileageDataDesc;

  /// No description provided for @lastServiceTime.
  ///
  /// In en, this message translates to:
  /// **'Last Service Time'**
  String get lastServiceTime;

  /// No description provided for @lastServiceTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Date and odometer reading when last maintenance was performed'**
  String get lastServiceTimeDesc;

  /// No description provided for @usageFrequency.
  ///
  /// In en, this message translates to:
  /// **'Usage Frequency'**
  String get usageFrequency;

  /// No description provided for @usageFrequencyDesc.
  ///
  /// In en, this message translates to:
  /// **'How often the vehicle is used in a specific period'**
  String get usageFrequencyDesc;

  /// No description provided for @maintenanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Maintenance History'**
  String get maintenanceHistory;

  /// No description provided for @maintenanceHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Historical data of services and component replacements'**
  String get maintenanceHistoryDesc;

  /// No description provided for @howSystemWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How System Works'**
  String get howSystemWorksTitle;

  /// No description provided for @usageClassification.
  ///
  /// In en, this message translates to:
  /// **'Usage Pattern Classification'**
  String get usageClassification;

  /// No description provided for @usageClassificationDesc.
  ///
  /// In en, this message translates to:
  /// **'System calculates average daily mileage and classifies it as '**
  String get usageClassificationDesc;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightUsageDetail.
  ///
  /// In en, this message translates to:
  /// **' (<15km/day), '**
  String get lightUsageDetail;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @normalUsageDetail.
  ///
  /// In en, this message translates to:
  /// **' (15-50km/day), or '**
  String get normalUsageDetail;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @heavyUsageDetail.
  ///
  /// In en, this message translates to:
  /// **' (>50km/day).'**
  String get heavyUsageDetail;

  /// No description provided for @intervalAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Interval Adjustment'**
  String get intervalAdjustment;

  /// No description provided for @intervalAdjustmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard intervals (e.g., oil change every 3000km) are adjusted based on usage intensity for optimal results.'**
  String get intervalAdjustmentDesc;

  /// No description provided for @trendDetection.
  ///
  /// In en, this message translates to:
  /// **'Trend and Anomaly Detection'**
  String get trendDetection;

  /// No description provided for @trendDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'System monitors weekly pattern changes to detect changes in your riding habits.'**
  String get trendDetectionDesc;

  /// No description provided for @contextualRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Contextual Recommendations'**
  String get contextualRecommendations;

  /// No description provided for @contextualRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Displayed insights are selected based on relevance to current vehicle condition and usage patterns.'**
  String get contextualRecommendationsDesc;

  /// No description provided for @technicalNote.
  ///
  /// In en, this message translates to:
  /// **'Technical Note'**
  String get technicalNote;

  /// No description provided for @technicalNoteDesc.
  ///
  /// In en, this message translates to:
  /// **'This system uses a deterministic approach with verifiable business rules. All calculations and recommendations are based on actual vehicle usage data.'**
  String get technicalNoteDesc;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Maintenance Scheduling based on Usage Patterns and Predictive Analytics'**
  String get reference;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Notification Center'**
  String get notificationCenter;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @maintenanceReminder.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Reminder'**
  String get maintenanceReminder;

  /// No description provided for @oilChangeReminder.
  ///
  /// In en, this message translates to:
  /// **'Oil change needed soon'**
  String get oilChangeReminder;

  /// No description provided for @oilChangeDue.
  ///
  /// In en, this message translates to:
  /// **'Your motorcycle has reached 8,450 km. Oil change is recommended at 9,000 km.'**
  String get oilChangeDue;

  /// No description provided for @newInsight.
  ///
  /// In en, this message translates to:
  /// **'New Insight'**
  String get newInsight;

  /// No description provided for @weeklyUsagePattern.
  ///
  /// In en, this message translates to:
  /// **'Weekly usage pattern detected'**
  String get weeklyUsagePattern;

  /// No description provided for @ridingMostEvening.
  ///
  /// In en, this message translates to:
  /// **'You\'re riding most in the evening. Consider scheduling maintenance on weekday mornings.'**
  String get ridingMostEvening;

  /// No description provided for @systemUpdate.
  ///
  /// In en, this message translates to:
  /// **'System Update'**
  String get systemUpdate;

  /// No description provided for @newFeaturesAvailable.
  ///
  /// In en, this message translates to:
  /// **'New features available'**
  String get newFeaturesAvailable;

  /// No description provided for @checkLatestFeatures.
  ///
  /// In en, this message translates to:
  /// **'Check out the latest features in version 2.1.0: Improved GPS tracking and enhanced insights.'**
  String get checkLatestFeatures;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MotoTracker'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Track, Maintain, Ride'**
  String get appTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailHint;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join MotoTracker today'**
  String get joinToday;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get passwordStrength;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'08123456789'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'We will send you a verification code'**
  String get sendVerificationCode;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a verification code to reset your password'**
  String get forgotPasswordDesc;

  /// No description provided for @sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOTP;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterOTPCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent'**
  String get enterOTPCode;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification code to the email address {email}'**
  String otpSentTo(String email);

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @newPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previous passwords'**
  String get newPasswordDesc;

  /// No description provided for @forAccount.
  ///
  /// In en, this message translates to:
  /// **'For account:'**
  String get forAccount;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get passwordRequirements;

  /// No description provided for @minLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get minLength;

  /// No description provided for @minUpperCase.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get minUpperCase;

  /// No description provided for @minLowerCase.
  ///
  /// In en, this message translates to:
  /// **'At least 1 lowercase letter'**
  String get minLowerCase;

  /// No description provided for @minNumber.
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get minNumber;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully!'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordChangedFor.
  ///
  /// In en, this message translates to:
  /// **'Password for account {email} has been changed successfully. You can now login with your new password.'**
  String passwordChangedFor(String email);

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips:'**
  String get securityTips;

  /// No description provided for @tipDontShare.
  ///
  /// In en, this message translates to:
  /// **'Never share your password with anyone'**
  String get tipDontShare;

  /// No description provided for @tipUseUnique.
  ///
  /// In en, this message translates to:
  /// **'Use a unique password for each account'**
  String get tipUseUnique;

  /// No description provided for @tipEnable2FA.
  ///
  /// In en, this message translates to:
  /// **'Enable two-factor authentication when available'**
  String get tipEnable2FA;

  /// No description provided for @backToLoginBtn.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLoginBtn;

  /// No description provided for @autoRedirect.
  ///
  /// In en, this message translates to:
  /// **'You will be automatically redirected in {seconds} seconds'**
  String autoRedirect(int seconds);

  /// No description provided for @yourPasswordSecure.
  ///
  /// In en, this message translates to:
  /// **'Your Password is Secure'**
  String get yourPasswordSecure;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registrationSuccess;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MotoTracker! Your account for {email} has been created successfully. Let\'s start tracking your motorcycle.'**
  String welcomeTo(String email);

  /// No description provided for @featureGPSTracking.
  ///
  /// In en, this message translates to:
  /// **'Automatic GPS Distance Tracking'**
  String get featureGPSTracking;

  /// No description provided for @featureGPSTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your rides accurately'**
  String get featureGPSTrackingDesc;

  /// No description provided for @featureSmartReminder.
  ///
  /// In en, this message translates to:
  /// **'Smart Service Reminders'**
  String get featureSmartReminder;

  /// No description provided for @featureSmartReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss any maintenance'**
  String get featureSmartReminderDesc;

  /// No description provided for @featureRidingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Riding Pattern Analysis'**
  String get featureRidingAnalysis;

  /// No description provided for @featureRidingAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Optimize your motorcycle performance'**
  String get featureRidingAnalysisDesc;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Motorcycle'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Monitor your vehicle condition and performance easily. Add multiple motorcycles and switch between vehicles quickly.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Real-time GPS Tracking'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Record every trip with GPS tracking. View routes, distance traveled, and your trip statistics in detail.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Maintenance Schedule'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'The system will remind you of service schedule based on mileage and time. Never miss maintenance again.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Analysis & Insights'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In en, this message translates to:
  /// **'Get usage pattern insights and maintenance recommendations tailored to your riding habits.'**
  String get onboarding4Desc;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifFilterAll;

  /// No description provided for @unreadNotificationsCount.
  ///
  /// In en, this message translates to:
  /// **'unread notifications'**
  String get unreadNotificationsCount;

  /// No description provided for @notifOilChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for Oil Change'**
  String get notifOilChangeTitle;

  /// No description provided for @notifOilChangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Next service in 550 km. Schedule now for optimal results.'**
  String get notifOilChangeDesc;

  /// No description provided for @notifTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2 hours ago'**
  String get notifTimeHoursAgo;

  /// No description provided for @notifCategoryService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get notifCategoryService;

  /// No description provided for @notifLongTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Long Trip Detected'**
  String get notifLongTripTitle;

  /// No description provided for @notifLongTripDesc.
  ///
  /// In en, this message translates to:
  /// **'You traveled 45.2 km today. Make sure your motorcycle is in prime condition.'**
  String get notifLongTripDesc;

  /// No description provided for @notifTimeFiveHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'5 hours ago'**
  String get notifTimeFiveHoursAgo;

  /// No description provided for @notifCategoryTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get notifCategoryTrip;

  /// No description provided for @notifTirePressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Tire Pressure Needs Checking'**
  String get notifTirePressureTitle;

  /// No description provided for @notifTirePressureDesc.
  ///
  /// In en, this message translates to:
  /// **'It\'s been 2 weeks since the last check. Check your tire pressure.'**
  String get notifTirePressureDesc;

  /// No description provided for @notifTimeOneDayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get notifTimeOneDayAgo;

  /// No description provided for @notifCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get notifCategoryWarning;

  /// No description provided for @notifEfficientDrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'Efficient Riding Pattern'**
  String get notifEfficientDrivingTitle;

  /// No description provided for @notifEfficientDrivingDesc.
  ///
  /// In en, this message translates to:
  /// **'You saved 15% fuel this week compared to last week. Keep it up!'**
  String get notifEfficientDrivingDesc;

  /// No description provided for @notifTimeTwoDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get notifTimeTwoDaysAgo;

  /// No description provided for @notifCategoryRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get notifCategoryRecommendation;

  /// No description provided for @notifServiceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Service History'**
  String get notifServiceHistoryTitle;

  /// No description provided for @notifServiceHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'All your service records have been synchronized successfully.'**
  String get notifServiceHistoryDesc;

  /// No description provided for @notifTimeThreeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'3 days ago'**
  String get notifTimeThreeDaysAgo;

  /// No description provided for @deleteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotificationTitle;

  /// No description provided for @deleteNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteNotificationMessage;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @reminderDistance100km.
  ///
  /// In en, this message translates to:
  /// **'100 km before'**
  String get reminderDistance100km;

  /// No description provided for @reminderDistance200km.
  ///
  /// In en, this message translates to:
  /// **'200 km before'**
  String get reminderDistance200km;

  /// No description provided for @reminderDistance300km.
  ///
  /// In en, this message translates to:
  /// **'300 km before'**
  String get reminderDistance300km;

  /// No description provided for @reminderDistance500km.
  ///
  /// In en, this message translates to:
  /// **'500 km before'**
  String get reminderDistance500km;

  /// No description provided for @reminderTime1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderTime1Day;

  /// No description provided for @reminderTime3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get reminderTime3Days;

  /// No description provided for @reminderTime1Week.
  ///
  /// In en, this message translates to:
  /// **'1 week before'**
  String get reminderTime1Week;

  /// No description provided for @reminderTime2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks before'**
  String get reminderTime2Weeks;

  /// No description provided for @reminderTime1Month.
  ///
  /// In en, this message translates to:
  /// **'1 month before'**
  String get reminderTime1Month;

  /// No description provided for @exampleKm10000.
  ///
  /// In en, this message translates to:
  /// **'Example: 10000'**
  String get exampleKm10000;

  /// No description provided for @exampleMonths6.
  ///
  /// In en, this message translates to:
  /// **'Example: 6'**
  String get exampleMonths6;

  /// No description provided for @remindMeBeforeDue.
  ///
  /// In en, this message translates to:
  /// **'Remind me before due date'**
  String get remindMeBeforeDue;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @liveChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant response from support team'**
  String get liveChatSubtitle;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @openingLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Opening live chat...'**
  String get openingLiveChat;

  /// No description provided for @openingEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Opening email client...'**
  String get openingEmailClient;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @faqAddMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'How to add a new motorcycle?'**
  String get faqAddMotorcycle;

  /// No description provided for @faqAddMotorcycleAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open the Vehicle page from the bottom menu, then tap the \'+\' button in the top right corner. Fill in your motorcycle information such as brand, model, year, and license plate number. When finished, tap \'Save\' to add the motorcycle to your list.'**
  String get faqAddMotorcycleAnswer;

  /// No description provided for @faqStartTracking.
  ///
  /// In en, this message translates to:
  /// **'How to start trip tracking?'**
  String get faqStartTracking;

  /// No description provided for @faqStartTrackingAnswer.
  ///
  /// In en, this message translates to:
  /// **'From Dashboard, tap the \'Start Trip\' button or open the GPS Tracking menu. Make sure GPS and location permission are enabled. Tap \'Start\' to begin recording.'**
  String get faqStartTrackingAnswer;

  /// No description provided for @faqNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'Why aren\'t service notifications appearing?'**
  String get faqNoNotifications;

  /// No description provided for @faqNoNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check notification settings in Profile > Notifications & Alerts menu. Make sure \'Enable All Notifications\' and \'Service Schedule\' are ON.'**
  String get faqNoNotificationsAnswer;

  /// No description provided for @faqSwitchMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'How to change active motorcycle?'**
  String get faqSwitchMotorcycle;

  /// No description provided for @faqSwitchMotorcycleAnswer.
  ///
  /// In en, this message translates to:
  /// **'From Dashboard, tap the motorcycle name at the top or open Vehicle menu and select \'Change Active Vehicle\'. Choose the motorcycle you want to activate.'**
  String get faqSwitchMotorcycleAnswer;

  /// No description provided for @faqDataLost.
  ///
  /// In en, this message translates to:
  /// **'My data is lost after app update?'**
  String get faqDataLost;

  /// No description provided for @faqDataLostAnswer.
  ///
  /// In en, this message translates to:
  /// **'Data is stored locally in your browser. Make sure you don\'t delete browser cache. For data security, we recommend regularly exporting data or using cloud backup feature (coming soon).'**
  String get faqDataLostAnswer;

  /// No description provided for @faqContactWorkshop.
  ///
  /// In en, this message translates to:
  /// **'How to contact a workshop?'**
  String get faqContactWorkshop;

  /// No description provided for @faqContactWorkshopAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open Workshop menu, select the workshop you want to contact, then tap the phone or email icon to contact them directly.'**
  String get faqContactWorkshopAnswer;

  /// No description provided for @lastUpdated30Jan2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 30, 2026'**
  String get lastUpdated30Jan2026;

  /// No description provided for @ourPrivacyCommitment.
  ///
  /// In en, this message translates to:
  /// **'Our Privacy Commitment'**
  String get ourPrivacyCommitment;

  /// No description provided for @privacyCommitmentDesc.
  ///
  /// In en, this message translates to:
  /// **'At MotoTracker, we highly value your privacy. This policy explains how we collect, use, and protect your personal information.'**
  String get privacyCommitmentDesc;

  /// No description provided for @section1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get section1Title;

  /// No description provided for @accountInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfoSubtitle;

  /// No description provided for @accountInfoItem1.
  ///
  /// In en, this message translates to:
  /// **'Full name and email during registration'**
  String get accountInfoItem1;

  /// No description provided for @accountInfoItem2.
  ///
  /// In en, this message translates to:
  /// **'Encrypted password for account security'**
  String get accountInfoItem2;

  /// No description provided for @accountInfoItem3.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional) for verification'**
  String get accountInfoItem3;

  /// No description provided for @vehicleDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Data'**
  String get vehicleDataSubtitle;

  /// No description provided for @vehicleDataItem1.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle information: brand, model, year, license plate'**
  String get vehicleDataItem1;

  /// No description provided for @vehicleDataItem2.
  ///
  /// In en, this message translates to:
  /// **'Odometer and mileage history'**
  String get vehicleDataItem2;

  /// No description provided for @vehicleDataItem3.
  ///
  /// In en, this message translates to:
  /// **'Vehicle photos you upload'**
  String get vehicleDataItem3;

  /// No description provided for @tripLocationDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trip & Location Data'**
  String get tripLocationDataSubtitle;

  /// No description provided for @tripLocationItem1.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates during trip tracking (with your permission)'**
  String get tripLocationItem1;

  /// No description provided for @tripLocationItem2.
  ///
  /// In en, this message translates to:
  /// **'Route, distance, duration, and travel speed'**
  String get tripLocationItem2;

  /// No description provided for @tripLocationItem3.
  ///
  /// In en, this message translates to:
  /// **'Location is only accessed when app is active and you start a trip'**
  String get tripLocationItem3;

  /// No description provided for @maintenanceHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance History'**
  String get maintenanceHistorySubtitle;

  /// No description provided for @maintenanceItem1.
  ///
  /// In en, this message translates to:
  /// **'Date and type of service performed'**
  String get maintenanceItem1;

  /// No description provided for @maintenanceItem2.
  ///
  /// In en, this message translates to:
  /// **'Maintenance costs and technician notes'**
  String get maintenanceItem2;

  /// No description provided for @maintenanceItem3.
  ///
  /// In en, this message translates to:
  /// **'Photos of receipts/service proof (optional)'**
  String get maintenanceItem3;

  /// No description provided for @section2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Information Usage'**
  String get section2Title;

  /// No description provided for @personalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Personalization:'**
  String get personalizationTitle;

  /// No description provided for @personalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize dashboard and maintenance recommendations based on your motorcycle usage patterns.'**
  String get personalizationDesc;

  /// No description provided for @maintenancePredictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Prediction:'**
  String get maintenancePredictionTitle;

  /// No description provided for @maintenancePredictionDesc.
  ///
  /// In en, this message translates to:
  /// **'Using AI to predict optimal service schedules.'**
  String get maintenancePredictionDesc;

  /// No description provided for @notificationsAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alerts:'**
  String get notificationsAlertsTitle;

  /// No description provided for @notificationsAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Send service reminders, app updates, and important information.'**
  String get notificationsAlertsDesc;

  /// No description provided for @serviceImprovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Improvement:'**
  String get serviceImprovementTitle;

  /// No description provided for @serviceImprovementDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze anonymous data to develop new features and improve app performance.'**
  String get serviceImprovementDesc;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security:'**
  String get securityTitle;

  /// No description provided for @securityDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect suspicious activity and protect your account.'**
  String get securityDesc;

  /// No description provided for @section3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security'**
  String get section3Title;

  /// No description provided for @encryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encryption:'**
  String get encryptionTitle;

  /// No description provided for @encryptionDesc.
  ///
  /// In en, this message translates to:
  /// **'All sensitive data is encrypted during transit and storage.'**
  String get encryptionDesc;

  /// No description provided for @localStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Storage:'**
  String get localStorageTitle;

  /// No description provided for @localStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Data is stored in your browser. You have full control.'**
  String get localStorageDesc;

  /// No description provided for @limitedAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited Access:'**
  String get limitedAccessTitle;

  /// No description provided for @limitedAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Only certain engineering team members have access to the backend.'**
  String get limitedAccessDesc;

  /// No description provided for @regularAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Regular Audits:'**
  String get regularAuditTitle;

  /// No description provided for @regularAuditDesc.
  ///
  /// In en, this message translates to:
  /// **'We conduct regular security audits to ensure data security.'**
  String get regularAuditDesc;

  /// No description provided for @section4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Sharing'**
  String get section4Title;

  /// No description provided for @noDataSharingStatement.
  ///
  /// In en, this message translates to:
  /// **'We will NOT share your data with third parties for commercial, advertising, or marketing purposes without your explicit permission.'**
  String get noDataSharingStatement;

  /// No description provided for @exceptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exceptions:'**
  String get exceptionsTitle;

  /// No description provided for @exceptionItem1.
  ///
  /// In en, this message translates to:
  /// **'If required by law or court order'**
  String get exceptionItem1;

  /// No description provided for @exceptionItem2.
  ///
  /// In en, this message translates to:
  /// **'With analytics vendors (anonymous data for statistics)'**
  String get exceptionItem2;

  /// No description provided for @exceptionItem3.
  ///
  /// In en, this message translates to:
  /// **'With your explicit consent for third-party integrations'**
  String get exceptionItem3;

  /// No description provided for @section5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get section5Title;

  /// No description provided for @dataAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Access:'**
  String get dataAccessTitle;

  /// No description provided for @dataAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'You can download all your data anytime through the \'Export Data\' menu.'**
  String get dataAccessDesc;

  /// No description provided for @correctionTitle.
  ///
  /// In en, this message translates to:
  /// **'Correction:'**
  String get correctionTitle;

  /// No description provided for @correctionDesc.
  ///
  /// In en, this message translates to:
  /// **'Update or correct your personal information directly in the app.'**
  String get correctionDesc;

  /// No description provided for @deletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion:'**
  String get deletionTitle;

  /// No description provided for @deletionDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account and all related data through \'Delete Account\'.'**
  String get deletionDesc;

  /// No description provided for @optOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Opt-out:'**
  String get optOutTitle;

  /// No description provided for @optOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable tracking, analytics, or notifications anytime.'**
  String get optOutDesc;

  /// No description provided for @contactUsEmail.
  ///
  /// In en, this message translates to:
  /// **'📧 Contact Us'**
  String get contactUsEmail;

  /// No description provided for @privacyContactIntro.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this privacy policy, contact:'**
  String get privacyContactIntro;

  /// No description provided for @privacyEmail.
  ///
  /// In en, this message translates to:
  /// **'privacy@mototracker.id'**
  String get privacyEmail;

  /// No description provided for @privacyFooter1.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MotoTracker. This policy may be updated at any time.'**
  String get privacyFooter1;

  /// No description provided for @privacyFooter2.
  ///
  /// In en, this message translates to:
  /// **'You will be notified via email if there are significant changes.'**
  String get privacyFooter2;

  /// No description provided for @completeGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete MotoTracker tutorial'**
  String get completeGuideSubtitle;

  /// No description provided for @welcomeGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'📖 Welcome!'**
  String get welcomeGuideTitle;

  /// No description provided for @welcomeGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete guide to maximize your experience with MotoTracker. Tap each category to view detailed tutorials.'**
  String get welcomeGuideDesc;

  /// No description provided for @gettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started with MotoTracker'**
  String get gettingStartedTitle;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'topics'**
  String get topics;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account'**
  String get creatingAccount;

  /// No description provided for @creatingAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Register with email and password. Verify your email through the OTP code sent. After verification, complete your profile with basic information.'**
  String get creatingAccountDesc;

  /// No description provided for @addingFirstMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Adding First Motorcycle'**
  String get addingFirstMotorcycle;

  /// No description provided for @addingFirstMotorcycleDesc.
  ///
  /// In en, this message translates to:
  /// **'From Dashboard, tap \'Add Motorcycle\' button. Fill in details like brand, model, year, license plate, and color. Upload motorcycle photo for personalization.'**
  String get addingFirstMotorcycleDesc;

  /// No description provided for @dashboardNavigation.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Navigation'**
  String get dashboardNavigation;

  /// No description provided for @dashboardNavigationDesc.
  ///
  /// In en, this message translates to:
  /// **'Dashboard displays active motorcycle summary, mileage, maintenance status, and insights. Use bottom menu for quick navigation between main features.'**
  String get dashboardNavigationDesc;

  /// No description provided for @managingVehicles.
  ///
  /// In en, this message translates to:
  /// **'Managing Vehicles'**
  String get managingVehicles;

  /// No description provided for @multiVehicle.
  ///
  /// In en, this message translates to:
  /// **'Multiple Vehicles'**
  String get multiVehicle;

  /// No description provided for @multiVehicleDesc.
  ///
  /// In en, this message translates to:
  /// **'Add up to 10 motorcycles in one account. Switch between vehicles by tapping motorcycle name on Dashboard or Vehicle menu.'**
  String get multiVehicleDesc;

  /// No description provided for @editMotorcycleInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Motorcycle Info'**
  String get editMotorcycleInfo;

  /// No description provided for @editMotorcycleInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Open vehicle details, tap edit icon (pencil). Update information like mileage, photos, or technical specifications anytime.'**
  String get editMotorcycleInfoDesc;

  /// No description provided for @deleteVehicleDesc.
  ///
  /// In en, this message translates to:
  /// **'On vehicle details page, scroll down and tap \'Delete Vehicle\'. Confirm deletion - data cannot be recovered.'**
  String get deleteVehicleDesc;

  /// No description provided for @gpsTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Tracking & Trips'**
  String get gpsTrackingTitle;

  /// No description provided for @startTripTracking.
  ///
  /// In en, this message translates to:
  /// **'Starting Trip Tracking'**
  String get startTripTracking;

  /// No description provided for @startTripTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Make sure GPS is active. Tap \'Start Trip\' on Dashboard or open GPS Tracking menu. Tap \'Start\' button to begin recording route and distance.'**
  String get startTripTrackingDesc;

  /// No description provided for @duringTrip.
  ///
  /// In en, this message translates to:
  /// **'During Trip'**
  String get duringTrip;

  /// No description provided for @duringTripDesc.
  ///
  /// In en, this message translates to:
  /// **'App will track location, distance, time, and speed in real-time. You can view live statistics on tracking screen.'**
  String get duringTripDesc;

  /// No description provided for @endingTrip.
  ///
  /// In en, this message translates to:
  /// **'Ending Trip'**
  String get endingTrip;

  /// No description provided for @endingTripDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Stop\' to end trip. Review trip summary including distance, duration, and route. Data is automatically saved to history.'**
  String get endingTripDesc;

  /// No description provided for @viewTripHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Open Trip History menu to view all trips. Filter by date, distance, or motorcycle. Tap trip for full details and route map.'**
  String get viewTripHistoryDesc;

  /// No description provided for @maintenanceServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance & Service'**
  String get maintenanceServiceTitle;

  /// No description provided for @smartMaintenanceTracking.
  ///
  /// In en, this message translates to:
  /// **'Smart Maintenance Tracking'**
  String get smartMaintenanceTracking;

  /// No description provided for @smartMaintenanceTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'System automatically calculates service intervals based on mileage and time. Notifications appear when approaching maintenance schedule.'**
  String get smartMaintenanceTrackingDesc;

  /// No description provided for @addServiceHistory.
  ///
  /// In en, this message translates to:
  /// **'Adding Service History'**
  String get addServiceHistory;

  /// No description provided for @addServiceHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add Service\' in Maintenance menu. Fill in date, service type, cost, and notes. Upload receipt proof for documentation.'**
  String get addServiceHistoryDesc;

  /// No description provided for @periodicServiceSchedule.
  ///
  /// In en, this message translates to:
  /// **'Periodic Service Schedule'**
  String get periodicServiceSchedule;

  /// No description provided for @periodicServiceScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'Set reminders for oil change, brake pads, tires, etc. Set interval based on mileage or months. System will alert before due date.'**
  String get periodicServiceScheduleDesc;

  /// No description provided for @workshopLocator.
  ///
  /// In en, this message translates to:
  /// **'Workshop Locator'**
  String get workshopLocator;

  /// No description provided for @workshopLocatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Find nearest workshop with GPS. View ratings, contact, operating hours. Tap to call directly or open in maps.'**
  String get workshopLocatorDesc;

  /// No description provided for @notificationsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Reminders'**
  String get notificationsRemindersTitle;

  /// No description provided for @settingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Setting Notifications'**
  String get settingNotifications;

  /// No description provided for @settingNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Open Profile > Notifications & Alerts. Enable/disable notifications per category: Maintenance, Trips, Vehicles, System.'**
  String get settingNotificationsDesc;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @notificationTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Service reminders (D-7, D-3, D-1), trip summary (daily/weekly), vehicle status, and system updates. Customize as needed.'**
  String get notificationTypesDesc;

  /// No description provided for @settingsPersonalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Personalization'**
  String get settingsPersonalizationTitle;

  /// No description provided for @appPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose distance unit (km/miles), fuel (liter/gallon). Set GPS auto-start and battery optimization for efficiency.'**
  String get appPreferencesDesc;

  /// No description provided for @privacySecurityTopic.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurityTopic;

  /// No description provided for @privacySecurityTopicDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA for extra security. Manage active sessions, change password, and control data sharing. Download or delete data anytime.'**
  String get privacySecurityTopicDesc;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your data regularly. Download in JSON format for local backup. Cloud sync coming soon.'**
  String get backupDataDesc;

  /// No description provided for @tipsAndTricks.
  ///
  /// In en, this message translates to:
  /// **'💡 Tips & Tricks'**
  String get tipsAndTricks;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'• Update mileage regularly for accurate maintenance prediction'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'• Enable GPS tracking for more detailed trip analysis'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'• Set service reminder D-7 to not miss schedule'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'• Backup your data regularly for security'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In en, this message translates to:
  /// **'• Use multi-vehicle feature to track all motorcycles'**
  String get tip5;

  /// No description provided for @stillHaveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Still have questions? Contact us at'**
  String get stillHaveQuestions;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@mototracker.id'**
  String get supportEmail;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @effectiveSince30Jan2026.
  ///
  /// In en, this message translates to:
  /// **'Effective since: January 30, 2026'**
  String get effectiveSince30Jan2026;

  /// No description provided for @welcomeToMotoTracker.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MotoTracker'**
  String get welcomeToMotoTracker;

  /// No description provided for @termsWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'By using the MotoTracker app, you agree to the following terms and conditions. Please read carefully before continuing to use the app.'**
  String get termsWelcomeDesc;

  /// No description provided for @section1AcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get section1AcceptanceTitle;

  /// No description provided for @acceptanceIntro.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using MotoTracker, you automatically agree to:'**
  String get acceptanceIntro;

  /// No description provided for @ageRequirement.
  ///
  /// In en, this message translates to:
  /// **'You are at least 17 years old or have parental/guardian permission'**
  String get ageRequirement;

  /// No description provided for @legalCapacity.
  ///
  /// In en, this message translates to:
  /// **'You have legal capacity to agree to this agreement'**
  String get legalCapacity;

  /// No description provided for @accurateInfo.
  ///
  /// In en, this message translates to:
  /// **'Information you provide is accurate and current'**
  String get accurateInfo;

  /// No description provided for @complyWithLaws.
  ///
  /// In en, this message translates to:
  /// **'You will comply with all applicable laws and regulations'**
  String get complyWithLaws;

  /// No description provided for @section2UserAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'2. User Account'**
  String get section2UserAccountTitle;

  /// No description provided for @accountResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Account Responsibility'**
  String get accountResponsibility;

  /// No description provided for @accountSecurityResponsibility.
  ///
  /// In en, this message translates to:
  /// **'You are fully responsible for your account and password security'**
  String get accountSecurityResponsibility;

  /// No description provided for @dontShareCredentials.
  ///
  /// In en, this message translates to:
  /// **'Don\'t share your login credentials with anyone'**
  String get dontShareCredentials;

  /// No description provided for @reportSuspiciousActivity.
  ///
  /// In en, this message translates to:
  /// **'Immediately report suspicious activity or unauthorized access'**
  String get reportSuspiciousActivity;

  /// No description provided for @noLiabilityForNegligence.
  ///
  /// In en, this message translates to:
  /// **'MotoTracker is not responsible for losses due to your negligence'**
  String get noLiabilityForNegligence;

  /// No description provided for @dataAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Data Accuracy'**
  String get dataAccuracy;

  /// No description provided for @dataAccuracyDesc.
  ///
  /// In en, this message translates to:
  /// **'You agree to provide accurate information during registration and update your data regularly. Data errors can affect service quality.'**
  String get dataAccuracyDesc;

  /// No description provided for @section3ServiceUseTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Service Usage'**
  String get section3ServiceUseTitle;

  /// No description provided for @permittedUse.
  ///
  /// In en, this message translates to:
  /// **'Permitted Use'**
  String get permittedUse;

  /// No description provided for @permittedUseItem1.
  ///
  /// In en, this message translates to:
  /// **'Tracking and managing your personal vehicles'**
  String get permittedUseItem1;

  /// No description provided for @permittedUseItem2.
  ///
  /// In en, this message translates to:
  /// **'Recording trips for personal purposes'**
  String get permittedUseItem2;

  /// No description provided for @permittedUseItem3.
  ///
  /// In en, this message translates to:
  /// **'Managing maintenance and service schedules'**
  String get permittedUseItem3;

  /// No description provided for @permittedUseItem4.
  ///
  /// In en, this message translates to:
  /// **'Sharing data with your explicit consent'**
  String get permittedUseItem4;

  /// No description provided for @serviceLimitations.
  ///
  /// In en, this message translates to:
  /// **'Service Limitations'**
  String get serviceLimitations;

  /// No description provided for @asIsProvision.
  ///
  /// In en, this message translates to:
  /// **'This app is provided \'as is\'. MotoTracker does not guarantee:'**
  String get asIsProvision;

  /// No description provided for @limitationItem1.
  ///
  /// In en, this message translates to:
  /// **'100% accuracy of maintenance predictions (use as guidance)'**
  String get limitationItem1;

  /// No description provided for @limitationItem2.
  ///
  /// In en, this message translates to:
  /// **'GPS tracking is always precise (depends on device signal)'**
  String get limitationItem2;

  /// No description provided for @limitationItem3.
  ///
  /// In en, this message translates to:
  /// **'Service without interruption or error-free'**
  String get limitationItem3;

  /// No description provided for @limitationItem4.
  ///
  /// In en, this message translates to:
  /// **'Compatibility with all devices and browsers'**
  String get limitationItem4;

  /// No description provided for @section4ProhibitedTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Prohibited Activities'**
  String get section4ProhibitedTitle;

  /// No description provided for @prohibitedIntro.
  ///
  /// In en, this message translates to:
  /// **'You are PROHIBITED from:'**
  String get prohibitedIntro;

  /// No description provided for @prohibitedItem1.
  ///
  /// In en, this message translates to:
  /// **'Using the app for illegal purposes or violating others\' rights'**
  String get prohibitedItem1;

  /// No description provided for @prohibitedItem2.
  ///
  /// In en, this message translates to:
  /// **'Reverse engineering, decompiling, or duplicating the app'**
  String get prohibitedItem2;

  /// No description provided for @prohibitedItem3.
  ///
  /// In en, this message translates to:
  /// **'Using bots, scrapers, or automation without written permission'**
  String get prohibitedItem3;

  /// No description provided for @prohibitedItem4.
  ///
  /// In en, this message translates to:
  /// **'Uploading malware, viruses, or harmful content'**
  String get prohibitedItem4;

  /// No description provided for @prohibitedItem5.
  ///
  /// In en, this message translates to:
  /// **'Misusing other users\' data or violating privacy'**
  String get prohibitedItem5;

  /// No description provided for @prohibitedItem6.
  ///
  /// In en, this message translates to:
  /// **'Creating fake accounts or impersonating others/entities'**
  String get prohibitedItem6;

  /// No description provided for @prohibitedItem7.
  ///
  /// In en, this message translates to:
  /// **'Using the app for commercial tracking without license'**
  String get prohibitedItem7;

  /// No description provided for @section5GpsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'5. GPS & Location Data'**
  String get section5GpsLocationTitle;

  /// No description provided for @gpsItem1.
  ///
  /// In en, this message translates to:
  /// **'GPS tracking is only active when you manually start a trip'**
  String get gpsItem1;

  /// No description provided for @gpsItem2.
  ///
  /// In en, this message translates to:
  /// **'Location data is stored locally on your device'**
  String get gpsItem2;

  /// No description provided for @gpsItem3.
  ///
  /// In en, this message translates to:
  /// **'You can delete location history anytime'**
  String get gpsItem3;

  /// No description provided for @gpsItem4.
  ///
  /// In en, this message translates to:
  /// **'We don\'t track your location in background without permission'**
  String get gpsItem4;

  /// No description provided for @gpsItem5.
  ///
  /// In en, this message translates to:
  /// **'Use GPS responsibly and comply with local laws'**
  String get gpsItem5;

  /// No description provided for @section6IntellectualPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Intellectual Property Rights'**
  String get section6IntellectualPropertyTitle;

  /// No description provided for @intellectualPropertyDesc1.
  ///
  /// In en, this message translates to:
  /// **'All content, features, and functionality of the MotoTracker app (including but not limited to text, graphics, logos, icons, and source code) are our exclusive property and protected by international copyright.'**
  String get intellectualPropertyDesc1;

  /// No description provided for @intellectualPropertyDesc2.
  ///
  /// In en, this message translates to:
  /// **'Your data belongs to you. We don\'t claim ownership of vehicle or trip information you input.'**
  String get intellectualPropertyDesc2;

  /// No description provided for @section7LiabilityLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Limitation of Liability'**
  String get section7LiabilityLimitTitle;

  /// No description provided for @liabilityIntro.
  ///
  /// In en, this message translates to:
  /// **'MotoTracker is not responsible for:'**
  String get liabilityIntro;

  /// No description provided for @liabilityItem1.
  ///
  /// In en, this message translates to:
  /// **'Vehicle damage due to maintenance negligence (our recommendations are guidance)'**
  String get liabilityItem1;

  /// No description provided for @liabilityItem2.
  ///
  /// In en, this message translates to:
  /// **'Data loss due to deleting browser cache or uninstalling'**
  String get liabilityItem2;

  /// No description provided for @liabilityItem3.
  ///
  /// In en, this message translates to:
  /// **'Financial losses or indirect damages from app usage'**
  String get liabilityItem3;

  /// No description provided for @liabilityItem4.
  ///
  /// In en, this message translates to:
  /// **'Incorrect workshop information listed'**
  String get liabilityItem4;

  /// No description provided for @liabilityItem5.
  ///
  /// In en, this message translates to:
  /// **'Service disruptions due to force majeure (natural disasters, war, etc.)'**
  String get liabilityItem5;

  /// No description provided for @section8SuspensionTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Suspension & Termination'**
  String get section8SuspensionTitle;

  /// No description provided for @suspensionIntro.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate your access if:'**
  String get suspensionIntro;

  /// No description provided for @suspensionItem1.
  ///
  /// In en, this message translates to:
  /// **'You violate these terms and conditions'**
  String get suspensionItem1;

  /// No description provided for @suspensionItem2.
  ///
  /// In en, this message translates to:
  /// **'We suspect fraud or abuse activity'**
  String get suspensionItem2;

  /// No description provided for @suspensionItem3.
  ///
  /// In en, this message translates to:
  /// **'Required by law or government authorities'**
  String get suspensionItem3;

  /// No description provided for @suspensionItem4.
  ///
  /// In en, this message translates to:
  /// **'You\'re inactive for more than 2 years (with notice)'**
  String get suspensionItem4;

  /// No description provided for @section9ChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to Terms'**
  String get section9ChangesTitle;

  /// No description provided for @changesDesc.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms and conditions at any time. Significant changes will be notified through:\n\n• In-app notifications\n• Email to registered address\n• Announcements on this page\n\nUsing the app after changes is considered your agreement.'**
  String get changesDesc;

  /// No description provided for @legalQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'📧 Legal Questions'**
  String get legalQuestionsTitle;

  /// No description provided for @legalContactIntro.
  ///
  /// In en, this message translates to:
  /// **'For questions regarding terms and conditions, contact:'**
  String get legalContactIntro;

  /// No description provided for @legalEmail.
  ///
  /// In en, this message translates to:
  /// **'legal@mototracker.id'**
  String get legalEmail;

  /// No description provided for @termsFooter1.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MotoTracker. All Rights Reserved.'**
  String get termsFooter1;

  /// No description provided for @termsFooter2.
  ///
  /// In en, this message translates to:
  /// **'By using this app, you agree to the applicable terms and conditions.'**
  String get termsFooter2;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
