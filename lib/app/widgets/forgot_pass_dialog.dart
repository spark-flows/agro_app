import 'package:flutter/material.dart';

bool isValidEmail(String email) {
  final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return regex.hasMatch(email);
}

void showEmailDialog(
  BuildContext context, {
  required Future<void> Function(String email) onSubmit,
  String title = 'Enter Your Email',
  String subtitle = "We'll use this to keep you updated",
  String buttonText = 'Add Email',
  String hintText = 'raj.kalsariya1994@gmail.com',
}) {
  showDialog(
    context: context,
    builder: (context) => _SimpleEmailDialog(
      onSubmit: onSubmit,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      hintText: hintText,
    ),
  );
}

class _SimpleEmailDialog extends StatefulWidget {
  final Future<void> Function(String email) onSubmit;
  final String title;
  final String subtitle;
  final String buttonText;
  final String hintText;

  const _SimpleEmailDialog({
    required this.onSubmit,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.hintText,
  });

  @override
  State<_SimpleEmailDialog> createState() => _SimpleEmailDialogState();
}

class _SimpleEmailDialogState extends State<_SimpleEmailDialog> {
  final _emailController = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() => _error = 'Please enter an email address');
      return;
    }

    if (!isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }

    // Show loading
    setState(() => _loading = true);

    try {
      // Call API
      await widget.onSubmit(email);

      // Show success
      setState(() => _success = true);

      // Close dialog
      Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.mail_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            Divider(height: 1),

            // Form
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email label
                  Text(
                    'Email Address',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),

                  // Email input
                  TextField(
                    controller: _emailController,
                    enabled: !_loading && !_success,
                    onChanged: (_) {
                      if (_error.isNotEmpty) {
                        setState(() => _error = '');
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error.isNotEmpty
                              ? Colors.red.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error.isNotEmpty
                              ? Colors.red.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error.isNotEmpty
                              ? Colors.red.shade500
                              : Colors.blue.shade500,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: _error.isNotEmpty
                          ? Colors.red.shade50
                          : _success
                          ? Colors.green.shade50
                          : Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _success
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green.shade600,
                              ),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Error message
                  if (_error.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Success message
                  if (_success)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Email added successfully!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: (_loading || _success) ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _loading
                            ? Colors.grey.shade400
                            : _success
                            ? Colors.green.shade600
                            : Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Submitting...'),
                              ],
                            )
                          : _success
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 18),
                                SizedBox(width: 8),
                                Text('Success!'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mail_outline, size: 18),
                                SizedBox(width: 8),
                                Text(widget.buttonText),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'We respect your privacy. Your email is safe with us.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
