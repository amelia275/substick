import 'package:flutter/material.dart';
import 'package:substack_app/features/home/home_screen.dart';
import '../notes_detail/notes_detail_screen.dart';

void main() {
  runApp(const MaterialApp(home: MyReply()));
}

class MyReply extends StatefulWidget {
  const MyReply({super.key});

  @override
  State<MyReply> createState() => _MyReply();
}

class _MyReply extends State<MyReply> {
  final TextEditingController _replyController = TextEditingController();
  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Adjust as needed
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyWidget(),
                      ));
                },
              ),
            ),
            title: const Text(
              'Balas',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.all(Radius.circular(8)))),
                  onPressed: () {
                    String replyText = _replyController.text.trim();

                    if (replyText.isNotEmpty) {
                      // Tutup halaman reply dan kirim data teks balasan ke halaman sebelumnya
                      Navigator.pop(context, replyText);
                    }
                  },
                  child: Text('Posting'),
                ),
              )
            ]),
        body: Expanded(
            child: Padding(
          padding: EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 18,
                      child: Icon(Icons.person, size: 20, color: Colors.grey),
                      backgroundColor: Color(0xFFEAEAEA)),
                  SizedBox(
                    width: 15,
                  ),
                  Text('2Mg',
                      style: TextStyle(
                          fontWeight: FontWeight.w300, color: Colors.grey))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                    'Asap kebakaran sangat  mengganggu aktivitas berkendara, hal ini dapat berpotensi kecelakaan',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF262626),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
// Form Input Balasan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange,
                    child: Text('S',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Tinggalkan balasan...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                      width: 52), // Menyejajarkan icon dengan teks input
                  IconButton(
                    icon:
                        const Icon(Icons.image_outlined, color: Colors.black87),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.black87),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        )));
  }
}
