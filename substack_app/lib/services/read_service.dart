// Simpan di: lib/services/read_service.dart
import '../core/network/api_client.dart';
import '../models/post.dart';
import '../models/read_section.dart';

/// Polanya sama dengan PostService: memakai ApiClient dan membaca
/// respons berbentuk { "data": [ ... ] }.
///
/// Bentuk respons yang diharapkan (nama endpoint ini asumsi, sesuaikan
/// dengan API tim):
///
/// GET /read?tab=for_you
/// {
///   "data": [
///     { "category": "Romansa", "posts": [ { ...sama seperti item /posts... } ] },
///     { "category": "Isu Sosial", "posts": [ ... ] }
///   ]
/// }
class ReadService {
  /// true  = pakai data dummy di bawah (API belum siap).
  /// false = ambil dari API.
  static bool useDummyData = false;

  final ApiClient _apiClient;

  ReadService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// [tab]: 'for_you' | 'latest' | 'paid' | 'saved' | 'history'
  /// (sementara hanya 'for_you' yang dipakai screen).
  Future<List<ReadSection>> fetchSections({String tab = 'for_you'}) async {
    if (useDummyData) {
      await Future.delayed(const Duration(milliseconds: 600)); // simulasi loading
      return _dummySections;
    }

    final result = await _apiClient.get('/read?tab=$tab');

    if (result is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai');
    }

    final data = result['data'];

    if (data is! List) {
      throw Exception('Data bacaan tidak ditemukan');
    }

    return data.map((item) {
      if (item is! Map) {
        throw Exception('Format data section tidak sesuai');
      }

      return ReadSection.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

// ───────────────────────── Data dummy ─────────────────────────
// Hapus bagian ini kalau API sudah dipakai.

/// Baris pertama = kutipan, sisanya pengisi supaya perkiraan waktu baca
/// (dihitung dari jumlah kata) bervariasi.
String _body(String intro, int minutes) =>
    '$intro\n${List.filled(minutes * 200, 'isi').join(' ')}';

final List<ReadSection> _dummySections = [
  ReadSection(title: 'Romansa', posts: [
    Post(
        id: 1,
        userId: 1,
        type: 'article',
        title: 'Semoga Aku Menjadi Panasea',
        content: _body('Semoga aku menjadi obat bagi luka-lukamu, meski aku sendiri belum sembuh.', 3),
        authorName: 'Ansa Modry',
        likesCount: 12800,
        commentsCount: 55,
        publishedAt: DateTime(2026, 9, 10)),
    Post(
        id: 2,
        userId: 2,
        type: 'article',
        title: 'Boleh tidak aku memintamu mencintaiku dengan cara yang paling berisik?',
        content: _body('Sebab, diriku sepi sekali, dan aku ingin kamu tahu bahwa aku ada.', 6),
        authorName: 'Rainthalogy',
        likesCount: 20100,
        commentsCount: 164,
        publishedAt: DateTime(2026, 9, 20)),
    Post(
        id: 3,
        userId: 3,
        type: 'article',
        title: 'Panasea',
        content: _body('Sebuah tulisan pendek tentang menyembuhkan dan disembuhkan.', 2),
        authorName: 'him',
        likesCount: 6400,
        commentsCount: 66,
        publishedAt: DateTime(2026, 9, 5)),
    Post(
        id: 4,
        userId: 4,
        type: 'article',
        title: 'Judul Artikel Romansa',
        content: _body('Contoh isi artikel romansa untuk keperluan tampilan.', 4),
        authorName: 'nabila putri',
        likesCount: 19900,
        commentsCount: 143,
        publishedAt: DateTime(2026, 9, 1)),
    Post(
        id: 5,
        userId: 5,
        type: 'article',
        title: 'Judul Artikel Romansa 2',
        content: _body('Contoh isi artikel romansa kedua untuk keperluan tampilan.', 3),
        authorName: 'senyap kalbu',
        likesCount: 40700,
        commentsCount: 98,
        publishedAt: DateTime(2026, 8, 28)),
  ]),
  ReadSection(title: 'Pengembangan diri', posts: [
    Post(
        id: 6,
        userId: 6,
        type: 'article',
        title: 'Untuk Jiwa-Jiwa yang Sedang Lelah Berjalan',
        content: _body('Tidak apa-apa berhenti sebentar, karena perjalanan ini memang panjang.', 3),
        authorName: 'dear.ann',
        likesCount: 12411,
        commentsCount: 307,
        publishedAt: DateTime(2026, 9, 14)),
    Post(
        id: 7,
        userId: 7,
        type: 'article',
        title: 'Kita Ternyata Tidak Sepenting Itu di Kehidupan Orang Lain',
        content: _body(
            'Mungkin salah satu hal yang paling sulit kita terima tentang hubungan dengan orang lain adalah ini.',
            5),
        authorName: 'cinas',
        likesCount: 6736,
        commentsCount: 39,
        publishedAt: DateTime(2026, 9, 24)),
    Post(
        id: 8,
        userId: 8,
        type: 'article',
        title: 'Bukankah Kita Juga Pertama Kali Menjadi Anak?',
        content: _body(
            'Aku pikir tidak semua hal yang kita bawa dari masa kecil selalu buruk, tetapi tidak berarti jujur.',
            4),
        authorName: 'Gita F Nisa',
        likesCount: 31306,
        commentsCount: 80,
        publishedAt: DateTime(2026, 8, 15)),
  ]),
  ReadSection(title: 'Kesehatan mental', posts: [
    // post pertama di section ini tampil sebagai kartu besar
    Post(
        id: 9,
        userId: 9,
        type: 'article',
        title: 'Kamu Hanya Ada Satu di Dunia, jadi Jangan Hilang',
        content: _body(
            'Tubuh yang selalu kamu panggil sebagai etalase kegagalan, bagiku adalah museum dari semua hal yang pernah kamu lewati.',
            6),
        publicationName: 'Biba Bercerita',
        likesCount: 44300,
        commentsCount: 1400,
        publishedAt: DateTime(2026, 8, 29)),
    Post(
        id: 10,
        userId: 2,
        type: 'article',
        title: 'Boleh tidak aku memintamu mencintaiku dengan cara yang paling berisik? Sebab, diriku sepi sekali, Sa...',
        content: _body('Sebab, diriku sepi sekali, dan aku ingin kamu tahu bahwa aku ada.', 6),
        authorName: 'Rainthalogy',
        likesCount: 20127,
        commentsCount: 164,
        publishedAt: DateTime(2026, 9, 20)),
    Post(
        id: 11,
        userId: 11,
        type: 'article',
        title: 'Being a Hopeless Romantic,',
        content: _body('Catatan kecil tentang percaya pada hal-hal yang manis.', 2),
        authorName: 'kiaa',
        likesCount: 13791,
        commentsCount: 66,
        publishedAt: DateTime(2026, 9, 25)),
  ]),
  ReadSection(title: 'Iman & Spiritualitas', posts: [
    Post(
        id: 12,
        userId: 12,
        type: 'article',
        title: 'Mungkin Kita Tidak Tertinggal, Hanya Berjalan Pelan',
        content: _body('Setiap orang punya waktunya sendiri untuk sampai.', 3),
        publicationName: 'The Serene Pages',
        likesCount: 10000,
        commentsCount: 67,
        publishedAt: DateTime(2026, 9, 2)),
    Post(
        id: 13,
        userId: 13,
        type: 'article',
        title: 'pertemukan kami sekali saja, ah bukan, berkali-kali',
        content: _body('Doa yang ditulis ulang setiap malam.', 2),
        authorName: 'margaret',
        likesCount: 9000,
        commentsCount: 92,
        publishedAt: DateTime(2026, 9, 3)),
    Post(
        id: 14,
        userId: 14,
        type: 'article',
        title: 'kumohon mudahkanlah segalanya',
        content: _body('Sebuah permohonan sederhana di penghujung hari.', 2),
        authorName: 'lettersfromjing',
        likesCount: 7000,
        commentsCount: 119,
        publishedAt: DateTime(2026, 9, 4)),
  ]),
  ReadSection(title: 'Isu Sosial', posts: [
    Post(
        id: 15,
        userId: 15,
        type: 'article',
        title: 'Kalau Perempuan Dipanggil Jalang, Lalu Laki-Laki Disebut Apa?',
        content: _body(
            'Coba sebutkan semua panggilan buruk untuk perempuan. Aku yakin akan mudah sekali untuk mendaftarnya.',
            5),
        authorName: 'Halo Serayu',
        likesCount: 55463,
        commentsCount: 127,
        publishedAt: DateTime(2026, 9, 14)),
    Post(
        id: 16,
        userId: 16,
        type: 'article',
        title: 'Nak, Suatu Hari Nanti, Kamu Akan Tahu bahwa Mimpi Juga Punya Harga.',
        content: _body('Surat untuk anak yang kelak tumbuh dewasa.', 5),
        authorName: 'noa',
        likesCount: 29984,
        commentsCount: 296,
        publishedAt: DateTime(2026, 8, 27)),
  ]),
];