import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/auth_provider.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _seconds = ValueNotifier<int>(30);
  final _hasError = ValueNotifier<bool>(false);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(authProvider.notifier).sendOtp(widget.phone));
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _seconds.dispose();
    _hasError.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds.value = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds.value <= 1) {
        _seconds.value = 0;
        timer.cancel();
      } else {
        _seconds.value -= 1;
      }
    });
  }

  Future<void> _verify(String value) async {
    final ok = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phone, value.trim());
    if (!mounted) {
      return;
    }
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    _hasError.value = true;
    _controller.clear();
    _focusNode.requestFocus();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (mounted) {
      _hasError.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: AppText.mono(size: 24, color: AppColors.navy),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border2),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxFormWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                  Text(
                    'Verify your number',
                    style: AppText.display(size: 28, color: AppColors.navy),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'We sent a code to +91 ${_masked(widget.phone)}',
                    style: AppText.body(size: 15, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppDimensions.space28),
                  ValueListenableBuilder<bool>(
                    valueListenable: _hasError,
                    builder: (context, hasError, child) {
                      final input = Pinput(
                        controller: _controller,
                        focusNode: _focusNode,
                        length: 4,
                        autofocus: true,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: AppColors.purple),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: AppColors.verified),
                          ),
                        ),
                        onCompleted: (value) => unawaited(_verify(value)),
                      );
                      return hasError
                          ? input.animate().shake(duration: 500.ms)
                          : input;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space18),
                  ValueListenableBuilder<int>(
                    valueListenable: _seconds,
                    builder: (context, seconds, child) {
                      if (seconds > 0) {
                        return Text(
                          'Resend OTP in ${seconds}s',
                          style: AppText.body(color: AppColors.textMuted),
                        );
                      }
                      return TextButton(
                        onPressed: () {
                          unawaited(
                            ref
                                .read(authProvider.notifier)
                                .sendOtp(widget.phone),
                          );
                          _startTimer();
                        },
                        child: const Text('Resend OTP'),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    'Demo code: 1234',
                    style: AppText.body(size: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _masked(String phone) {
    if (phone.length < 4) {
      return phone;
    }
    return '${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}';
  }
}
