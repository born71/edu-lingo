import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/animated_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userProgress = Provider.of<ProgressProvider>(context, listen: false).userProgress;
    _nameController = TextEditingController(text: userProgress.displayName);
    _emailController = TextEditingController(text: userProgress.email);
    _bioController = TextEditingController(text: userProgress.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await Provider.of<ProgressProvider>(context, listen: false).updateProfile(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    final userProgress = Provider.of<ProgressProvider>(context, listen: false).userProgress;
    setState(() {
      _nameController.text = userProgress.displayName;
      _emailController.text = userProgress.email;
      _bioController.text = userProgress.bio;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
              tooltip: 'Cancel',
            ),
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSaving ? null : _saveProfile,
              tooltip: 'Save',
            ),
          ],
        ],
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          final userProgress = progressProvider.userProgress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Avatar
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: _buildAvatar(userProgress.displayName),
                  ),
                  const SizedBox(height: 30),

                  // Profile Fields
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: _buildProfileCard(userProgress),
                  ),
                  const SizedBox(height: 20),

                  // Stats Card
                  FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: _buildStatsCard(userProgress),
                  ),
                  const SizedBox(height: 20),

                  // Achievement Badge
                  FadeInWidget(
                    delay: const Duration(milliseconds: 400),
                    child: _buildAchievementCard(userProgress),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String displayName) {
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade400,
                Colors.purpleAccent.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF121212), width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(userProgress) {
    return Card(
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.deepPurple.shade300),
                const SizedBox(width: 10),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Display Name',
              icon: Icons.badge_outlined,
              enabled: _isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.trim().isEmpty)) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (_isEditing && value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info_outline,
              enabled: _isEditing,
              maxLines: 3,
              hintText: 'Tell us about yourself...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey.shade400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: enabled ? const Color(0xFF2A2A3E) : const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
    );
  }

  Widget _buildStatsCard(userProgress) {
    return Card(
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.deepPurple.shade300),
                const SizedBox(width: 10),
                const Text(
                  'Learning Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.stars,
                  value: '${userProgress.totalXP}',
                  label: 'XP',
                  color: Colors.amber,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  value: '${userProgress.currentStreak}',
                  label: 'Day Streak',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  value: '${userProgress.totalLessonsCompleted}',
                  label: 'Lessons',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(
              label: 'Overall Accuracy',
              value: userProgress.overallAccuracy,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade800,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(userProgress) {
    String badge = 'Beginner';
    IconData badgeIcon = Icons.school;
    Color badgeColor = Colors.green;

    if (userProgress.totalXP >= 1000) {
      badge = 'Expert';
      badgeIcon = Icons.workspace_premium;
      badgeColor = Colors.amber;
    } else if (userProgress.totalXP >= 500) {
      badge = 'Advanced';
      badgeIcon = Icons.star;
      badgeColor = Colors.purple;
    } else if (userProgress.totalXP >= 100) {
      badge = 'Intermediate';
      badgeIcon = Icons.trending_up;
      badgeColor = Colors.blue;
    }

    return Card(
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    badgeColor.withOpacity(0.3),
                    badgeColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 2),
              ),
              child: Icon(badgeIcon, color: badgeColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Level',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getNextLevelText(userProgress.totalXP),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextLevelText(int xp) {
    if (xp >= 1000) {
      return 'You\'ve reached the highest level!';
    } else if (xp >= 500) {
      return '${1000 - xp} XP to Expert';
    } else if (xp >= 100) {
      return '${500 - xp} XP to Advanced';
    } else {
      return '${100 - xp} XP to Intermediate';
    }
  }
}
