import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/services/preferences_service.dart';
import '../../activity/providers/activity_feed_provider.dart';
import '../models/cohort.dart';
import '../models/student.dart';

final academyProvider = StateNotifierProvider<AcademyController, AcademyState>(
  (ref) => AcademyController(
    ref.watch(preferencesServiceProvider),
    ref.read(activityFeedProvider.notifier),
  ),
);

enum StudentFilter { all, studioDeployed, certified, placed }

class EnrollmentApplication {
  const EnrollmentApplication({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.college,
    required this.cityTier,
    required this.paymentType,
    required this.linkedIn,
    required this.submittedAt,
  });

  final String fullName;
  final String email;
  final String phone;
  final String college;
  final String cityTier;
  final String paymentType;
  final String linkedIn;
  final DateTime submittedAt;
}

class EnrollmentFormState {
  const EnrollmentFormState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.college = '',
    this.cityTier = 'Tier 2',
    this.paymentType = 'Upfront',
    this.linkedIn = '',
    this.isSubmitting = false,
  });

  final String fullName;
  final String email;
  final String phone;
  final String college;
  final String cityTier;
  final String paymentType;
  final String linkedIn;
  final bool isSubmitting;

  bool get isValid {
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    final phoneOk = RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
    final urlOk =
        linkedIn.isEmpty ||
        Uri.tryParse(linkedIn)?.hasAbsolutePath == true ||
        linkedIn.startsWith('https://');
    return fullName.trim().length >= 2 &&
        emailOk &&
        phoneOk &&
        college.trim().isNotEmpty &&
        urlOk;
  }

  EnrollmentFormState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? college,
    String? cityTier,
    String? paymentType,
    String? linkedIn,
    bool? isSubmitting,
  }) {
    return EnrollmentFormState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      college: college ?? this.college,
      cityTier: cityTier ?? this.cityTier,
      paymentType: paymentType ?? this.paymentType,
      linkedIn: linkedIn ?? this.linkedIn,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'college': college,
      'cityTier': cityTier,
      'paymentType': paymentType,
      'linkedIn': linkedIn,
    };
  }

  factory EnrollmentFormState.fromJson(Map<String, dynamic> json) {
    return EnrollmentFormState(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      college: json['college'] as String? ?? '',
      cityTier: json['cityTier'] as String? ?? 'Tier 2',
      paymentType: json['paymentType'] as String? ?? 'Upfront',
      linkedIn: json['linkedIn'] as String? ?? '',
    );
  }
}

class AcademyState {
  const AcademyState({
    required this.cohorts,
    required this.selectedCohortIndex,
    required this.activeTabIndex,
    required this.enrollmentForm,
    required this.pendingApplications,
    required this.sortColumn,
    required this.sortAscending,
    required this.studentFilter,
    required this.studentSearch,
  });

  final List<Cohort> cohorts;
  final int selectedCohortIndex;
  final int activeTabIndex;
  final EnrollmentFormState enrollmentForm;
  final List<EnrollmentApplication> pendingApplications;
  final int sortColumn;
  final bool sortAscending;
  final StudentFilter studentFilter;
  final String studentSearch;

  AcademyState copyWith({
    List<Cohort>? cohorts,
    int? selectedCohortIndex,
    int? activeTabIndex,
    EnrollmentFormState? enrollmentForm,
    List<EnrollmentApplication>? pendingApplications,
    int? sortColumn,
    bool? sortAscending,
    StudentFilter? studentFilter,
    String? studentSearch,
  }) {
    return AcademyState(
      cohorts: cohorts ?? this.cohorts,
      selectedCohortIndex: selectedCohortIndex ?? this.selectedCohortIndex,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      enrollmentForm: enrollmentForm ?? this.enrollmentForm,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      studentFilter: studentFilter ?? this.studentFilter,
      studentSearch: studentSearch ?? this.studentSearch,
    );
  }

  Cohort? cohortById(String id) {
    for (final cohort in cohorts) {
      if (cohort.id == id) {
        return cohort;
      }
    }
    return null;
  }

  Student? studentById(String cohortId, String studentId) {
    final cohort = cohortById(cohortId);
    if (cohort == null) {
      return null;
    }
    for (final student in cohort.students) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }
}

class AcademyController extends StateNotifier<AcademyState> {
  AcademyController(this._prefs, this._activity)
    : super(
        AcademyState(
          cohorts: MockData.cohorts(),
          selectedCohortIndex: 1,
          activeTabIndex: 0,
          enrollmentForm: _loadDraft(_prefs),
          pendingApplications: const [],
          sortColumn: _prefs.getAcademySortColumn(),
          sortAscending: _prefs.getAcademySortAscending(),
          studentFilter: StudentFilter.all,
          studentSearch: '',
        ),
      );

  final PreferencesService _prefs;
  final ActivityFeedController _activity;

  static EnrollmentFormState _loadDraft(PreferencesService prefs) {
    final raw = prefs.getAcademyDraftEnrollment();
    if (raw == null) {
      return const EnrollmentFormState();
    }
    try {
      return EnrollmentFormState.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const EnrollmentFormState();
    }
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  void sortCohorts(int column) {
    final ascending = state.sortColumn == column ? !state.sortAscending : true;
    final cohorts = [...state.cohorts];
    cohorts.sort((a, b) {
      final result = switch (column) {
        0 => a.name.compareTo(b.name),
        1 => a.studentsEnrolled.compareTo(b.studentsEnrolled),
        2 => a.capacity.compareTo(b.capacity),
        3 => a.status.name.compareTo(b.status.name),
        4 => a.grossMarginPercent.compareTo(b.grossMarginPercent),
        _ => a.name.compareTo(b.name),
      };
      return ascending ? result : -result;
    });
    state = state.copyWith(
      cohorts: cohorts,
      sortColumn: column,
      sortAscending: ascending,
    );
    unawaited(_prefs.setAcademySort(column, ascending));
  }

  void updateEnrollment({
    String? fullName,
    String? email,
    String? phone,
    String? college,
    String? cityTier,
    String? paymentType,
    String? linkedIn,
  }) {
    final form = state.enrollmentForm.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      college: college,
      cityTier: cityTier,
      paymentType: paymentType,
      linkedIn: linkedIn,
    );
    state = state.copyWith(enrollmentForm: form);
    unawaited(_prefs.setAcademyDraftEnrollment(jsonEncode(form.toJson())));
  }

  Future<void> submitEnrollment() async {
    if (!state.enrollmentForm.isValid || state.enrollmentForm.isSubmitting) {
      return;
    }
    state = state.copyWith(
      enrollmentForm: state.enrollmentForm.copyWith(isSubmitting: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final form = state.enrollmentForm;
    final application = EnrollmentApplication(
      fullName: form.fullName.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      college: form.college.trim(),
      cityTier: form.cityTier,
      paymentType: form.paymentType,
      linkedIn: form.linkedIn.trim(),
      submittedAt: DateTime.now(),
    );
    state = state.copyWith(
      pendingApplications: [application, ...state.pendingApplications],
      enrollmentForm: const EnrollmentFormState(),
    );
    _activity.add(
      icon: Icons.school_rounded,
      description: 'New enrollment: ${application.fullName}',
      route: '/academy',
    );
    unawaited(
      _prefs.setAcademyDraftEnrollment(
        jsonEncode(const EnrollmentFormState().toJson()),
      ),
    );
  }

  void markStudioReady(String cohortId, String studentId) {
    _updateStudent(
      cohortId,
      studentId,
      (student) => student.copyWith(studioDeployed: true),
    );
    final student = state.studentById(cohortId, studentId);
    _activity.add(
      icon: Icons.rocket_launch_rounded,
      description: '${student?.name ?? 'Builder'} marked Studio ready',
      route: '/academy/$cohortId/student/$studentId',
    );
  }

  void issueBadge(String cohortId, String studentId) {
    _updateStudent(
      cohortId,
      studentId,
      (student) => student.copyWith(certified: true),
    );
    final student = state.studentById(cohortId, studentId);
    _activity.add(
      icon: Icons.workspace_premium_rounded,
      description: 'Badge issued to ${student?.name ?? 'Academy builder'}',
      route: '/academy/$cohortId/student/$studentId',
    );
  }

  void markPlaced(String cohortId, String studentId) {
    _updateStudent(
      cohortId,
      studentId,
      (student) => student.copyWith(placed: true),
    );
    final student = state.studentById(cohortId, studentId);
    _activity.add(
      icon: Icons.handshake_rounded,
      description: '${student?.name ?? 'Academy builder'} marked placed',
      route: '/academy/$cohortId/student/$studentId',
    );
  }

  void _updateStudent(
    String cohortId,
    String studentId,
    Student Function(Student student) update,
  ) {
    state = state.copyWith(
      cohorts: [
        for (final cohort in state.cohorts)
          if (cohort.id == cohortId)
            Cohort(
              id: cohort.id,
              name: cohort.name,
              studentsEnrolled: cohort.studentsEnrolled,
              capacity: cohort.capacity,
              startDate: cohort.startDate,
              endDate: cohort.endDate,
              status: cohort.status,
              feeRange: cohort.feeRange,
              grossMarginPercent: cohort.grossMarginPercent,
              students: [
                for (final student in cohort.students)
                  if (student.id == studentId) update(student) else student,
              ],
            )
          else
            cohort,
      ],
    );
  }

  void setStudentFilter(StudentFilter filter) {
    state = state.copyWith(studentFilter: filter);
  }

  void setStudentSearch(String value) {
    state = state.copyWith(studentSearch: value);
  }

  List<Student> filteredStudents(String cohortId) {
    final cohort = state.cohortById(cohortId);
    if (cohort == null) {
      return const [];
    }
    final query = state.studentSearch.toLowerCase().trim();
    return cohort.students.where((student) {
      final matchesSearch =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.college.toLowerCase().contains(query);
      final matchesFilter = switch (state.studentFilter) {
        StudentFilter.all => true,
        StudentFilter.studioDeployed => student.studioDeployed,
        StudentFilter.certified => student.certified,
        StudentFilter.placed => student.placed,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
