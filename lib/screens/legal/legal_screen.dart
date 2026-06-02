import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LegalScreen extends StatelessWidget {
  final String page;
  const LegalScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = page == 'privacy';
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
    final content = isPrivacy ? _privacyContent : _termsContent;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLastUpdated(isPrivacy),
                    const SizedBox(height: 20),
                    ...content.map((section) => _buildSection(section)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFFDDDDDD),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(bool isPrivacy) {
    return Row(
      children: [
        Icon(Icons.update, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 6),
        Text(
          'Last updated: ${isPrivacy ? 'June 1, 2026' : 'June 1, 2026'}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Text(section.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(height: 12),
          ...section.paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(p,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.7,
                    )),
              )),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...section.bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(b,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.6,
                            )),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class LegalSection {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  const LegalSection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });
}

const _privacyContent = [
  LegalSection(
    title: 'Information We Collect',
    paragraphs: [
      'When you create an account on ThiraiPedia, we collect information that you provide directly, including your username, email address, and any profile information you choose to add such as a biography.',
      'We also automatically collect certain information when you use our platform, including your IP address, browser type, device information, and usage data such as pages visited and features accessed.',
    ],
    bullets: [
      'Account information: username, email, profile picture, bio',
      'Usage data: movies viewed, ratings, reviews, lists created',
      'Device information: browser type, operating system, IP address',
      'Cookies and similar tracking technologies',
    ],
  ),
  LegalSection(
    title: 'How We Use Your Information',
    paragraphs: [
      'We use the information we collect to provide, maintain, and improve our services, to personalize your experience, and to communicate with you about updates and new features.',
    ],
    bullets: [
      'To create and manage your account',
      'To personalize movie recommendations and content',
      'To display user reviews, ratings, and community content',
      'To send notifications about activity on your account',
      'To analyze and improve our platform performance',
      'To detect and prevent fraudulent or unauthorized activity',
    ],
  ),
  LegalSection(
    title: 'Information Sharing',
    paragraphs: [
      'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:',
    ],
    bullets: [
      'With your consent or at your direction',
      'With service providers who assist us in operating our platform',
      'To comply with legal obligations or protect our rights',
      'In connection with a business transfer or acquisition',
    ],
  ),
  LegalSection(
    title: 'Data Security',
    paragraphs: [
      'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. These include encryption, secure socket layer technology (SSL), and regular security audits.',
      'However, no method of transmission over the Internet or electronic storage is 100% secure. We cannot guarantee absolute security of your data.',
    ],
  ),
  LegalSection(
    title: 'Your Rights',
    paragraphs: [
      'You have the right to access, update, or delete your personal information at any time through your account settings. You may also contact us directly to exercise any of your data protection rights.',
    ],
    bullets: [
      'Access your personal data',
      'Correct inaccurate or incomplete data',
      'Delete your account and associated data',
      'Object to or restrict processing of your data',
      'Export your data in a portable format',
    ],
  ),
  LegalSection(
    title: 'Cookies',
    paragraphs: [
      'ThiraiPedia uses cookies and similar tracking technologies to enhance your browsing experience, analyze site traffic, and understand where our audience comes from. You can control cookie preferences through your browser settings.',
    ],
  ),
  LegalSection(
    title: 'Contact Us',
    paragraphs: [
      'If you have any questions about this Privacy Policy or our data practices, please contact us through our Contact page or email us at privacy@thiraipedia.com.',
    ],
  ),
];

const _termsContent = [
  LegalSection(
    title: 'Acceptance of Terms',
    paragraphs: [
      'By accessing or using ThiraiPedia, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not access or use our platform.',
      'We reserve the right to update or modify these terms at any time without prior notice. Continued use of the platform after changes constitutes acceptance of the new terms.',
    ],
  ),
  LegalSection(
    title: 'Account Registration',
    paragraphs: [
      'To access certain features of ThiraiPedia, you must create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
    ],
    bullets: [
      'You must provide accurate and complete information when creating an account',
      'You must not create multiple accounts or use automated methods to create accounts',
      'You must notify us immediately of any unauthorized use of your account',
      'You must be at least 13 years of age to create an account',
    ],
  ),
  LegalSection(
    title: 'User Conduct',
    paragraphs: [
      'You agree to use ThiraiPedia in a responsible manner and to respect other users of the platform. You are solely responsible for any content you post, including reviews, comments, and ratings.',
    ],
    bullets: [
      'Do not post false, misleading, or defamatory content',
      'Do not harass, abuse, or threaten other users',
      'Do not post spam or unauthorized promotional content',
      'Do not attempt to manipulate ratings or reviews',
      'Do not violate the intellectual property rights of others',
      'Do not use the platform for any illegal purpose',
    ],
  ),
  LegalSection(
    title: 'Content Ownership',
    paragraphs: [
      'You retain all rights to the content you submit on ThiraiPedia. By submitting content, you grant us a non-exclusive, royalty-free license to display, distribute, and modify your content in connection with the platform.',
      'Movie data, posters, and related media are provided for informational purposes and may be subject to copyright by their respective owners.',
    ],
  ),
  LegalSection(
    title: 'Intellectual Property',
    paragraphs: [
      'The ThiraiPedia name, logo, design, and platform features are owned by ThiraiPedia and are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, or reproduce any part of our platform without our express written consent.',
    ],
  ),
  LegalSection(
    title: 'Limitation of Liability',
    paragraphs: [
      'ThiraiPedia is provided "as is" without warranties of any kind, either express or implied. We do not guarantee that the platform will be uninterrupted, secure, or error-free.',
      'In no event shall ThiraiPedia be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the platform.',
    ],
  ),
  LegalSection(
    title: 'Termination',
    paragraphs: [
      'We reserve the right to suspend or terminate your account at any time for violation of these terms or for any other reason at our discretion. Upon termination, your right to use the platform will immediately cease.',
      'You may delete your account at any time through your profile settings. We will delete your personal data in accordance with our Privacy Policy.',
    ],
  ),
  LegalSection(
    title: 'Governing Law',
    paragraphs: [
      'These Terms of Service shall be governed by and construed in accordance with the laws of India. Any disputes arising from these terms shall be subject to the exclusive jurisdiction of the courts in Chennai, Tamil Nadu.',
    ],
  ),
  LegalSection(
    title: 'Contact',
    paragraphs: [
      'For any questions regarding these Terms of Service, please contact us through our Contact page or email us at legal@thiraipedia.com.',
    ],
  ),
];
