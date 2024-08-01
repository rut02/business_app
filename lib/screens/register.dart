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

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) => !_isSubmitting ? setState(() => _currentStep = step) : null,
                onStepContinue: _isSubmitting ? null : _currentStep < 2
                    ? () => setState(() => _currentStep += 1)
                    : _submitForm,
                onStepCancel: _isSubmitting ? null : _currentStep > 0
                    ? () => setState(() => _currentStep -= 1)
                    : null,
                steps: [
                  Step(
                    title: Text('Personal Information'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: Column(
                      children: [
                        _buildTextField(firstNameController, 'First Name', Icons.person),
                        SizedBox(height: 10),
                        _buildTextField(lastNameController, 'Last Name', Icons.person),
                        SizedBox(height: 10),
                        _buildTextField(emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 10),
                        _buildPasswordField(passwordController, 'Password'),
                        SizedBox(height: 10),
                        _buildDropdownField('Gender', Icons.person, ['Male', 'Female'], (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        }),
                      ],
                    ),
                  ),
                  Step(
                    title: Text('Contact Information'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: Column(
                      children: [
                        _buildTextField(phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
                        SizedBox(height: 10),
                        _buildTextField(subdistrictController, 'Subdistrict', Icons.location_city),
                        SizedBox(height: 10),
                        _buildTextField(districtController, 'District', Icons.location_city),
                        SizedBox(height: 10),
                        _buildTextField(provinceController, 'Province', Icons.location_city),
                        SizedBox(height: 10),
                        _buildTextField(countryController, 'Country', Icons.location_city),
                      ],
                    ),
                  ),
                  Step(
                    title: Text('Additional Information'),
                    isActive: _currentStep >= 2,
                    state: _currentStep == 2 ? StepState.indexed : StepState.complete,
                    content: Column(
                      children: [
                        _buildDateField(birthdateController, 'Birthdate', Icons.cake),
                        SizedBox(height: 10),
                        _buildTextField(positionController, 'Position', Icons.work),
                        SizedBox(height: 20),
                        _buildImagePicker(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        if (value.length < 6) {
          return '$labelText must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String labelText, IconData icon, List<String> items, void Function(String?) onChanged) {
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
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        try {
          DateTime.parse(value);
        } catch (_) {
          return 'Invalid date format';
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
          title: Text('Select Profile Image'),
          subtitle: Text(_imageFile == null ? 'No image selected' : 'Image selected'),
          trailing: IconButton(
            icon: Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
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
                  onPressed: _isSubmitting ? null : () {
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
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
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
          SnackBar(content: Text('กรุณาอัปโหลดรูปโปรไฟล์')),
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
          print('User created successfully');
          print(response.userId);

          if (_imageFile != null) {
            print('Uploading profile image...');
            try {
              ProfileImage uploadResponse = await UserService().uploadProfileImage(
                response.userId,
                'profile',
                _imageFile!.path,
              );
              if (uploadResponse.message == 'Profile uploaded successfully') {
                print('Profile image uploaded successfully');
                await UserService().create_card(response.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ลงทะเบียนสำเร็จ!')),
                );
              } else {
                print('Failed to upload profile image. Status code: ${uploadResponse.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ไม่สามารถอัปโหลดรูปโปรไฟล์ได้. Status code: ${uploadResponse.message}')),
                );
              }
            } catch (e) {
              print('Error uploading profile image: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ไม่สามารถอัปโหลดรูปโปรไฟล์ได้. กรุณาลองอีกครั้งในภายหลัง')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ลงทะเบียนสำเร็จ!')),
            );
          }

          _clearFormFields();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          print('Failed to create user. Status code: ${response.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create user. Status code: ${response.message}')),
          );
        }
      } catch (e) {
        print('Error creating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register. Please try again later.')),
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
