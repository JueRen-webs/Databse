import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kBackgroundColor = Color(0xFFF4F6FC);
const Color kInk = Color(0xFF061128);
const Color kMuted = Color(0xFF6B7280);

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isNotificationOn = true;

  final List<_NewsItem> _news = const [
    _NewsItem(
      title:
      'Tidur dalam kereta, ambil upah mesin rumput, jaga enam anak - demi segulung PhD',
      time: '2h ago',
      accent: Color(0xFF117E82),
      icon: Icons.bedtime_rounded,
      secondaryIcon: Icons.grass_rounded,
    ),
    _NewsItem(
      title: 'Liputan Berita UTHM:\n7 Disember 2025',
      time: '5h ago',
      accent: Color(0xFF174EB9),
      icon: Icons.description_rounded,
      secondaryIcon: Icons.school_rounded,
    ),
    _NewsItem(
      title:
      'UTHM perkasa EduTourism berteraskan Ecohydrology, sokong agenda UNESCO, SDG dan TVET',
      time: '1d ago',
      accent: Color(0xFF73BDC1),
      icon: Icons.public_rounded,
      secondaryIcon: Icons.water_drop_rounded,
    ),
  ];

  final List<_EventItem> _events = const [
    _EventItem(day: '07', month: 'DEC', year: '2025', title: 'FESTKON UTHM'),
    _EventItem(
      day: '07',
      month: 'DEC',
      year: '2025',
      title: 'Pertandingan Konsep Reka Bentuk Bangunan Canselori UTHM',
    ),
    _EventItem(
      day: '15',
      month: 'DEC',
      year: '2025',
      title: 'Program Audit Pengauditan Dalaman MS ISO 9001:2015',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Notification Page',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 118),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Notification Setting',
                  style: GoogleFonts.poppins(
                    color: kMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 0.92,
                  child: Switch(
                    value: _isNotificationOn,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF006ED1),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      setState(() => _isNotificationOn = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(
              title: 'News',
              showViewAll: false,
            ),

            const SizedBox(height: 12),

            ..._news.map(
                  (item) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNewsCard(item),
                  ),
            ),

            const SizedBox(height: 12),

            _buildSectionHeader(
              title: 'Events',
              showViewAll: true,
              onViewAll: () {},
            ),

            const SizedBox(height: 12),

            ..._events.map(
                  (item) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildEventCard(item),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool showViewAll,
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: kPrimaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showViewAll)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: kPrimaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNewsCard(_NewsItem item) {
    return InkWell(
      onTap: () => _openDetail(item.title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 118),
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNewsIllustration(item),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.accent.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'NEWS',
                            style: GoogleFonts.poppins(
                              color: item.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.time,
                          style: GoogleFonts.poppins(
                            color: kMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: kInk,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsIllustration(_NewsItem item) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.accent.withOpacity(0.78),
            item.accent,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -18,
            child: Icon(
              item.icon,
              color: Colors.white.withOpacity(0.22),
              size: 88,
            ),
          ),
          Positioned(
            left: 18,
            top: 24,
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.secondaryIcon,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(_EventItem item) {
    return InkWell(
      onTap: () => _openDetail(item.title),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            SizedBox(
              width: 66,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.month,
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.day,
                    style: GoogleFonts.poppins(
                      color: kInk,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 0.98,
                    ),
                  ),
                  Text(
                    item.year,
                    style: GoogleFonts.poppins(
                      color: kMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: const Color(0xFFD8DFEA),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: kMuted,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All day',
                        style: GoogleFonts.poppins(
                          color: kMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: kPrimaryBlue,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E293B).withOpacity(0.07),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

    void _openDetail(String title) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailPage(title: title),
        ),
      );
    }
  }

class _NewsItem {
  final String title;
  final String time;
  final Color accent;
  final IconData icon;
  final IconData secondaryIcon;

  const _NewsItem({
    required this.title,
    required this.time,
    required this.accent,
    required this.icon,
    required this.secondaryIcon,
  });
}

class _EventItem {
  final String day;
  final String month;
  final String year;
  final String title;

  const _EventItem({
    required this.day,
    required this.month,
    required this.year,
    required this.title,
  });
}

class EventDetailPage extends StatelessWidget {
  final String title;

  const EventDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: kPrimaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UTHM',
              style: GoogleFonts.poppins(
                color: kPrimaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'News Portal',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Home',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: kMuted,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'ALUMNI Disember 7, 2025',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: kMuted,
              ),
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&q=80&w=1000',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Oleh Suriayati Baharom',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: kMuted,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 20),

            _buildArticleText(
              'PAGOH - Bagi Nurul Zakiah Zamri Tan, 42 perjalanan menamatkan pengajian doktor falsafah (PhD) bukan sekadar pencapaian akademik, tetapi kisah perjuangan luar biasa seorang ibu, isteri dan pelajar yang bertarung dengan ujian hidup selama lebih lima tahun.',
            ),
            _buildArticleText(
              'Bermula pada tahun 2019 di bawah seliaan Profesor Madya Ts. Dr. Azrin Hani Abd Rashid, Fakulti Teknologi Kejuruteraan (FTK). Zakiah menempuh laluan penuh liku, dari tekanan kewangan, beban emosi, hingga tanggungjawab membesarkan enam anak tanpa pembantu.',
            ),
            _buildArticleText(
              '"Saya pernah tidur dalam kereta dan mandi di hentian R&R Pagoh semata-mata mahu jimat masa dan kos ulang-alik."',
            ),
            _buildArticleText(
              '"Anak-anak dijaga ibu mertua, dan saya siapkan makanan frozen untuk beberapa hari," ceritanya.',
            ),
            _buildArticleText(
              'Lebih menyentuh hati, Zakiah turut mengambil upah memesin rumput, termasuk kawasan seluas empat ekar, selain bekerja sambilan sebagai pensyarah, mengemas homestay dan membuat rekaan grafik untuk menampung kehidupan.',
            ),
            _buildArticleText(
              '"Kenapa mesin rumput? Sebab itu satu-satunya kerja yang saya boleh buat waktu itu dan anehnya, bunyi mesin rumput itu menenangkan fikiran saya," ujarnya sambil tersenyum.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF424242),
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}