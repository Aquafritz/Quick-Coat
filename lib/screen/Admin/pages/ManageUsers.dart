import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:quickcoat/screen/Admin/top_bar.dart'; // if you need your top bar

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _userStream() {
    // No filters here to avoid composite indexes.
    // We filter by accountType == "Customer" and isDeleted != true in Dart.
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  List<Map<String, dynamic>> _buildUserList(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    final docs = snapshot.data?.docs ?? [];
    final q = _q.toLowerCase();

    final formatter = DateFormat('yyyy-MM-dd');

    final users = <Map<String, dynamic>>[];

    for (final doc in docs) {
      final data = doc.data();

      final accountType = (data['accountType'] ?? '').toString();
      final isDeleted = (data['isDeleted'] == true);

      // Only CUSTOMER accounts and not deleted
      if (accountType != 'Customer' || isDeleted) continue;

      final fullName = (data['full_name'] ?? '').toString();
      final email = (data['email_Address'] ?? '').toString();

      // Search filter
      if (q.isNotEmpty) {
        final nameMatch = fullName.toLowerCase().contains(q);
        final emailMatch = email.toLowerCase().contains(q);
        if (!nameMatch && !emailMatch) continue;
      }

      String createdStr = '-';
      final createdRaw = data['created_at'];
      if (createdRaw is Timestamp) {
        createdStr = formatter.format(createdRaw.toDate());
      } else if (createdRaw is String && createdRaw.isNotEmpty) {
        createdStr = createdRaw;
      }

      users.add({
        'id': doc.id,
        'name': fullName,
        'email': email,
        'created_at': createdStr,
      });
    }

    // newest first (string dates are already in yyyy-MM-dd format above)
    users.sort(
      (a, b) =>
          (b['created_at'] as String).compareTo(a['created_at'] as String),
    );

    return users;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Future<void> _softDelete(String id) async {
    final ok = await _confirm(
      context,
      title: 'Move user to Deleted?',
      message:
          'This will hide the user from the active list and move it to Deleted Users.',
    );
    if (!ok) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'isDeleted': true,
        'deleted_at': FieldValue.serverTimestamp(),
      });
      _toast('User moved to Deleted Users');
    } catch (e) {
      _toast('Failed to delete user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Customers',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View, search, and manage all customer accounts.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 340,
                    child: TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _q = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search name or email…',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- TABLE CARD ----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Table header row
                      Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Created',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 96,
                              child: Text(
                                'Actions',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table body
                      Expanded(
                        child: StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>
                        >(
                          stream: _userStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    'Error loading users:\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final users = _buildUserList(snapshot);

                            if (users.isEmpty) {
                              return const Center(
                                child: Text('No customers found'),
                              );
                            }

                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    thickness: 0.4,
                                    color: Colors.grey.shade200,
                                  ),
                              itemBuilder: (context, index) {
                                final u = users[index];
                                final bgColor =
                                    index.isEven
                                        ? Colors.white
                                        : const Color(0xFFF9FAFB);

                                return InkWell(
                                  onTap: () {
                                    // In future: open details drawer / dialog
                                  },
                                  child: Container(
                                    color: bgColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        // Name + avatar
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: const Color(
                                                  0xFFEEF2FF,
                                                ),
                                                child: Text(
                                                  _initials(
                                                    (u['name'] ?? '') as String,
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Flexible(
                                                child: Text(
                                                  (u['name'] ?? '-') as String,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Email
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            (u['email'] ?? '-') as String,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Created
                                        Expanded(
                                          child: Text(
                                            (u['created_at'] ?? '-') as String,
                                          ),
                                        ),

                                        // Actions
                                        SizedBox(
                                          width: 96,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                tooltip: 'Delete',
                                                onPressed:
                                                    () => _softDelete(
                                                      u['id'] as String,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
