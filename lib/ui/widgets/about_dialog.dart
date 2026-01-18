import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// About dialog showing developer info with social links
class AboutDeveloperDialog extends StatelessWidget {
  const AboutDeveloperDialog({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),

              // Profile Avatar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/pp.img.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Developer Name
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      'Design & Developed by',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sabarivasan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Social Links
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Column(
                  children: [
                    // Portfolio
                    _SocialLinkButton(
                      icon: Icons.language_rounded,
                      label: 'Portfolio',
                      url: 'https://portfolio.vasan.tech/',
                      onTap: () => _launchUrl('https://portfolio.vasan.tech/'),
                    ),
                    const SizedBox(height: 12),

                    // GitHub
                    _SocialLinkButton(
                      icon: Icons.code_rounded,
                      label: 'GitHub',
                      url: 'github.com/Sabari-Vasan-SM',
                      onTap: () =>
                          _launchUrl('https://github.com/Sabari-Vasan-SM'),
                    ),
                    const SizedBox(height: 12),

                    // LinkedIn
                    _SocialLinkButton(
                      icon: Icons.business_rounded,
                      label: 'LinkedIn',
                      url: 'linkedin.com/in/sabarivasan-s-m',
                      onTap: () => _launchUrl(
                        'https://www.linkedin.com/in/sabarivasan-s-m-b10229255/',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Text(
                  'Expense Tracker v1.0.0',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social link button widget
class _SocialLinkButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;
  final VoidCallback onTap;

  const _SocialLinkButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });

  @override
  State<_SocialLinkButton> createState() => _SocialLinkButtonState();
}

class _SocialLinkButtonState extends State<_SocialLinkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.url,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
