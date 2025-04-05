import 'package:flutter/material.dart';
import 'package:book_world/screens/librarians/librarian_home_screen.dart';
import 'package:book_world/screens/librarians/add_book_screen.dart';
import 'package:book_world/screens/librarians/issue_return_screen.dart';

class StudentInfo {
  final String id;
  final String name;
  final String registrationDate;
  final String? username;
  final String? email;
  final String? mobile;
  final String? dob;
  final String? localAddress;
  final String? permanentAddress;

  StudentInfo({
    required this.id,
    required this.name,
    required this.registrationDate,
    this.username,
    this.email,
    this.mobile,
    this.dob,
    this.localAddress,
    this.permanentAddress,
  });
}

class AllStudentsScreen extends StatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<StudentInfo> students = [
    StudentInfo(
      id: '001',
      name: 'Vivek Sharma',
      registrationDate: '22-02-2025',
    ),
    StudentInfo(
      id: '002',
      name: 'Shubham Ganvani',
      registrationDate: '24-02-2025',
    ),
    StudentInfo(
      id: '003',
      name: 'Vrinda Sharma',
      registrationDate: '25-02-2025',
      username: 'vrinda_sharma_08',
      email: 'vrinda.sharma@gamil.com',
      mobile: '8976453201',
      dob: '20/06/2004',
      localAddress:
          '1/2 abc nagar, def place, ghi city, xyz state, country\nPIN CODE-282002',
      permanentAddress:
          '1/2 abc nagar, def place, ghi city, xyz state, country\nPIN CODE-282005',
    ),
  ];

  List<StudentInfo> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = students;
    _searchController.addListener(_filterStudents);
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents =
          students.where((student) {
            return student.id.toLowerCase().contains(query) ||
                student.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  Widget _buildStudentCard(StudentInfo student) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student ID: ${student.id}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Name: ${student.name}', style: const TextStyle(fontSize: 16)),
            Text(
              'Registered On: ${student.registrationDate}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        children: [
          if (student.username != null) ...[
            _buildInfoRow('Username', student.username!),
            _buildInfoRow('E-mail', student.email!),
            _buildInfoRow('Mobile', student.mobile!),
            _buildInfoRow('DOB', student.dob!),
            _buildInfoRow('Local Address', student.localAddress!),
            _buildInfoRow('Permanent Address', student.permanentAddress!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement total books issued functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Total Books Issued',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8C6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 60, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.orange, size: 32),
                SizedBox(width: 8),
                Text(
                  'All Students Registered',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Student ID or Name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(filteredStudents[index]);
              },
            ),
          ),
        ],
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
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LibrarianHomeScreen(),
                    ),
                  );
                },
                child: _buildNavItem(icon: Icons.home, label: 'Home'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookScreen(),
                    ),
                  );
                },
                child: _buildNavItem(icon: Icons.add_box, label: 'Add Book'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IssueReturnScreen(),
                    ),
                  );
                },
                child: _buildNavItem(
                  icon: Icons.swap_horiz,
                  label: 'Issue/Return',
                ),
              ),
              _buildNavItem(
                icon: Icons.people,
                label: 'All Students',
                isSelected: true,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
