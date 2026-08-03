import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class PoojaBookingScreen extends StatefulWidget {
  const PoojaBookingScreen({super.key});

  @override
  State<PoojaBookingScreen> createState() => _PoojaBookingScreenState();
}

class _PoojaBookingScreenState extends State<PoojaBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContentService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _message = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();

  List<PoojaItem> _poojas = [];
  String? _selectedPooja;
  bool _loadingPoojas = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPoojas();
  }

  Future<void> _loadPoojas() async {
    try {
      final list = await _service.fetchPoojas();
      if (!mounted) return;
      setState(() {
        _poojas = list;
        _loadingPoojas = false;
        if (list.isNotEmpty) _selectedPooja = list.first.title;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPoojas = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    _message.dispose();
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _date.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _time.text = picked.format(context);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPooja == null || _selectedPooja!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pooja')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final msg = await _service.submitPoojaBooking(
        name: _name.text.trim(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        pooja: _selectedPooja!,
        bookingDate: _date.text.trim(),
        bookingTime: _time.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _name.clear();
      _email.clear();
      _mobile.clear();
      _message.clear();
      _date.clear();
      _time.clear();
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
            title: 'Pooja Booking',
            subtitle: 'Book a sacred pooja',
            icon: Icons.upload_rounded,
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
                  if (_loadingPoojas)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: AppColors.goldLight,
                      ),
                    )
                  else if (_poojas.isEmpty)
                    const EmptyStateCard(
                      message: 'No poojas available from admin yet.',
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPooja,
                        dropdownColor: const Color(0xFF1A0A00),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Select Pooja *'),
                        items: _poojas
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.title,
                                child: Text(p.title),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPooja = v),
                      ),
                    ),
                  _field(_name, 'Name *', validator: _required),
                  _field(_email, 'Email *',
                      keyboard: TextInputType.emailAddress,
                      validator: _emailValidator),
                  _field(_mobile, 'Mobile (10 digits) *',
                      keyboard: TextInputType.phone,
                      validator: _mobileValidator),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: _field(_date, 'Booking Date *',
                          validator: _required),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickTime,
                    child: AbsorbPointer(
                      child: _field(_time, 'Preferred Time'),
                    ),
                  ),
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
                              'Submit Booking',
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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.white24),
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
        decoration: _decoration(label),
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
