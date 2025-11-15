import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeletedUsers extends StatefulWidget {
  const DeletedUsers({super.key});

  @override
  State<DeletedUsers> createState() => _DeletedUsersState();
}

class _DeletedUsersState extends State<DeletedUsers> {
  final TextEditingController _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _deletedStream() {
    // Single-field filter (no composite index needed)
    return FirebaseFirestore.instance
        .collection('users')
        .where('isDeleted', isEqualTo: true)
        .snapshots();
  }

  List<Map<String, dynamic>> _buildDeletedList(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    final docs = snapshot.data?.docs ?? [];
    final q = _q.toLowerCase();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    final list = <Map<String, dynamic>>[];

    for (final doc in docs) {
      final data = doc.data();

      final accountType = (data['accountType'] ?? '').toString();
      if (accountType != 'Customer') continue;

      final fullName = (data['full_name'] ?? '').toString();
      final email = (data['email_Address'] ?? '').toString();

      if (q.isNotEmpty) {
        final nameMatch = fullName.toLowerCase().contains(q);
        final emailMatch = email.toLowerCase().contains(q);
        if (!nameMatch && !emailMatch) continue;
      }

      String deletedStr = '-';
      final deletedRaw = data['deleted_at'];
      if (deletedRaw is Timestamp) {
        deletedStr = formatter.format(deletedRaw.toDate());
      } else if (deletedRaw is String && deletedRaw.isNotEmpty) {
        deletedStr = deletedRaw;
      }

      list.add({
        'id': doc.id,
        'name': fullName,
        'email': email,
        'deleted_at': deletedStr,
      });
    }

    list.sort(
      (a, b) =>
          (b['deleted_at'] as String).compareTo(a['deleted_at'] as String),
    );

    return list;
  }

  Future<void> _restore(String id) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'isDeleted': false,
        'deleted_at': FieldValue.delete(),
      });
      _toast('User restored');
    } catch (e) {
      _toast('Failed to restore user: $e');
    }
  }

  Future<void> _hardDelete(String id) async {
    final ok = await _confirm(
      context,
      title: 'Delete permanently?',
      message:
          'This will permanently remove this user document from Firestore. This action cannot be undone.',
    );
    if (!ok) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      _toast('User permanently deleted');
    } catch (e) {
      _toast('Failed to delete user: $e');
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deleted Customers',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Users that have been removed from the active list.',
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

            // CARD + TABLE
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
                                'Deleted At',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                'Actions',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>
                        >(
                          stream: _deletedStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    'Error loading deleted users:\n${snapshot.error}',
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

                            final deleted = _buildDeletedList(snapshot);

                            if (deleted.isEmpty) {
                              return const Center(
                                child: Text('No deleted customers'),
                              );
                            }

                            return ListView.separated(
                              itemCount: deleted.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    thickness: 0.4,
                                    color: Colors.grey.shade200,
                                  ),
                              itemBuilder: (context, index) {
                                final u = deleted[index];
                                final bgColor =
                                    index.isEven
                                        ? Colors.white
                                        : const Color(0xFFF9FAFB);

                                return Container(
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
                                                0xFFFFF7ED,
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
                                                overflow: TextOverflow.ellipsis,
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
                                      // Deleted at
                                      Expanded(
                                        child: Text(
                                          (u['deleted_at'] ?? '-') as String,
                                        ),
                                      ),
                                      // Actions
                                      // Actions
                                      SizedBox(
                                        width: 140,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              tooltip: 'Restore',
                                              icon: Icon(
                                                CupertinoIcons.arrow_clockwise,
                                                size: 20,
                                                color: Color(
                                                  0xFF4A90E2,
                                                ), // nice restore color
                                              ),
                                              onPressed:
                                                  () => _restore(
                                                    u['id'] as String,
                                                  ),
                                            ),
                                            IconButton(
                                              tooltip: 'Delete Permanently',
                                              icon: const Icon(
                                                CupertinoIcons.delete,
                                                size: 20,
                                                color: Color(
                                                  0xFFD0021B,
                                                ), // red for delete
                                              ),
                                              onPressed:
                                                  () => _hardDelete(
                                                    u['id'] as String,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
