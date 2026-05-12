import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCity;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final RegExp _nameRegex = RegExp(r'^[a-zA-Z ]+$');

  final RegExp _gmailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

  final List<String> _cities = [
    'Agra',
    'Ahmedabad',
    'Bengaluru',
    'Bhopal',
    'Chandigarh',
    'Chennai',
    'Delhi',
    'Faridabad',
    'Ghaziabad',
    'Gurugram',
    'Hyderabad',
    'Indore',
    'Jaipur',
    'Kanpur',
    'Kolkata',
    'Lucknow',
    'Meerut',
    'Mumbai',
    'Noida',
    'Patna',
    'Pune',
    'Surat',
    'Varanasi',
    'Vrindavan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup Successful'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      counterText: '',
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.72),
        fontSize: 15.sp,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 14.w, right: 12.w),
        child: Icon(
          icon,
          color: AppColors.goldLight,
          size: 24.sp,
        ),
      ),
      prefixIconConstraints: BoxConstraints(
        minWidth: 58.w,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 18.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.28),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(
          color: AppColors.goldLight,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [

          /// Background
          Positioned.fill(
            child: Image.asset(
              SignupScreen._bgImage,
              fit: BoxFit.cover,
            ),
          ),

          /// Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.68),
            ),
          ),

          /// Main UI
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 24.h,
              ),

              child: Column(
                children: [

                  /// Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _goToLogin,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  /// Title
                  Text(
                    'CREATE ACCOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 18.sp,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    'श्री चित्रगुप्त पीठ वृंदावन',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.saffron,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 34.h),

                  /// Signup Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 28.h,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.60),
                      ),
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        children: [

                          /// Name
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,

                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'),
                              ),
                            ],

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter full name';
                              }

                              if (!_nameRegex.hasMatch(
                                value.trim(),
                              )) {
                                return 'Only alphabets allowed';
                              }

                              return null;
                            },

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            cursorColor: AppColors.goldLight,

                            decoration: _inputDecoration(
                              hintText: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                          ),

                          SizedBox(height: 14.h),

                          /// Mobile
                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter mobile number';
                              }

                              if (value.trim().length != 10) {
                                return 'Mobile number must be 10 digits';
                              }

                              return null;
                            },

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            cursorColor: AppColors.goldLight,

                            decoration: _inputDecoration(
                              hintText: 'Mobile Number',
                              icon: Icons.phone_outlined,
                            ),
                          ),

                          SizedBox(height: 14.h),

                          /// Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType.emailAddress,

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return '@gmail is required';
                              }

                              if (!value.trim()
                                  .contains('@gmail.com')) {
                                return '@gmail is required';
                              }

                              if (!_gmailRegex.hasMatch(
                                value.trim(),
                              )) {
                                return 'Enter valid Gmail address';
                              }

                              return null;
                            },

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            cursorColor: AppColors.goldLight,

                            decoration: _inputDecoration(
                              hintText: 'Email',
                              icon: Icons.email_outlined,
                            ),
                          ),

                          SizedBox(height: 14.h),

                          /// City
                          DropdownButtonFormField<String>(
                            value: _selectedCity,
                            dropdownColor: Colors.black87,
                            iconEnabledColor:
                                AppColors.goldLight,

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            decoration: _inputDecoration(
                              hintText: 'Select City',
                              icon:
                                  Icons.location_city_outlined,
                            ),

                            items: _cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),

                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please select city';
                              }

                              return null;
                            },
                          ),

                          SizedBox(height: 14.h),

                          /// Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please enter password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            cursorColor: AppColors.goldLight,

                            decoration: _inputDecoration(
                              hintText: 'Password',
                              icon: Icons.lock_outline,

                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hidePassword
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color: AppColors.goldLight,
                                ),

                                onPressed: () {
                                  setState(() {
                                    _hidePassword =
                                        !_hidePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 14.h),

                          /// Confirm Password
                          TextFormField(
                            controller:
                                _confirmPasswordController,
                            obscureText:
                                _hideConfirmPassword,

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please confirm password';
                              }

                              if (value !=
                                  _passwordController.text) {
                                return 'Password not same';
                              }

                              return null;
                            },

                            style: const TextStyle(
                              color: Colors.white,
                            ),

                            cursorColor: AppColors.goldLight,

                            decoration: _inputDecoration(
                              hintText: 'Confirm Password',
                              icon:
                                  Icons.lock_reset_outlined,

                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hideConfirmPassword
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color: AppColors.goldLight,
                                ),

                                onPressed: () {
                                  setState(() {
                                    _hideConfirmPassword =
                                        !_hideConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 26.h),

                          /// Signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,

                            child: ElevatedButton(
                              onPressed: _signUp,

                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.saffron,

                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14.r,
                                  ),
                                ),
                              ),

                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          /// Login Button
                          TextButton(
                            onPressed: _goToLogin,

                            child: Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.90),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
}