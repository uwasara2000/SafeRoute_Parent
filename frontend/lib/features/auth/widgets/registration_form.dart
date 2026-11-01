import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/validators/form_validators.dart';

/// Form widget containing all inputs and validation for Parent Registration
class RegistrationForm extends StatefulWidget {
  final bool isLoading;
  final Function({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) onSubmit;

  const RegistrationForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String? _termsErrorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleFormSubmit() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _termsErrorMessage = _agreedToTerms
          ? null
          : 'You must agree to the Terms and Privacy Policy';
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        return;
      }
      widget.onSubmit(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildFieldLabel('Full name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(hintText: 'Your full name'),
            validator: FormValidators.validateFullName,
          ),
          const SizedBox(height: 16),

          // Email Address Field
          _buildFieldLabel('Email address'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(hintText: 'name@example.com'),
            validator: FormValidators.validateEmail,
          ),
          const SizedBox(height: 16),

          // Mobile Number Field
          _buildFieldLabel('Mobile number'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(hintText: '+94 7X XXX XXXX'),
            validator: FormValidators.validatePhoneNumber,
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildFieldLabel('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'At least 8 characters',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: FormValidators.validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          _buildFieldLabel('Confirm password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              hintText: 'Re-enter password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) => FormValidators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 8),

          // Helper hint text under password fields
          const Text(
            'Use 8+ characters with a number and symbol.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // Terms and Privacy Policy Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _agreedToTerms,
                  activeColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: AppColors.borderSubtle,
                    width: 1.5,
                  ),
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                            if (_agreedToTerms) {
                              _termsErrorMessage = null;
                            }
                          });
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                            if (_agreedToTerms) {
                              _termsErrorMessage = null;
                            }
                          });
                        },
                  child: const Text(
                    'I agree to the Terms and Privacy Policy',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_termsErrorMessage != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                _termsErrorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Create Account Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleFormSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryTeal.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textHint,
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

