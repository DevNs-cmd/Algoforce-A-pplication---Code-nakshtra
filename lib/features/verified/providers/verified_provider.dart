import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/services/preferences_service.dart';
import '../../activity/providers/activity_feed_provider.dart';
import '../models/certified_founder.dart';
import '../models/founder_application.dart';

final verifiedProvider =
    StateNotifierProvider<VerifiedController, VerifiedState>(
      (ref) => VerifiedController(
        ref.watch(preferencesServiceProvider),
        ref.read(activityFeedProvider.notifier),
      ),
    );

class VerifiedApplicationFormState {
  const VerifiedApplicationFormState({
    this.currentStep = 0,
    this.legalName = '',
    this.registrationNumber = '',
    this.companyType = 'Pvt Ltd',
    this.address = '',
    this.certificateFile = '',
    this.productDescription = '',
    this.marketSize = '',
    this.revenueModel = 'SaaS',
    this.currentRevenue = '',
    this.customerCount = '',
    this.certificationReason = '',
    this.acceptedTerms = false,
    this.paymentMethod = 'UPI',
    this.upiId = '',
    this.isSubmitting = false,
  });

  final int currentStep;
  final String legalName;
  final String registrationNumber;
  final String companyType;
  final String address;
  final String certificateFile;
  final String productDescription;
  final String marketSize;
  final String revenueModel;
  final String currentRevenue;
  final String customerCount;
  final String certificationReason;
  final bool acceptedTerms;
  final String paymentMethod;
  final String upiId;
  final bool isSubmitting;

  VerifiedApplicationFormState copyWith({
    int? currentStep,
    String? legalName,
    String? registrationNumber,
    String? companyType,
    String? address,
    String? certificateFile,
    String? productDescription,
    String? marketSize,
    String? revenueModel,
    String? currentRevenue,
    String? customerCount,
    String? certificationReason,
    bool? acceptedTerms,
    String? paymentMethod,
    String? upiId,
    bool? isSubmitting,
  }) {
    return VerifiedApplicationFormState(
      currentStep: currentStep ?? this.currentStep,
      legalName: legalName ?? this.legalName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      companyType: companyType ?? this.companyType,
      address: address ?? this.address,
      certificateFile: certificateFile ?? this.certificateFile,
      productDescription: productDescription ?? this.productDescription,
      marketSize: marketSize ?? this.marketSize,
      revenueModel: revenueModel ?? this.revenueModel,
      currentRevenue: currentRevenue ?? this.currentRevenue,
      customerCount: customerCount ?? this.customerCount,
      certificationReason: certificationReason ?? this.certificationReason,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      upiId: upiId ?? this.upiId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'legalName': legalName,
      'registrationNumber': registrationNumber,
      'companyType': companyType,
      'address': address,
      'certificateFile': certificateFile,
      'productDescription': productDescription,
      'marketSize': marketSize,
      'revenueModel': revenueModel,
      'currentRevenue': currentRevenue,
      'customerCount': customerCount,
      'certificationReason': certificationReason,
      'acceptedTerms': acceptedTerms,
      'paymentMethod': paymentMethod,
      'upiId': upiId,
    };
  }

  factory VerifiedApplicationFormState.fromJson(Map<String, dynamic> json) {
    return VerifiedApplicationFormState(
      currentStep: json['currentStep'] as int? ?? 0,
      legalName: json['legalName'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      companyType: json['companyType'] as String? ?? 'Pvt Ltd',
      address: json['address'] as String? ?? '',
      certificateFile: json['certificateFile'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      marketSize: json['marketSize'] as String? ?? '',
      revenueModel: json['revenueModel'] as String? ?? 'SaaS',
      currentRevenue: json['currentRevenue'] as String? ?? '',
      customerCount: json['customerCount'] as String? ?? '',
      certificationReason: json['certificationReason'] as String? ?? '',
      acceptedTerms: json['acceptedTerms'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      upiId: json['upiId'] as String? ?? '',
    );
  }
}

class VerifiedState {
  const VerifiedState({
    required this.certifiedFounders,
    required this.pendingApplications,
    required this.selectedFounderIndex,
    required this.applicationForm,
  });

  final List<CertifiedFounder> certifiedFounders;
  final List<FounderApplication> pendingApplications;
  final int selectedFounderIndex;
  final VerifiedApplicationFormState applicationForm;

  VerifiedState copyWith({
    List<CertifiedFounder>? certifiedFounders,
    List<FounderApplication>? pendingApplications,
    int? selectedFounderIndex,
    VerifiedApplicationFormState? applicationForm,
  }) {
    return VerifiedState(
      certifiedFounders: certifiedFounders ?? this.certifiedFounders,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      selectedFounderIndex: selectedFounderIndex ?? this.selectedFounderIndex,
      applicationForm: applicationForm ?? this.applicationForm,
    );
  }

  CertifiedFounder? founderById(String id) {
    for (final founder in certifiedFounders) {
      if (founder.id == id) {
        return founder;
      }
    }
    return null;
  }
}

class VerifiedController extends StateNotifier<VerifiedState> {
  VerifiedController(this._prefs, this._activity)
    : super(
        VerifiedState(
          certifiedFounders: MockData.certifiedFounders(),
          pendingApplications: MockData.founderApplications(),
          selectedFounderIndex: 0,
          applicationForm: _loadDraft(_prefs),
        ),
      );

  final PreferencesService _prefs;
  final ActivityFeedController _activity;

  static VerifiedApplicationFormState _loadDraft(PreferencesService prefs) {
    final raw = prefs.getVerifiedApplicationDraft();
    if (raw == null) {
      return const VerifiedApplicationFormState();
    }
    try {
      return VerifiedApplicationFormState.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const VerifiedApplicationFormState();
    }
  }

  void selectFounder(int index) {
    state = state.copyWith(selectedFounderIndex: index);
  }

  void setStep(int step) {
    state = state.copyWith(
      applicationForm: state.applicationForm.copyWith(
        currentStep: step.clamp(0, 4).toInt(),
      ),
    );
    _persistDraft();
  }

  void updateForm({
    String? legalName,
    String? registrationNumber,
    String? companyType,
    String? address,
    String? certificateFile,
    String? productDescription,
    String? marketSize,
    String? revenueModel,
    String? currentRevenue,
    String? customerCount,
    String? certificationReason,
    bool? acceptedTerms,
    String? paymentMethod,
    String? upiId,
  }) {
    state = state.copyWith(
      applicationForm: state.applicationForm.copyWith(
        legalName: legalName,
        registrationNumber: registrationNumber,
        companyType: companyType,
        address: address,
        certificateFile: certificateFile,
        productDescription: productDescription,
        marketSize: marketSize,
        revenueModel: revenueModel,
        currentRevenue: currentRevenue,
        customerCount: customerCount,
        certificationReason: certificationReason,
        acceptedTerms: acceptedTerms,
        paymentMethod: paymentMethod,
        upiId: upiId,
      ),
    );
    _persistDraft();
  }

  Future<void> submitApplication() async {
    state = state.copyWith(
      applicationForm: state.applicationForm.copyWith(isSubmitting: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    final form = state.applicationForm;
    final app = FounderApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      founderName: form.legalName.isEmpty
          ? 'New Verified Founder'
          : form.legalName,
      startupName: form.registrationNumber.isEmpty
          ? 'Certification Candidate'
          : 'Company ${form.registrationNumber}',
      submittedDate: DateTime.now(),
      currentLayer: 1,
      layerStatuses: const [
        'pending',
        'pending',
        'pending',
        'pending',
        'pending',
      ],
      totalFeesPaid: 5000,
    );
    state = state.copyWith(
      pendingApplications: [app, ...state.pendingApplications],
      applicationForm: const VerifiedApplicationFormState(),
    );
    _activity.add(
      icon: Icons.verified_user_rounded,
      description: 'Verified application submitted: ${app.founderName}',
      route: '/verified',
    );
    unawaited(
      _prefs.setVerifiedApplicationDraft(
        jsonEncode(const VerifiedApplicationFormState().toJson()),
      ),
    );
  }

  void advanceApplicationLayer(String applicationId) {
    state = state.copyWith(
      pendingApplications: [
        for (final app in state.pendingApplications)
          if (app.id == applicationId)
            FounderApplication(
              id: app.id,
              founderName: app.founderName,
              startupName: app.startupName,
              submittedDate: app.submittedDate,
              currentLayer: (app.currentLayer + 1).clamp(1, 5).toInt(),
              layerStatuses: [
                for (var i = 0; i < app.layerStatuses.length; i++)
                  i < app.currentLayer ? 'passed' : app.layerStatuses[i],
              ],
              totalFeesPaid: app.totalFeesPaid,
            )
          else
            app,
      ],
    );
    FounderApplication? app;
    for (final item in state.pendingApplications) {
      if (item.id == applicationId) {
        app = item;
        break;
      }
    }
    _activity.add(
      icon: Icons.timeline_rounded,
      description:
          '${app?.startupName ?? 'Verified application'} advanced to layer ${app?.currentLayer ?? ''}',
      route: '/verified',
    );
  }

  void sendRenewalReminder(String founderId) {
    final founder = state.founderById(founderId);
    _activity.add(
      icon: Icons.notification_important_rounded,
      description:
          'Renewal reminder sent to ${founder?.founderName ?? 'certified founder'}',
      route: '/verified/$founderId',
    );
  }

  void logInvestorIntro(String founderName, String investorName) {
    _activity.add(
      icon: Icons.handshake_rounded,
      description: 'Investor intro requested: $investorName to $founderName',
      route: '/verified/investors',
    );
  }

  void _persistDraft() {
    unawaited(
      _prefs.setVerifiedApplicationDraft(
        jsonEncode(state.applicationForm.toJson()),
      ),
    );
  }
}
