import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(80); // Tinggi header (py-4 approx)

  @override
  Widget build(BuildContext context) {
    // Definisi warna (sesuaikan dengan config tailwind Anda)
    const Color sbBlue = Color(0xFF1E40AF); // text-sb-blue
    const Color sbOrange = Color(0xFFF97316); // text-sb-orange

    // ClipRect diperlukan agar efek blur tidak "bocor" ke luar area header
    return ClipRect(
      child: BackdropFilter(
        // Efek backdrop-blur-md (sigmaX/Y 10 setara medium blur)
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ), // px-6 py-4
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // bg-white/80
            border: Border(
              bottom: BorderSide(
                color: Colors.grey
                    .shade200, // border-gray-100 (shade200 lebih terlihat di mobile)
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            // Penting agar tidak tertutup status bar HP
            bottom: false,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // justify-between
              children: [
                // --- KIRI: Teks Sapaan & Logo ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // RichText untuk "SB" (Biru) dan "POS" (Oranye)
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20, // text-xl
                          fontWeight: FontWeight.bold, // font-bold
                          letterSpacing: -0.5, // tracking-tight
                          fontFamily: 'Roboto', // Sesuaikan font default Anda
                        ),
                        children: [
                          TextSpan(
                            text: 'SB',
                            style: TextStyle(color: sbBlue),
                          ),
                          TextSpan(
                            text: 'POS',
                            style: TextStyle(color: sbOrange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // --- KANAN: Icon Bell dengan Badge ---
                InkWell(
                  onTap: () {
                    print("Notifikasi diklik");
                  },
                  borderRadius: BorderRadius.circular(50), // rounded-full
                  child: Container(
                    padding: const EdgeInsets.all(8), // p-2
                    // hover:bg-gray-100 (di mobile pakai InkWell ripple effect)
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined, // Bell icon
                          size:
                              24, // size={20} di web agak kecil, 24 standar mobile
                          color: Color(0xFF4B5563), // text-gray-600
                        ),
                        // Badge Merah (absolute top-2 right-2.5)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 8, // w-2
                            height: 8, // h-2
                            decoration: BoxDecoration(
                              color: Colors.red, // bg-red-500
                              shape: BoxShape.circle, // rounded-full
                              border: Border.all(
                                color: Colors.white, // border-white
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
