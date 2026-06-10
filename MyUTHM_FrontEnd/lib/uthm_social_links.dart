import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme/app_colors.dart';

class UthmSocialLinksRow extends StatelessWidget {
  const UthmSocialLinksRow({super.key});

  static const _links = [
    _UthmSocialLink(
      label: 'Facebook',
      url: 'https://www.facebook.com/uthmjohor/?locale=ms_MY',
      brand: _SocialBrand.facebook,
    ),
    _UthmSocialLink(
      label: 'Instagram',
      url: 'https://www.instagram.com/uthmjohor/',
      brand: _SocialBrand.instagram,
    ),
    _UthmSocialLink(
      label: 'LinkedIn',
      url:
          'https://www.linkedin.com/school/universiti-tun-hussein-onn-malaysia/',
      brand: _SocialBrand.linkedin,
    ),
    _UthmSocialLink(
      label: 'Website',
      url: 'https://www.uthm.edu.my/en/',
      brand: _SocialBrand.website,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int index = 0; index < _links.length; index++) ...[
          _SocialIconButton(link: _links[index]),
          if (index != _links.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.link});

  final _UthmSocialLink link;

  Future<void> _launch() async {
    final uri = Uri.parse(link.url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $uri');
      }
    } catch (error) {
      debugPrint('Error launching URL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: link.label,
      button: true,
      child: InkWell(
        onTap: _launch,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderColor),
            boxShadow: [
              BoxShadow(
                color: colors.primaryText.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _BrandMark(brand: link.brand),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.brand});

  final _SocialBrand brand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return switch (brand) {
      _SocialBrand.facebook => const Text(
          'f',
          style: TextStyle(
            color: Color(0xFF1877F2),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      _SocialBrand.instagram => Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFFFEDA75),
                Color(0xFFFA7E1E),
                Color(0xFFD62976),
                Color(0xFF962FBF),
                Color(0xFF4F5BD5),
              ],
            ),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
      _SocialBrand.linkedin => Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0A66C2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      _SocialBrand.website => Icon(
          Icons.language_rounded,
          color: colors.brandPrimary,
          size: 25,
        ),
    };
  }
}

enum _SocialBrand { facebook, instagram, linkedin, website }

class _UthmSocialLink {
  const _UthmSocialLink({
    required this.label,
    required this.url,
    required this.brand,
  });

  final String label;
  final String url;
  final _SocialBrand brand;
}
