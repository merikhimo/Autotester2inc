import 'package:flutter/material.dart';
import '../widgets/appbars/appbar_with_text.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      //затычка
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("success!"),
          content: Text("Email: $email\n password: $password"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(100), child: AppbarWithText(text: "Home page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              LayoutBuilder(
  builder: (context, constraints) {
    double maxWidth = constraints.maxWidth > 500
        ? 500
        : constraints.maxWidth * 0.9;

    return Center(
      child: SizedBox(
        width: maxWidth,
        child: Column(
          children: [
            // Email
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: themeProvider.isDarkTheme
                    ? const Color(0xFF303030)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: TextFormField(
                controller: _emailController,
                style: const TextStyle(),
                cursorColor: const Color(0xFF0088FF),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    color: Color(0xFF898989),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                  hintText: "email",
                  border: InputBorder.none,
                ),
                validator: (value) {
                  RegExp exp = RegExp(r'^\S+@\S+\.\S+$');
                  if (!exp.hasMatch(value!)) {
                    return "email is invalid";
                  }
                  return null;
                }
              ),
            ),

            const SizedBox(height: 16),

            // Password
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: themeProvider.isDarkTheme
                    ? const Color(0xFF303030)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(),
                cursorColor: const Color(0xFF0088FF),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: const TextStyle(
                    color: Color(0xFF898989),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                  hintText: "password",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                   if (value == null || value.length < 8 ) {
                    return "password should contain 8 or more characters";
                  }
                  return null;
                }
              ),
            ),

            const SizedBox(height: 16),

            // Password repeat
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: themeProvider.isDarkTheme
                    ? const Color(0xFF303030)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                style: const TextStyle(),
                cursorColor: const Color(0xFF0088FF),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: const TextStyle(
                    color: Color(0xFF898989),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                  hintText: "repeat password",
                  border: InputBorder.none,
                ),
                validator: (value) {
                   if (value != _passwordController.text) {
                    return "passwords are different";
                  }
                  return null;
                }
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0088FF),
              ),
              child:
              Text("login",
                style: TextStyle(color: Color(0xFFF5F5F5))
              ),
            ),
          ],
        ),
      ),
    );
  },
),
            ],
          ),
        ),
      ),
    );
  }
}
