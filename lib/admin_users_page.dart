part of 'main.dart';

class _PendingApprovalPage extends StatelessWidget {
  const _PendingApprovalPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval pending'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.hourglass_top, size: 72, color: Colors.amber),
              SizedBox(height: 24),
              Text(
                'Your registration request has been sent to the admin. You can log in after approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Please wait for admin approval or contact support if required.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUsersPage extends StatelessWidget {
  const _AdminUsersPage();

  Future<void> _updateUserRole(
    BuildContext context,
    String userId,
    String newRole,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated to $newRole.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update role.')));
      }
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    String userId,
    String userName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully.')),
          );
        }
      } on FirebaseException catch (e) {
        if (context.mounted) {
          String errorMsg = 'Delete failed.';
          if (e.code == 'permission-denied') {
            errorMsg = 'Permission denied. Check Firestore rules.';
          } else {
            errorMsg = 'Error: ${e.message}';
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final name = data['name']?.toString() ?? 'Unknown';
            final role = data['role']?.toString() ?? 'pending';
            final createdAt = data['createdAt'] as Timestamp?;
            final createdText = createdAt != null
                ? createdAt.toDate().toLocal().toString().split('.').first
                : 'Date unknown';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getRoleColor(
                          role,
                        ).withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: _getRoleColor(role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User name: $name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: _getRoleColor(role),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Joined: $createdText',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (role != 'admin')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'admin'),
                          icon: const Icon(Icons.security, size: 18),
                          label: const Text(
                            'Make Admin',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (role == 'pending') ...[
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'retailer'),
                          icon: const Icon(Icons.storefront, size: 18),
                          label: const Text(
                            'Approve Retailer',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'customer'),
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Approve Customer',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      if (role == 'retailer')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'pending'),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text(
                            'Suspend',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (role == 'customer')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'pending'),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text(
                            'Suspend',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      IconButton(
                        onPressed: () => _deleteUser(context, doc.id, name),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'retailer':
        return Colors.green;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
