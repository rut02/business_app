import 'package:app_card/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/services/users.dart';

class EditAccountScreen extends StatefulWidget {
  final User user;
  EditAccountScreen({required this.user});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  String? _gender;
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _subdistrictController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final user = widget.user;

    setState(() {
      _firstnameController.text = user.firstname;
      _lastnameController.text = user.lastname;
      _gender = user.gender;
      _birthdateController.text = user.birthdate;
      _phoneController.text = user.phone;

      final addressParts = user.address.split(',');
      _countryController.text = addressParts.length > 0 ? addressParts[0] : '';
      _provinceController.text = addressParts.length > 1 ? addressParts[1] : '';
      _districtController.text = addressParts.length > 2 ? addressParts[2] : '';
      _subdistrictController.text =
          addressParts.length > 3 ? addressParts[3] : '';

      _positionController.text = user.position;

      _selectedDate = DateFormat('yyyy-MM-dd').parse(user.birthdate);
      _birthdateController.text =
          DateFormat('yyyy-MM-dd').format(_selectedDate);

      isLoading = false;
    });
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final userId =
          Provider.of<LoginProvider>(context, listen: false).login?.id;
      if (userId != null) {
        await UserService().updateUser(
          uid: userId,
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          gender: _gender ?? '',
          birthdate: _selectedDate,
          phone: _phoneController.text,
          country: _countryController.text,
          district: _districtController.text,
          province: _provinceController.text,
          subdistrict: _subdistrictController.text,
          position: _positionController.text,
        );

        setState(() {
          isLoading = false;
        });

        Navigator.pop(context, true); // Return true to indicate data update
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Ensure the selected date is not in the future
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขบัญชี'),
        leading: isLoading
            ? Container() // Disable back button when loading
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(17.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: 20), // เพิ่มระยะห่างจาก AppBar
                    TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อ',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดกรอกชื่อของคุณ';
                        }
                        if (value.contains(RegExp(r'[0-9]'))) {
                          return 'ชื่อไม่ควรมีตัวเลข';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: 'นามสกุล',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดกรอกนามสกุลของคุณ';
                        }
                        if (value.contains(RegExp(r'[0-9]'))) {
                          return 'นามสกุลไม่ควรมีตัวเลข';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'เพศ',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      items: ['ชาย', 'หญิง', 'อื่นๆ']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดเลือกเพศของคุณ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdateController,
                      decoration: InputDecoration(
                        labelText: 'วันเกิด',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดเลือกวันเกิดของคุณ';
                        }
                        final selectedDate =
                            DateFormat('yyyy-MM-dd').parse(value);
                        if (selectedDate.isAfter(DateTime.now())) {
                          return 'วันเกิดไม่สามารถเป็นอนาคตได้';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'โทรศัพท์',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดกรอกหมายเลขโทรศัพท์ของคุณ';
                        }
                        if (value.length != 10 ||
                            !value.contains(RegExp(r'^[0-9]+$'))) {
                          return 'หมายเลขโทรศัพท์ต้องมี 10 หลัก';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'ประเทศ',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _provinceController,
                      decoration: InputDecoration(
                        labelText: 'จังหวัด',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText: 'อำเภอ',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _subdistrictController,
                      decoration: InputDecoration(
                        labelText: 'ตำบล',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        labelText: 'ตำแหน่ง',
                        labelStyle: TextStyle(
                          fontSize: 16, // Adjust the font size here
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _updateUser,
                      child: Text('อัปเดตข้อมูล'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
