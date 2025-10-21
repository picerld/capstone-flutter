import 'package:capstone/provider/nav_provider.dart';
import 'package:capstone/provider/user_provider.dart';
import 'package:capstone/ui/pages/name_entry_screen.dart';
import 'package:capstone/ui/pages/splash_screen.dart';
import 'package:capstone/ui/widgets/bottom_nav.dart';
import 'package:flutter/material.dart' as m;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Keluar Akun',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin keluar? Semua data akan dihapus.',
            style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.7)),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
            ),
            PrimaryButton(
              onPressed: () async {
                await context.read<UserProvider>().clearUserData();

                context.read<NavProvider>().resetIndex(context);

                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SplashScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const curve = Curves.easeInOut;
                          final tween = Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).chain(CurveTween(curve: curve));
                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                  (route) => false,
                );
              },
              child: Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: context.read<UserProvider>().userName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Nama',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: m.TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.black),
            decoration: m.InputDecoration(
              hintText: 'Masukkan nama baru...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.1),
              border: m.OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
            ),
            PrimaryButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await context.read<UserProvider>().saveUserName(
                    nameController.text,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    m.ScaffoldMessenger.of(context).showSnackBar(
                      m.SnackBar(
                        content: Text(
                          'Nama berhasil diubah',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context);

    return Scaffold(
      floatingHeader: true,
      floatingFooter: true,
      footers: [
        ShadcnBottomNav(
          currentIndex: navProvider.index,
          onTap: (i) => navProvider.setIndex(context, i),
        ),
      ],
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0118), Color(0xFF1A0B2E), Color(0xFF0A0118)],
          ),
        ),
        child: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) => m.Transform.translate(
                    offset: m.Offset(0, _slideAnimation.value),
                    child: m.Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        userProvider.userName ?? 'User',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project Owl Member',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildProfileOption(
                        icon: Icons.edit,
                        title: 'Edit Nama',
                        subtitle: 'Ubah nama panggilan kamu',
                        onTap: () => _showEditNameDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _buildProfileOption(
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        subtitle: 'Project Owl v1.0.0',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Project Owl'),
                                content: const Text(
                                  'Tingkatkan produktifitas mu!!',
                                ),
                                actions: [
                                  OutlineButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  PrimaryButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: 'Keluar',
                        subtitle: 'Hapus data dan keluar dari akun',
                        onTap: () => _showLogoutDialog(context),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: m.ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.3),
        ),
        onTap: onTap,
      ),
    );
  }
}
