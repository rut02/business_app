import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_card/services/users.dart';
import 'package:app_card/models/create.dart';
import 'package:app_card/models/profileImage.dart';
import 'package:intl/intl.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController subdistrictController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  String? selectedGender;
  File? _imageFile;
  bool _isSubmitting = false;
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลงทะเบียน'),
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: _currentStep == 0
                ? _buildPageOne(context)
                : _buildPageTwo(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPageOne(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(firstNameController, 'ชื่อ', Icons.person),
          SizedBox(height: 10),
          _buildTextField(lastNameController, 'นามสกุล', Icons.person),
          SizedBox(height: 10),
          _buildTextField(emailController, 'อีเมล', Icons.email,
              keyboardType: TextInputType.emailAddress, isEmail: true),
          SizedBox(height: 10),
          _buildPasswordField(passwordController, 'รหัสผ่าน'),
          SizedBox(height: 10),
          _buildDropdownField('เพศ', Icons.person, ['ชาย', 'หญิง'],
              (value) {
            setState(() {
              selectedGender = value;
            });
          }),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isSubmitting = true;
                });

                try {
                  // ตรวจสอบว่าอีเมลนี้ถูกใช้งานแล้วหรือไม่
                  bool isEmailRegistered = await UserService().checkEmail(emailController.text);
                  if (isEmailRegistered == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('อีเมลนี้ถูกใช้งานแล้ว'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {
                      _isSubmitting = false;
                    });
                    return;
                  }

                  setState(() {
                    _currentStep = 1;
                  });
                } catch (e) {
                  print('ข้อผิดพลาดในการตรวจสอบอีเมล: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ไม่สามารถตรวจสอบอีเมลได้ โปรดลองอีกครั้งในภายหลัง'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    _isSubmitting = false;
                  });
                }
              }
            },
            child: Text('ถัดไป'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTwo(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(phoneController, 'โทรศัพท์', Icons.phone,
              keyboardType: TextInputType.phone),
          SizedBox(height: 10),
          _buildTextField(
              subdistrictController, 'ตำบล', Icons.location_city),
          SizedBox(height: 10),
          _buildTextField(districtController, 'อำเภอ', Icons.location_city),
          SizedBox(height: 10),
          _buildTextField(provinceController, 'จังหวัด', Icons.location_city),
          SizedBox(height: 10),
          _buildTextField(countryController, 'ประเทศ', Icons.location_city),
          SizedBox(height: 10),
          _buildDateField(birthdateController, 'วันเกิด', Icons.cake),
          SizedBox(height: 10),
          _buildTextField(positionController, 'ตำแหน่ง', Icons.work),
          SizedBox(height: 20),
          _buildImagePicker(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isSubmitting ? null : () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
                child: Text('ย้อนกลับ'),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? CircularProgressIndicator()
                    : Text('ส่ง'),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildTextField(
    TextEditingController controller, String labelText, IconData icon,
    {TextInputType keyboardType = TextInputType.text,
    bool isEmail = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      labelText: labelText,
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
    ),
    keyboardType: keyboardType,
    enabled: !_isSubmitting,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'โปรดกรอก$labelText';
      }
      if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'โปรดกรอกอีเมลที่ถูกต้อง';
      }
      if (controller == phoneController &&
          !RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'โปรดกรอกเบอร์โทรศัพท์ที่ถูกต้อง';
      }
      if ((controller == firstNameController || controller == lastNameController) &&
          RegExp(r'\d').hasMatch(value)) {
        return 'โปรดอย่ากรอกตัวเลขใน$labelText';
      }
      return null;
    },
  );
}

  Widget _buildPasswordField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      enabled: !_isSubmitting,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'โปรดกรอก$labelText';
        }
        if (value.length < 6) {
          return '$labelTextต้องมีอย่างน้อย 6 ตัวอักษร';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String labelText, IconData icon,
      List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      onChanged: _isSubmitting ? null : onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'โปรดเลือก$labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      onTap: _isSubmitting
          ? null
          : () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
      enabled: !_isSubmitting,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'โปรดกรอก$labelText';
        }
        try {
          DateTime birthdate = DateTime.parse(value);
          if (birthdate.isAfter(DateTime.now())) {
            return 'วันเกิดไม่สามารถเป็นอนาคตได้';
          }
        } catch (_) {
          return 'รูปแบบวันที่ไม่ถูกต้อง';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.image, color: Theme.of(context).primaryColor),
          title: Text('เลือกรูปโปรไฟล์'),
          subtitle:
              Text(_imageFile == null ? 'ไม่มีรูปภาพที่เลือก' : 'รูปภาพถูกเลือก'),
          trailing: IconButton(
            icon:
                Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
            onPressed: _isSubmitting ? null : _pickImage,
          ),
        ),
        if (_imageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(_imageFile!),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      setState(() {
        _imageFile = null;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('โปรดอัพโหลดรูปโปรไฟล์'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        Create response = await UserService().createUser(
          email: emailController.text,
          password: passwordController.text,
          firstname: firstNameController.text,
          lastname: lastNameController.text,
          phone: phoneController.text,
          gender: selectedGender!,
          birthdate: DateTime.parse(birthdateController.text),
          district: districtController.text,
          subdistrict: subdistrictController.text,
          province: provinceController.text,
          country: countryController.text,
          position: positionController.text,
        );

        if (response.message == 'User created successfully') {
          print('สร้างผู้ใช้สำเร็จ');
          print(response.userId);

          if (_imageFile != null) {
            print('กำลังอัพโหลดรูปโปรไฟล์...');
            try {
              ProfileImage uploadResponse = await UserService().uploadProfileImage(
                response.userId,
                'profile',
                _imageFile!.path,
              );
              if (uploadResponse.message == 'Profile uploaded successfully') {
                print('อัพโหลดรูปโปรไฟล์สำเร็จ');
                await UserService().create_card(response.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลงทะเบียนสำเร็จ!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                print('ล้มเหลวในการอัพโหลดรูปโปรไฟล์. รหัสสถานะ: ${uploadResponse.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ล้มเหลวในการอัพโหลดรูปโปรไฟล์. รหัสสถานะ: ${uploadResponse.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              print('ข้อผิดพลาดในการอัพโหลดรูปโปรไฟล์: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ไม่สามารถอัพโหลดรูปโปรไฟล์ได้ โปรดลองอีกครั้งในภายหลัง'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ลงทะเบียนสำเร็จ!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          _clearFormFields();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          print('ล้มเหลวในการสร้างผู้ใช้. รหัสสถานะ: ${response.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ล้มเหลวในการสร้างผู้ใช้. รหัสสถานะ: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('ข้อผิดพลาดในการสร้างผู้ใช้: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ล้มเหลวในการลงทะเบียน โปรดลองอีกครั้งในภายหลัง'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearFormFields() {
    emailController.clear();
    passwordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    districtController.clear();
    subdistrictController.clear();
    provinceController.clear();
    countryController.clear();
    birthdateController.clear();
    positionController.clear();
    setState(() {
      selectedGender = null;
      _imageFile = null;
    });
  }
}