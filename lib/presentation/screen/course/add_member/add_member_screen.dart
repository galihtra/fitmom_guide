import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../data/services/course/course_service.dart';

class AddMemberScreen extends StatefulWidget {
  final String courseId;

  const AddMemberScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final CourseService _courseService = CourseService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Set<String> _selectedUsers = {}; // Menyimpan user yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchUsersAndMembers();
  }

  void _fetchUsersAndMembers() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();

    List<String> members = [];
    if (courseSnapshot.exists && courseSnapshot.data()?['members'] != null) {
      members = List<String>.from(courseSnapshot.data()!['members']);
    }

    final users = usersSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'email': doc.data()['email'] ?? 'No Email',
        'name': doc.data()['name'] ?? 'Unknown',
      };
    }).toList();

    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _selectedUsers =
          members.toSet(); // Tetapkan user yang sudah menjadi member
    });
  }

  void _filterUsers(String query) {
    final filtered = _allUsers.where((user) {
      final emailLower = user['email'].toLowerCase();
      return emailLower.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _addMembers() async {
    for (String userId in _selectedUsers) {
      await _courseService.addMemberToCourse(widget.courseId, userId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Members updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Members')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return CheckboxListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        value: _selectedUsers.contains(user['id']),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedUsers.add(user['id']);
                            } else {
                              _selectedUsers.remove(user['id']);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedUsers.isEmpty ? null : _addMembers,
              child: Text('Tambah Members'),
            ),
          ),
        ],
      ),
    );
  }
}
