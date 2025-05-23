import 'package:book_world/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';

class IssueReturnScreen extends StatefulWidget {
  const IssueReturnScreen({super.key});

  @override
  State<IssueReturnScreen> createState() => _IssueReturnScreenState();
}

class _IssueReturnScreenState extends State<IssueReturnScreen> {
  bool isIssueActive = true;

  Widget _buildInputField(String label, String hintText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isActive ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    title.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isActive)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.white.withAlpha(13)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8C6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 0, top: 44, bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.orange, size: 32),
                  SizedBox(width: 8),
                  Text(
                    'Issue/Return Books',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              title: 'Issue a Book',
              isActive: isIssueActive,
              onTap: () => setState(() => isIssueActive = true),
              children: [
                _buildInputField('Book ID', 'Enter the ID of book..'),
                _buildInputField('Student Name', 'Enter the Student name..'),
                _buildInputField('Student ID', 'Enter the ID of Student..'),
              ],
            ),
            _buildSection(
              title: 'Return a Book',
              isActive: !isIssueActive,
              onTap: () => setState(() => isIssueActive = false),
              children: [
                _buildInputField('Book ID', 'Enter the ID of book..'),
                _buildInputField('Student Name', 'Enter the Student name..'),
                _buildInputField('Student ID', 'Enter the ID of Student..'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap:
                    () =>
                        Get.offAllNamed(RouteNames.librarianHome),
                child: _buildNavItem(icon: Icons.home, label: 'Home'),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(RouteNames.addBook),
                child: _buildNavItem(icon: Icons.add_box, label: 'Add Book'),
              ),
              _buildNavItem(
                icon: Icons.swap_horiz,
                label: 'Issue/Return',
                isSelected: true,
              ),
              GestureDetector(
                onTap:
                    () => Get.toNamed(RouteNames.allBooks),
                child: _buildNavItem(icon: Icons.people, label: 'All Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

}
