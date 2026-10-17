// TODO: Implement this screen/state. See README.md and docs/.
import 'package:flutter/material.dart';
 // Import file halaman tujuan


void main() {
  runApp(const MaterialApp(home: MyWidget()));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}
// 1. Fungsi penolong ditaruh di dalam kelas State (di atas Widget build)

class _MyWidgetState extends State<MyWidget> {
  // pop show modal
  void _showOptionMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
              title: const Text('Ikuti Cindira', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.white),
              title: const Text('Salin tautan', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: const Text('Blokir', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
  Widget buildHoverIcon({
    required IconData defaultIcon,
    required IconData hoveredIcon,
    required VoidCallback onPressed,
    required String label,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Column(
             mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onPressed,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: Icon(
                  isHovered ? hoveredIcon : defaultIcon,
                  color: Colors.white,
                  size: 28,
                ),
                
              ),
              Text(
              label,
              style: TextStyle(
                color: isHovered ? Colors.white : Colors.white, // Contoh: warna berubah pas di-hover
                fontSize: 12,
              )
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            //  Navigator.push(context, 
            //  MaterialPageRoute(
            //   builder: (context) => const HomeScreen(),
            //  ));
          },
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
        ),
        title: const Text(
          'Note',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Tinggi border
          child: Container(
            color: Colors.grey, // Warna border bawah AppBar
            height: 1.0, // Ketebalan garis
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                // <-- Bungkus pakai Column ini
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profil & Tombol (Row Atas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(
                              'https://wallpapers.com/images/hd/photography-nature-background-h2ifm0bbe638sw4p.jpg',
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jaian',
                                style: TextStyle(color: Colors.white),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '2Mg .',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Berlangganan',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      //   IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(
                      //     Icons.more_horiz,
                      //     color: Color.fromARGB(255, 84, 79, 79),
                      //     size: 28,
                      //   ),
                      // ),
    PopupMenuButton<String>(
  icon: const Icon(Icons.more_horiz, color: Color.fromARGB(255, 84, 79, 79),),
  color: const Color(0xFF212121), // Warna background pop-up
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // Sudut melengkung
  ),
  offset: const Offset(0, 60), // Mengatur posisi pop-up tepat di bawah tombol
  onSelected: (value) {
    // Aksi ketika salah satu menu diklik
    if (value == 'follow') {
      // Aksi ikuti
    } else if (value == 'copy') {
      // Aksi salin tautan
    } else if (value == 'block') {
      // Aksi blokir
    }
  },
  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
    const PopupMenuItem<String>(
      value: 'follow',
      child: Row(
        children: [
          Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
          SizedBox(width: 12),
          Text('Ikuti Jaian', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'copy',
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.white),
          SizedBox(width: 12),
          Text('Salin tautan', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'save',
      child: Row(
        children: [
          Icon(Icons.bookmark_border, color: Colors.white),
          SizedBox(width: 12),
          Text('Simpan', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'share',
      child: Row(
        children: [
          Icon(Icons.share_outlined, color: Colors.white),
          SizedBox(width: 12),
          Text('Bagikan', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'download',
      child: Row(
        children: [
          Icon(Icons.file_download, color: Colors.white),
          SizedBox(width: 12),
          Text('Simpan sebagai gambar', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'copy_teks',
      child: Row(
        children: [
          Icon(Icons.filter_center_focus, color: Colors.white),
          SizedBox(width: 12),
          Text('Salin teks ', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'scan_teks',
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.white),
          SizedBox(width: 12),
          Text('Simpan sebagai gambar', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'scan_teks',
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: Colors.white),
          SizedBox(width: 12),
          Text('Pindai teks AI', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'close',
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.white),
          SizedBox(width: 12),
          Text('Tampilkan lebih sedikit', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
   // Garis pemisah opsional
    const PopupMenuItem<String>(
      value: 'hide',
      child: Row(
        children: [
          Icon(Icons.speaker_notes_off_outlined, color: Colors.redAccent),
          SizedBox(width: 12),
          Text('Sembunyikan penulis', style: TextStyle(color: Colors.redAccent)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'block',
      child: Row(
        children: [
          Icon(Icons.block, color: Colors.redAccent),
          SizedBox(width: 12),
          Text('Blokir', style: TextStyle(color: Colors.redAccent)),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'report',
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 12),
          Text('Laporkan', style: TextStyle(color: Colors.redAccent)),
        ],
      ),
    ),
   
  ],
),
                    
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Column(
                    children: const [
                      Text(
                        'aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 2. Gambar Postingan (Di Bawah Profil)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://www.financialexpress.com/wp-content/uploads/2021/09/air-pollution-noida.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Color.fromARGB(255, 84, 79, 79),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsetsGeometry.fromLTRB(8, 0, 8, 0),
              child: Row(
                children: [
                  Text(
                    '5 SUKA . 2 RESTACKS',
                    style: TextStyle(
                      color: Color.fromARGB(255, 65, 62, 62),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Color.fromARGB(255, 84, 79, 79),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_outline),
                  iconSize: 30,
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  iconSize: 30,
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.loop_outlined),
                  iconSize: 30,
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  iconSize: 30,
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Color.fromARGB(255, 84, 79, 79),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          const CircleAvatar(),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'readtings',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Row(
                                children: const [
                                  Text(
                                    '3Mg .',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    ' Berlangganan',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.close),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 45),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Turut prihatin',
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(
                              Icons.favorite_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.loop_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.share_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1.0,
                          color: Color.fromARGB(255, 84, 79, 79),
                        ),
                      ),
                    ),
                  ),
  
                ],
              ),
            ),
              Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Andri',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Row(
                                children: const [
                                  Text(
                                    '4Mg .',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    ' Berlangganan',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.close),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 45),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Semoga segera membaik',
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(
                              Icons.favorite_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.loop_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.share_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1.0,
                          color: Color.fromARGB(255, 84, 79, 79),
                        ),
                      ),
                    ),
                  ),
  
                ],
              ),
            ),
             Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cynta',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Row(
                                children: const [
                                  Text(
                                    '4Mg .',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    ' Berlangganan',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.close),
                            color: const Color.fromARGB(255, 84, 79, 79),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 45),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          ':(',
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(
                              Icons.favorite_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.loop_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.share_outlined,
                              color: const Color.fromARGB(255, 84, 79, 79),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1.0,
                          color: Color.fromARGB(255, 84, 79, 79),
                        ),
                      ),
                    ),
                  ),
  
                ],
              ),
            ),
            
            
            //  Container(
            //   decoration: const BoxDecoration(
            //     border: Border(
            //       bottom: BorderSide(
            //         width: 1.0,
            //         color: Color.fromARGB(255, 84, 79, 79),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: const Border(
            top: const BorderSide(color: const Color.fromARGB(255, 84, 79, 79), width: 1.0),
          ),
        ),
        child: BottomAppBar(
          color: Colors.black,
          elevation: 0,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                  buildHoverIcon(
                    defaultIcon: Icons.home_outlined,
                    hoveredIcon: Icons.home,
                    onPressed: () {},
                    label: 'Beranda',
                  ),
                       
              // 2. Chat / Gelembung
              buildHoverIcon(
                defaultIcon: Icons.menu_book_outlined,
                hoveredIcon: Icons.chat_bubble,
                onPressed: () {},
                 label: 'Bacaan',
              ),
              buildHoverIcon(
                defaultIcon: Icons.headphones_outlined,
                hoveredIcon: Icons.chat_bubble,
                onPressed: () {},
                 label: 'Podcast',
              ),

              buildHoverIcon(
                defaultIcon: Icons.chat_bubble_outline,
                hoveredIcon: Icons.headphones,
                onPressed: () {},
                 label: 'Obrolan',
              ),

              // 4. Notification
              buildHoverIcon(
                defaultIcon: Icons.notifications_none_outlined,
                hoveredIcon: Icons.notifications,
                onPressed: () {},
                 label: 'aktivitas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
