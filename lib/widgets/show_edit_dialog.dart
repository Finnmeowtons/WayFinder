import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:way_finders/ip_address.dart';

Future<Map<String, dynamic>?> showEditStickDialog(
    BuildContext context, {
      required int userDeviceId,
      required String deviceUid,
      required String currentName,
      String? currentImageUrl,
    }) async {
  final TextEditingController nameController =
  TextEditingController(text: currentName);
  File? selectedImage;

  return await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Device",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Image picker
                    GestureDetector(
                      onTap: () async {
                        final picked =
                        await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => selectedImage = File(picked.path));
                        }
                      },
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (currentImageUrl != null
                            ? NetworkImage("${IpAddress.ipAddress}$currentImageUrl")
                            : null) as ImageProvider<Object>?,
                        child: selectedImage == null && currentImageUrl == null
                            ? Icon(
                          Icons.camera_alt_rounded,
                          size: 36,
                          color: Colors.blue.shade400,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(text: deviceUid.toString().replaceAll('+', '')),
                      decoration: InputDecoration(
                        labelText: "Device UID",
                        prefixIcon: const Icon(Icons.fingerprint_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                      enabled: false, // ensures user cannot edit
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextField(
                      controller: nameController,
                      onSubmitted: (_){
                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Device name cannot be empty."),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, {
                          'action': 'edit',
                          'id': userDeviceId,
                          'name': nameController.text,
                          'image': selectedImage?.path,
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Name",
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete button with confirmation
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Disconnect"),
                                content: const Text(
                                    "Are you sure you want to disconnect this device?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Disconnect",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              Navigator.pop(context, {
                                'action': 'delete',
                                'id': userDeviceId,
                              });
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            "Disconnect",
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        // Save button
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Device name cannot be empty."),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context, {
                              'action': 'edit',
                              'id': userDeviceId,
                              'name': nameController.text,
                              'image': selectedImage?.path,
                            });
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
