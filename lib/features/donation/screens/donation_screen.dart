import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContentService();

  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _amount = TextEditingController();
  final _message = TextEditingController();

  bool _submitting = false;

  final _presets = const [51, 101, 501, 1100, 2100];

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final msg = await _service.submitDonation(
        name: _name.text.trim(),
        mobile: _mobile.text.trim(),
        amount: num.parse(_amount.text.trim()),
        email: _email.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _name.clear();
      _mobile.clear();
      _email.clear();
      _amount.clear();
      _message.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
        children: [
          const SectionTitle(
            title: 'Donation',
            subtitle: 'Support the Peeth seva',
            icon: Icons.volunteer_activism_rounded,
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _presets
                .map(
                  (p) => ChoiceChip(
                    label: Text('₹$p'),
                    selected: _amount.text == '$p',
                    selectedColor: AppColors.saffron,
                    labelStyle: TextStyle(
                      color: _amount.text == '$p'
                          ? Colors.white
                          : Colors.white70,
                    ),
                    backgroundColor: Colors.white12,
                    onSelected: (_) =>
                        setState(() => _amount.text = '$p'),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.white24),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(_name, 'Name *', validator: _required),
                  _field(_mobile, 'Mobile (10 digits) *',
                      keyboard: TextInputType.phone,
                      validator: _mobileValidator),
                  _field(_email, 'Email',
                      keyboard: TextInputType.emailAddress),
                  _field(_amount, 'Amount (₹) *',
                      keyboard: TextInputType.number,
                      validator: _amountValidator),
                  _field(_message, 'Message', maxLines: 3),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Donate Now',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.white24),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _mobileValidator(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter 10-digit mobile';
    return null;
  }

  String? _amountValidator(String? v) {
    final n = num.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter a valid amount';
    return null;
  }
}
