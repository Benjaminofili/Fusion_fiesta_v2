import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';

class MockPaymentScreen extends StatefulWidget {
  final double amount;
  final String itemName;

  const MockPaymentScreen({
    super.key,
    required this.amount,
    required this.itemName
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulate Network Delay for Payment Gateway
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Return "true" to indicate success
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Secure Payment', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Display
              Center(
                child: Column(
                  children: [
                    Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    Text(
                      '\$${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: Text(widget.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // Card Details
              Text('Card Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 16.h),

              TextFormField(
                decoration: _inputDeco('Card Number', Icons.credit_card),
                keyboardType: TextInputType.number,
                validator: (v) => (v?.length ?? 0) < 12 ? 'Invalid Card Number' : null,
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco('Expiry (MM/YY)', Icons.calendar_today),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco('CVV', Icons.lock_outline),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v?.length ?? 0) < 3 ? 'Invalid CVV' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                decoration: _inputDeco('Cardholder Name', Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              SizedBox(height: 40.h),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Pay \$${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Payments are secure and encrypted', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    );
  }
}