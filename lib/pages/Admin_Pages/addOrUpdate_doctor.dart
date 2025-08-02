import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/Widgets/normalTitle.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/pages/Doctor_Page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/pickImage_imgbb.dart';
import 'package:nubmed/utils/specialization_list.dart';
import '../../model/doctor_model.dart';

class AddOrUpdateNewDoctor extends StatefulWidget {
  const AddOrUpdateNewDoctor({super.key, this.doctor});
  static String name = 'add-new-doctor';

  final Doctor? doctor;

  @override
  State<AddOrUpdateNewDoctor> createState() => _AddOrUpdateNewDoctorState();
}

class _AddOrUpdateNewDoctorState extends State<AddOrUpdateNewDoctor> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? selectedPhoto;
  String? imageString;
  bool _loading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<String> selectedDays = [];
  String? visitingTime;
  DoctorSpecialization? selectedSpecialization;

  List<String> allDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _initializeWithDoctorData();
    }
  }

  void _initializeWithDoctorData() {
    final doctor = widget.doctor!;
    _nameController.text = doctor.name;
    _degreeController.text = doctor.degree;
    _designationController.text = doctor.designation;
    _hospitalController.text = doctor.hospital;
    _emailController.text = doctor.email;
    _phoneController.text = doctor.phone;
    selectedDays = List<String>.from(doctor.visitingDays);
    visitingTime = doctor.visitingTime;
    imageString = doctor.imageUrl;

    if (doctor.specialization.isNotEmpty) {
      try {
        selectedSpecialization = DoctorSpecialization.values.firstWhere(
              (e) => e.toString() == doctor.specialization,
        );
        if (selectedSpecialization == DoctorSpecialization.all) {
          selectedSpecialization = null;
        }
      } catch (e) {
        selectedSpecialization = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.doctor == null ? 'Add New Doctor' : 'Update Doctor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Normal_Title(title: "Photo"),
                _buildImagePickerSection(),
                const SizedBox(height: 8),
                _buildFormFields(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return GestureDetector(
      onTap: _handleImageSelection,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        height: 250,
        width: double.infinity,
        child: imageString != null && imageString!.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageString!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildPlaceholderImage(),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      "assets/blank person.jpg",
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFormField("Name", _nameController, "Enter Name"),
        _buildTextFormField("Degree", _degreeController, "Enter Degree"),
        _buildTextFormField("Designation", _designationController, "Enter Designation"),
        _buildTextFormField("Hospital", _hospitalController, "Enter Hospital"),
        _buildSpecializationDropdown(),
        _buildTextFormField("Email", _emailController, "Enter email address"),
        _buildTextFormField("Phone Number", _phoneController, "Enter Phone Number"),
        const Normal_Title(title: "Visiting Days"),
        _buildDaySelectionChips(),
        const SizedBox(height: 16),
        const Normal_Title(title: "Visiting Time"),
        _buildTimePickerTile(),
      ],
    );
  }

  Widget _buildTextFormField(String title, TextEditingController controller, String errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Normal_Title(title: title),
        TextFormField(
          controller: controller,
          validator: (value) => value!.isEmpty ? errorText : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSpecializationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Normal_Title(title: "Specialization"),
        DropdownButtonFormField<DoctorSpecialization>(
          value: selectedSpecialization,
          hint: const Text(
            "Select Specialization",
            style: TextStyle(fontSize: 14.0),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Color_codes.meddle,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Color_codes.meddle,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Color_codes.meddle,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
          ),
          items: DoctorSpecialization.values
              .where((e) => e != DoctorSpecialization.all)
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e.displayName,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          )
              .toList(),
          onChanged: (value) => setState(() => selectedSpecialization = value),
          validator: (value) => value == null ? 'Please select specialization' : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDaySelectionChips() {
    return Wrap(
      spacing: 8,
      children: allDays.map((day) {
        final isSelected = selectedDays.contains(day);
        return FilterChip(
          selected: isSelected,
          label: Text(day),
          onSelected: (value) {
            setState(() {
              isSelected ? selectedDays.remove(day) : selectedDays.add(day);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimePickerTile() {
    return ListTile(
      title: Text(visitingTime ?? "Choose Time"),
      trailing: const Icon(Icons.access_time),
      onTap: _selectTime,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Visibility(
          visible: !_loading,
          replacement: const Center(child: CircularProgressIndicator()),
          child: FilledButton(
            onPressed: widget.doctor == null ? _saveForm : _updateInformation,
            child: Text(widget.doctor == null ? "Save" : "Update"),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        if (widget.doctor != null)
          FilledButton(
            onPressed: () => _deleteDoctor(widget.doctor!),
            child: const Text("Delete"),
          ),
      ],
    );
  }

  Future<void> _handleImageSelection() async {
    selectedPhoto = await ImgBBImagePicker.pickImage();
    if (selectedPhoto == null) return;

    final response = await ImgBBImagePicker.uploadImage(
      context: context,
      imageFile: selectedPhoto!,
    );

    if (response == null) return;

    setState(() {
      imageString = response.imageUrl;
    });
  }

  Future<void> _deleteDoctor(Doctor doctor) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${doctor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctor.id)
            .delete();

        if (mounted) {
          showsnakBar(context, "${doctor.name} deleted", true);
          Navigator.pushNamedAndRemoveUntil(
            context,
            DoctorPage.name,
                (predicate) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          showsnakBar(context, "Delete failed: ${e.toString()}", false);
        }
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted = DateFormat.jm().format(
        DateTime(2020, 1, 1, picked.hour, picked.minute),
      );
      setState(() {
        visitingTime = formatted;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedDays.isEmpty) {
        showsnakBar(context, "Please select at least one visiting day", false);
        return;
      }
      if (visitingTime == null) {
        showsnakBar(context, "Please select a visiting time", false);
        return;
      }
      if (selectedSpecialization == null) {
        showsnakBar(context, 'Please select specialization', false);
        return;
      }

      _saveDoctorInformation();
    }
  }

  Future<void> _saveDoctorInformation() async {
    try {
      final doctor = Doctor(
        degree: _degreeController.text.trim(),
        designation: _designationController.text.trim(),
        email: _emailController.text.trim(),
        hospital: _hospitalController.text.trim(),
        imageUrl: imageString ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: selectedSpecialization.toString(),
        visitingTime: visitingTime!,
        visitingDays: selectedDays,
      );

      await FirebaseFirestore.instance
          .collection('doctors')
          .add(doctor.toFirestore());

      if (mounted) {
        showsnakBar(context, "Doctor Saved Successfully!", true);
        Navigator.pushNamedAndRemoveUntil(
          context,
          DoctorPage.name,
              (predicate) => false,
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showsnakBar(context, "Error: $e", false);
      }
    }
  }

  Future<void> _updateInformation() async {
    if (widget.doctor?.id == null) return;

    _loading = true;
    setState(() {});

    try {
      final updatedDoctor = Doctor(
        id: widget.doctor!.id,
        degree: _degreeController.text.trim(),
        designation: _designationController.text.trim(),
        email: _emailController.text.trim(),
        hospital: _hospitalController.text.trim(),
        imageUrl: imageString ?? widget.doctor!.imageUrl,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: selectedSpecialization.toString(),
        visitingTime: visitingTime!,
        visitingDays: selectedDays,
      );

      await FirebaseFirestore.instance
          .collection("doctors")
          .doc(widget.doctor!.id)
          .update(updatedDoctor.toFirestore());

      _loading = false;
      if (mounted) {
        showsnakBar(context, "Doctor Information Updated Successfully", true);
        Navigator.pop(context, updatedDoctor);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _loading = false;
        showsnakBar(context, "Error: $e", false);
      }
    }
  }
}