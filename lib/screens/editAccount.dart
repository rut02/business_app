import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';


class EditAccountScreen extends StatefulWidget {
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _subdistrictController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
    if (userId != null) {
      final user = await UserService().getUserByid(userId);
      
      setState(() {
        _firstnameController.text = user.firstname ;
        _lastnameController.text = user.lastname;
        _genderController.text = user.gender ;
        _birthdateController.text = user.birthdate ;
        _phoneController.text = user.phone ;

     
        final addressParts = user.address.split(',');
        _countryController.text = addressParts.length > 0 ? addressParts[0] : '';
        _provinceController.text = addressParts.length > 1 ? addressParts[1] : '';
        _districtController.text = addressParts.length > 2 ? addressParts[2] : '';
        _subdistrictController.text = addressParts.length > 3 ? addressParts[3] : '';
      
    
        // _countryController.text = user.country ?? '';
        // _districtController.text = user.district ?? '';
        // _provinceController.text = user.province ?? '';
        // _subdistrictController.text = user.subdistrict ?? '';
        _positionController.text = user.position;
       
          _selectedDate = DateFormat('yyyy-MM-dd').parse(user.birthdate);
          _birthdateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        
    });
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
      if (userId != null) {
        await UserService().updateUser(
          uid: userId,
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          gender: _genderController.text,
          birthdate: _selectedDate,
          phone: _phoneController.text,
          country: _countryController.text,
          district: _districtController.text,
          province: _provinceController.text,
          subdistrict: _subdistrictController.text,
          position: _positionController.text,
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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
        title: Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(labelText: 'Birthdate'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your district';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _provinceController,
                decoration: InputDecoration(labelText: 'Province'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your province';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _subdistrictController,
                decoration: InputDecoration(labelText: 'Subdistrict'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your subdistrict';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your position';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
