import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContentService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _profession = TextEditingController();
  final _message = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    _city.dispose();
    _state.dispose();
    _profession.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final msg = await _service.submitMember(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        profession: _profession.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _formKey.currentState!.reset();
      _name.clear();
      _email.clear();
      _mobile.clear();
      _city.clear();
      _state.clear();
      _profession.clear();
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
            title: 'Member',
            subtitle: 'Join Shree Chitragupt Peeth',
            icon: Icons.person_add_alt_1_rounded,
          ),
          SizedBox(height: 18.h),
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
                  _field(_name, 'Full Name *', validator: _required),
                  _field(_email, 'Email *',
                      keyboard: TextInputType.emailAddress,
                      validator: _emailValidator),
                  _field(_mobile, 'Mobile (10 digits) *',
                      keyboard: TextInputType.phone,
                      validator: _mobileValidator),
                  _field(_city, 'City'),
                  _field(_state, 'State'),
                  _field(_profession, 'Profession'),
                  _field(_message, 'Message', maxLines: 3),
                  SizedBox(height: 16.h),
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
                              'Submit Membership',
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

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())) return 'Invalid email';
    return null;
  }

  String? _mobileValidator(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter 10-digit mobile';
    return null;
  }
}
