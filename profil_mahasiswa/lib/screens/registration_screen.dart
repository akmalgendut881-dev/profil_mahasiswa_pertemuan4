import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController(); // Latihan 1
  final _dobController = TextEditingController(); // Latihan 2

  // State Variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedGender; // Latihan 3
  bool _agreeToTerms = false; // Latihan 4
  bool _termsError = false;

  // State Kekuatan Password (Latihan 5)
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // --- VALIDASI ---
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  // Latihan 1: Validasi No Telepon
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Nomor telepon tidak boleh kosong';
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()))
      return 'Hanya boleh berisi angka';
    if (value.trim().length < 10 || value.trim().length > 13)
      return 'Nomor telepon harus 10-13 digit';
    return null;
  }

  // Latihan 2: Date Picker Tanggal Lahir
  Future<void> _selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!value.contains(RegExp(r'[A-Z]')))
      return 'Password harus mengandung huruf kapital';
    if (!value.contains(RegExp(r'[0-9]')))
      return 'Password harus mengandung angka';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return 'Konfirmasi password tidak boleh kosong';
    if (value != _passwordController.text) return 'Password tidak cocok';
    return null;
  }

  // Latihan 5: Logika Kekuatan Password
  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthLabel = '';
      });
      return;
    }

    bool hasMinLength = value.length >= 8;
    bool hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
    bool hasUpper = value.contains(RegExp(r'[A-Z]'));
    bool hasLower = value.contains(RegExp(r'[a-z]'));
    bool hasNumber = value.contains(RegExp(r'[0-9]'));
    bool hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasMinLength && hasUpper && hasLower && hasNumber && hasSymbol) {
      setState(() {
        _passwordStrength = 1.0;
        _passwordStrengthLabel = 'Kuat';
        _passwordStrengthColor = Colors.green;
      });
    } else if (hasMinLength && hasLetter && hasNumber) {
      setState(() {
        _passwordStrength = 0.6;
        _passwordStrengthLabel = 'Sedang';
        _passwordStrengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = 0.3;
        _passwordStrengthLabel = 'Lemah';
        _passwordStrengthColor = Colors.red;
      });
    }
  }

  // Submit Handler
  void _submitForm() {
    bool isFormValid = _formKey.currentState!.validate();

    // Validasi Checkbox Syarat & Ketentuan (Latihan 4)
    setState(() {
      _termsError = !_agreeToTerms;
    });

    if (isFormValid && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registrasi Berhasil'),
            content: Text(
              'Selamat, ${_nameController.text}!\n'
              'Email: ${_emailController.text}\n'
              'No Telp: ${_phoneController.text}\n'
              'Gender: $_selectedGender\n'
              'Tgl Lahir: ${_dobController.text}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dobController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedGender = null;
      _agreeToTerms = false;
      _termsError = false;
      _passwordStrength = 0.0;
      _passwordStrengthLabel = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Field Nama Lengkap
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),

                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                // Latihan 1: Field Nomor Telepon
                CustomTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hint: 'Contoh: 081234567890',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),

                // Latihan 2: Field Tanggal Lahir
                CustomTextField(
                  controller: _dobController,
                  label: 'Tanggal Lahir',
                  hint: 'Pilih tanggal lahir',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _selectDateOfBirth,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Tanggal lahir wajib diisi'
                      : null,
                ),

                // Latihan 3: Dropdown Jenis Kelamin
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.people),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Jenis kelamin wajib dipilih' : null,
                  ),
                ),

                // Field Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onChanged: _checkPasswordStrength, // Latihan 5
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 8 karakter, huruf kapital, angka',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // Latihan 5: Indikator Kekuatan Password
                if (_passwordStrengthLabel.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey[300],
                          color: _passwordStrengthColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Kekuatan: $_passwordStrengthLabel',
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // Latihan 4: Checkbox Syarat & Ketentuan
                CheckboxListTile(
                  title: const Text('Saya menyetujui Syarat & Ketentuan'),
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                      if (_agreeToTerms) _termsError = false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_termsError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text(
                      'Anda harus menyetujui syarat & ketentuan',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 24),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),

                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
