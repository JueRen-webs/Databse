import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';





class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("DETAILS FOR SESSION 202420251",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 20, color: Colors.grey))
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF000080),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child: Text("FEES / SERVICES / FINES",
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11))),
                            Expanded(
                                flex: 2,
                                child: Text("CODE",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11))),
                            Expanded(
                                flex: 2,
                                child: Text("DEBIT (MYR)",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11))),
                          ],
                        ),
                      ),
                      _buildDetailRow(
                          "Tabung Aktiviti Pelajar", "E15109", "20"),
                      _buildDetailRow(
                          "Tabung Pusat Kesihatan Universiti", "E15221", "20"),
                      _buildDetailRow(
                          "Yuran Pengajian Ijazah", "H79102", "700"),
                      _buildDetailRow("Yuran Perkhidmatan ICT", "H79108", "25"),
                      _buildDetailRow("Yuran Dana Ihsan", "E15103", "10"),
                      _buildDetailRow("Tabung MHS", "E15110", "150"),
                      _buildDetailRow("Dana Wakaf Pendidikan", "E15511", "10"),
                      _buildDetailRow(
                          "Yuran Perkhidmatan UTHM", "H79107", "110"),
                      _buildDetailRow("Tabung Ko-Kurikulum", "E15104", "200"),
                      _buildDetailRow("Tabung Khidmat Pelajar", "E15106", "25"),
                      _buildDetailRow("Tabung Pusat Sukan", "E15112", "150"),
                      _buildDetailRow("Tabung Alumni", "E15108", "100"),
                      _buildDetailRow(
                          "Yuran Sijil Profesional (FSKTM)", "E80127", "125"),
                      _buildDetailRow(
                          "Bayaran Pelekat Elektrik", "H73104", "18"),
                      _buildDetailRow(
                          "Yuran Pendaftaran Ijazah", "H79105", "70"),
                      _buildDetailRow("Yuran Asrama Dalam", "H79112", "781"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String name, String code, String debit) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(name, style: GoogleFonts.inter(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text(code,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text(debit,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Finance",
            style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF000080),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: _buildHeaderText("SEMESTER/SESSION")),
                        Expanded(
                            flex: 2, child: _buildHeaderText("DEBIT\n(MYR)")),
                        Expanded(
                            flex: 2, child: _buildHeaderText("CREDIT\n(MYR)")),
                        Expanded(
                            flex: 2, child: _buildHeaderText("BALANCE\n(MYR)")),
                        Expanded(flex: 2, child: _buildHeaderText("")),
                      ],
                    ),
                  ),
                  _buildFinanceRow(
                      context, "1 / 20242025", "2514", "2514", "0", "Details"),
                  _buildFinanceRow(
                      context, "2 / 20242025", "1664", "1664", "0", "Details"),
                  _buildFinanceRow(
                      context, "1 / 20252026", "1035", "1035", "0", "Details"),
                  Container(
                    color: Colors.grey.shade200,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text("TOTAL",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text("5213",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text("5213",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text("0",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red))),
                        const Expanded(flex: 2, child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text("IMPORTANT REMINDER",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildBulletPoint("Payment can be made by ONLINE PAYMENT : ",
                linkText: kFinancePaymentLink),
            const SizedBox(height: 8),
            _buildBulletPoint(
                "Failure to do so will result in cancellation of course registration, suspension of examination results and any other actions as imposed in the Student's Payment Rules and Regulations (Pekeliling Bendahari Bil. 10/2008)"),
            const SizedBox(height: 20),
            Text("Thank you for your cooperation.",
                style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 10)
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _launchURL(kFinancePaymentLink),
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text("Make Payment Online",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
  }

  Widget _buildFinanceRow(BuildContext context, String session, String debit,
      String credit, String balance, String action) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(session,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.black))),
          Expanded(
              flex: 2,
              child: Text(debit,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11))),
          Expanded(
              flex: 2,
              child: Text(credit,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11))),
          Expanded(
              flex: 2,
              child: Text(balance,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11))),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showDetailsDialog(context),
              child: Text(action,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, {String? linkText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                  color: Colors.black, fontSize: 13, height: 1.4),
              children: [
                TextSpan(text: text),
                if (linkText != null)
                  WidgetSpan(
                    child: InkWell(
                      onTap: () => _launchURL(linkText),
                      child: Text(
                        linkText,
                        style: GoogleFonts.inter(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
