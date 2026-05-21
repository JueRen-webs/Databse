import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Constants
const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kBackgroundColor = Color(0xFFF4F6FC);
// const Color kCardBgColor = Color(0xFFEBEBEB); // Removed grey, will use White
const Color kTextBlack = Colors.black87;
const Color kTextGrey = Colors.grey;

// =======================================================
//           CLASS 1: NOTIFICATION PAGE (List)
// =======================================================
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Notification Toggle State
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        automaticallyImplyLeading: false,
        title: Text(
          "Notification Page",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // --- Body Content ---
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Control Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "News",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: const Color(0xFF00695C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Notification Setting",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isNotificationOn,
                    activeThumbColor: kPrimaryBlue,
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationOn = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // News List
          _buildNewsItem(
            imageUrl:
                "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=200&h=200&fit=crop",
            title:
                "Tidur dalam kereta, ambil upah mesin rumput, jaga enam anak - demi segulung PhD",
          ),
          const SizedBox(height: 12),
          _buildNewsItem(
            imageUrl:
                "https://images.unsplash.com/photo-1557683316-973673baf926?w=200&h=200&fit=crop",
            title: "Liputan Berita UTHM: 7 Disember 2025",
          ),
          const SizedBox(height: 12),
          _buildNewsItem(
            imageUrl:
                "https://images.unsplash.com/photo-1577962917302-cd874c4e3169?w=200&h=200&fit=crop",
            title:
                "UTHM perkasa EduTourism berteraskan Ecohydrology, sokong agenda UNESCO, SDG dan TVET",
          ),

          const SizedBox(height: 24),

          // Events Header
          Text(
            "Events",
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Events List
          _buildEventItem("07 Dec 2025 : FESTKON UTHM"),
          const SizedBox(height: 8),
          _buildEventItem(
              "07 Dec 2025 : Pertandingan Konsep Reka Bentuk Bangunan Canselori UTHM"),
          const SizedBox(height: 8),
          _buildEventItem(
              "15 Dec 2025 : Program Audit Persijilan Semula MS ISO 9001:2015"),

          // Bottom Spacing
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildNewsItem({required String imageUrl, required String title}) {
    return GestureDetector(
      // Click to navigate to details
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(title: title),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white, // Changed to White
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            // Added shadow for better visibility on white bg
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(String title) {
    return GestureDetector(
      // Click to navigate to details
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(title: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Changed to White
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            // Added shadow
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
//           CLASS 2: EVENT DETAIL PAGE (Article)
// =======================================================
class EventDetailPage extends StatelessWidget {
  final String title;

  const EventDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text("UTHM",
                    style: GoogleFonts.poppins(
                        color: kPrimaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 22)),
                Text("News Portal",
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Home",
                style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tidur dalam kereta, ambil upah mesin rumput, jaga enam anak - demi segulung PhD",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ALUMNI Disember 7, 2025",
              style: GoogleFonts.poppins(fontSize: 11, color: kTextGrey),
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
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Oleh Suriayati Baharom",
              style: GoogleFonts.poppins(
                  fontSize: 12, color: kTextGrey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            _buildArticleText(
                "PAGOH - Bagi Nurul Zakiah Zamri Tan, 42 perjalanan menamatkan pengajian doktor falsafah (PhD) bukan sekadar pencapaian akademik, tetapi kisah perjuangan luar biasa seorang ibu, isteri dan pelajar yang bertarung dengan ujian hidup selama lebih lima tahun."),
            _buildArticleText(
                "Bermula pada tahun 2019 di bawah seliaan Profesor Madya Ts. Dr. Azrin Hani Abd Rashid, Fakulti Teknologi Kejuruteraan (FTK). Zakiah menempuh laluan penuh liku, dari tekanan kewangan, beban emosi, hingga tanggungjawab membesarkan enam anak tanpa pembantu."),
            _buildArticleText(
                "\"Saya pernah tidur dalam kereta dan mandi di hentian R&R Pagoh semata-mata mahu jimat masa dan kos ulang-alik.\""),
            _buildArticleText(
                "\"Anak-anak dijaga ibu mertua, dan saya siapkan makanan frozen untuk beberapa hari,\" ceritanya."),
            _buildArticleText(
                "Lebih menyentuh hati, Zakiah turut mengambil upah memesin rumput, termasuk kawasan seluas empat ekar, selain bekerja sambilan sebagai pensyarah, mengemas homestay dan membuat rekaan grafik untuk menampung kehidupan."),
            _buildArticleText(
                "\"Kenapa mesin rumput? Sebab itu satu-satunya kerja yang saya boleh buat waktu itu dan anehnya, bunyi mesin rumput itu menenangkan fikiran saya,\" ujarnya sambil tersenyum."),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
