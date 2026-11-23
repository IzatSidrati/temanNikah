import '../models/wedding_info.dart';
import '../models/checklist_item.dart';
import '../models/expense_item.dart';
import '../models/guest_item.dart';
import '../models/vendor_item.dart';
import '../models/rundown_item.dart';

class DefaultData {
  static WeddingInfo get weddingInfo {
    return WeddingInfo(
      groomName: 'Rian Pratama',
      brideName: 'Sarah Amanda',
      weddingDate: DateTime.now().add(const Duration(days: 150)),
      weddingLocation: 'Grand Ballroom Hotel Mulia, Jakarta',
      totalBudget: 180000000.0,
      notes: 'Pernikahan impian bertema Modern Rustic dengan nuansa Rose Gold & White.',
    );
  }

  static List<ChecklistItem> get checklistItems {
    return [
      // H-12 Bulan
      ChecklistItem(
        id: 'cl-1',
        title: 'Tentukan tanggal dan konsep pernikahan bersama keluarga besar',
        category: 'H-12 Bulan',
        isDone: true,
        pic: 'Rian & Sarah',
      ),
      ChecklistItem(
        id: 'cl-2',
        title: 'Tentukan alokasi anggaran total dan sumber dana',
        category: 'H-12 Bulan',
        isDone: true,
        pic: 'Rian & Sarah',
      ),
      ChecklistItem(
        id: 'cl-3',
        title: 'Survei dan booking venue (gedung/outdoor) & tanggal ketersediaan',
        category: 'H-12 Bulan',
        isDone: true,
        pic: 'Rian',
      ),

      // H-6 Bulan
      ChecklistItem(
        id: 'cl-4',
        title: 'Pilih vendor katering dan jadwalkan food tasting',
        category: 'H-6 Bulan',
        isDone: true,
        pic: 'Sarah & Ibu',
      ),
      ChecklistItem(
        id: 'cl-5',
        title: 'Booking vendor foto & video (prewedding & hari H)',
        category: 'H-6 Bulan',
        isDone: false,
        pic: 'Rian',
      ),
      ChecklistItem(
        id: 'cl-6',
        title: 'Pilih MUA (rias wajah), desainer gaun, dan jas pengantin',
        category: 'H-6 Bulan',
        isDone: false,
        pic: 'Sarah',
      ),
      ChecklistItem(
        id: 'cl-7',
        title: 'Sesi foto dan video prewedding',
        category: 'H-6 Bulan',
        isDone: false,
        pic: 'Vendor Foto',
      ),

      // H-3 Bulan
      ChecklistItem(
        id: 'cl-8',
        title: 'Urus berkas administrasi nikah di KUA / Catatan Sipil',
        category: 'H-3 Bulan',
        isDone: false,
        pic: 'Rian',
      ),
      ChecklistItem(
        id: 'cl-9',
        title: 'Pesan cincin kawin dan ukir nama pasangan',
        category: 'H-3 Bulan',
        isDone: false,
        pic: 'Rian & Sarah',
      ),
      ChecklistItem(
        id: 'cl-10',
        title: 'Finalisasi daftar tamu dan desain kartu undangan & souvenir',
        category: 'H-3 Bulan',
        isDone: false,
        pic: 'Sarah',
      ),
      ChecklistItem(
        id: 'cl-11',
        title: 'Beli bahan dan jahit seragam keluarga & bridesmaid/groomsmen',
        category: 'H-3 Bulan',
        isDone: false,
        pic: 'Keluarga',
      ),

      // H-1 Bulan
      ChecklistItem(
        id: 'cl-12',
        title: 'Fitting baju pengantin tahap akhir (final fitting)',
        category: 'H-1 Bulan',
        isDone: false,
        pic: 'Sarah & Rian',
      ),
      ChecklistItem(
        id: 'cl-13',
        title: 'Kirim undangan fisik dan sebar undangan digital (web/wa)',
        category: 'H-1 Bulan',
        isDone: false,
        pic: 'Tim Undangan',
      ),
      ChecklistItem(
        id: 'cl-14',
        title: 'Pelunasan pembayaran seluruh vendor',
        category: 'H-1 Bulan',
        isDone: false,
        pic: 'Rian',
      ),
      ChecklistItem(
        id: 'cl-15',
        title: 'Susun rundown acara detail dan bagikan ke keluarga & WO',
        category: 'H-1 Bulan',
        isDone: false,
        pic: 'WO / PIC Acara',
      ),

      // H-1 Minggu
      ChecklistItem(
        id: 'cl-16',
        title: 'Technical meeting seluruh vendor dan panitia keluarga',
        category: 'H-1 Minggu',
        isDone: false,
        pic: 'Wedding Organizer',
      ),
      ChecklistItem(
        id: 'cl-17',
        title: 'Siapkan mahar, mas kawin, dan seserahan yang sudah dihias rapi',
        category: 'H-1 Minggu',
        isDone: false,
        pic: 'Rian & Keluarga',
      ),
      ChecklistItem(
        id: 'cl-18',
        title: 'Perawatan diri pengantin (spa, lulur, istirahat cukup)',
        category: 'H-1 Minggu',
        isDone: false,
        pic: 'Rian & Sarah',
      ),

      // Hari H
      ChecklistItem(
        id: 'cl-19',
        title: 'Sarapan bergizi dan minum air putih yang cukup',
        category: 'Hari H',
        isDone: false,
        pic: 'Pengantin',
      ),
      ChecklistItem(
        id: 'cl-20',
        title: 'Serahkan segala urusan teknis ke WO dan nikmati hari bahagia!',
        category: 'Hari H',
        isDone: false,
        pic: 'Semua',
      ),
    ];
  }

  static List<ExpenseItem> get expenses {
    return [
      ExpenseItem(
        id: 'exp-1',
        title: 'Sewa Gedung / Ballroom',
        category: 'Venue & Dekorasi',
        estimatedCost: 45000000,
        actualCost: 45000000,
        paidAmount: 45000000,
        status: PaymentStatus.paid,
        notes: 'Termasuk fasilitas sound system standard & ruang rias.',
      ),
      ExpenseItem(
        id: 'exp-2',
        title: 'Dekorasi Pelaminan & Ruangan',
        category: 'Venue & Dekorasi',
        estimatedCost: 28000000,
        actualCost: 30000000,
        paidAmount: 15000000,
        status: PaymentStatus.downPayment,
        notes: 'DP 50% sudah dibayar. Pelunasan H-14.',
      ),
      ExpenseItem(
        id: 'exp-3',
        title: 'Katering Paket 600 Porsi + Stall',
        category: 'Katering',
        estimatedCost: 55000000,
        actualCost: 52000000,
        paidAmount: 26000000,
        status: PaymentStatus.downPayment,
        notes: 'Menu buffet nusantara + 4 food stalls favorit.',
      ),
      ExpenseItem(
        id: 'exp-4',
        title: 'Gaun Pengantin, Jas, & MUA Hari H',
        category: 'Busana & MUA',
        estimatedCost: 18000000,
        actualCost: 17500000,
        paidAmount: 8500000,
        status: PaymentStatus.downPayment,
        notes: 'Termasuk rias ibu kedua mempelai.',
      ),
      ExpenseItem(
        id: 'exp-5',
        title: 'Dokumentasi Foto & Video Cinematic',
        category: 'Foto & Video',
        estimatedCost: 14000000,
        actualCost: 13500000,
        paidAmount: 5000000,
        status: PaymentStatus.downPayment,
        notes: 'Prewed outdoor + Liputan akad & resepsi (2 fotografer, 2 videografer).',
      ),
      ExpenseItem(
        id: 'exp-6',
        title: 'Cincin Kawin & Kotak Cincin',
        category: 'Mahar & Seserahan',
        estimatedCost: 9000000,
        actualCost: 9200000,
        paidAmount: 9200000,
        status: PaymentStatus.paid,
        notes: 'Emas putih 75% grafir nama.',
      ),
      ExpenseItem(
        id: 'exp-7',
        title: 'Undangan Digital & 200 Cetak Fisik',
        category: 'Undangan & Souvenir',
        estimatedCost: 4500000,
        actualCost: 4000000,
        paidAmount: 0,
        status: PaymentStatus.unpaid,
        notes: 'Desain sedang proses review proofing.',
      ),
      ExpenseItem(
        id: 'exp-8',
        title: 'Souvenir Pouch Elegan (300 pcs)',
        category: 'Undangan & Souvenir',
        estimatedCost: 3500000,
        actualCost: 3500000,
        paidAmount: 1750000,
        status: PaymentStatus.downPayment,
        notes: 'DP 50% lunas.',
      ),
      ExpenseItem(
        id: 'exp-9',
        title: 'Wedding Organizer (Hari H - 6 Kru)',
        category: 'Lainnya',
        estimatedCost: 7000000,
        actualCost: 7000000,
        paidAmount: 3500000,
        status: PaymentStatus.downPayment,
        notes: 'Koordinasi vendor & rundown mulai H-1 bulan.',
      ),
    ];
  }

  static List<GuestItem> get guests {
    return [
      GuestItem(
        id: 'gst-1',
        name: 'Om Budi & Tante Maya',
        category: 'Keluarga Pria',
        pax: 2,
        isInvitationSent: true,
        rsvpStatus: RsvpStatus.attending,
        tableNumber: 'Meja VIP 1',
        phoneNumber: '081234567890',
      ),
      GuestItem(
        id: 'gst-2',
        name: 'Keluarga Besar dr. Handoko',
        category: 'Keluarga Wanita',
        pax: 4,
        isInvitationSent: true,
        rsvpStatus: RsvpStatus.attending,
        tableNumber: 'Meja VIP 2',
      ),
      GuestItem(
        id: 'gst-3',
        name: 'Dimas Aditya (Bestman)',
        category: 'Teman Pria',
        pax: 2,
        isInvitationSent: true,
        rsvpStatus: RsvpStatus.attending,
        tableNumber: 'Meja 5',
        phoneNumber: '081987654321',
      ),
      GuestItem(
        id: 'gst-4',
        name: 'Nadira & Pasangan (Bridesmaid)',
        category: 'Teman Wanita',
        pax: 2,
        isInvitationSent: true,
        rsvpStatus: RsvpStatus.attending,
        tableNumber: 'Meja 5',
      ),
      GuestItem(
        id: 'gst-5',
        name: 'Tim Engineering Google / Kantor',
        category: 'Rekan Kerja',
        pax: 8,
        isInvitationSent: true,
        rsvpStatus: RsvpStatus.tentative,
        tableNumber: 'Meja 8',
      ),
      GuestItem(
        id: 'gst-6',
        name: 'Pak RT Hendra & Ibu',
        category: 'Tetangga',
        pax: 2,
        isInvitationSent: false,
        rsvpStatus: RsvpStatus.pending,
        tableNumber: 'Meja 10',
      ),
    ];
  }

  static List<VendorItem> get vendors {
    return [
      VendorItem(
        id: 'vnd-1',
        name: 'Grand Ballroom Hotel Mulia',
        category: 'Venue',
        contactPerson: 'Ibu Ratna',
        phone: '08111222333',
        cost: 45000000,
        status: 'Lunas',
        notes: 'PIC venue sangat responsif, ruang rias 2 kamar siap jam 05.00.',
      ),
      VendorItem(
        id: 'vnd-2',
        name: 'Al-Hana Catering & Service',
        category: 'Katering',
        contactPerson: 'Pak Danang',
        phone: '08122334455',
        cost: 52000000,
        status: 'Booking (DP)',
        notes: 'Tes food memuaskan. Free bonus dessert corner 100 porsi.',
      ),
      VendorItem(
        id: 'vnd-3',
        name: 'Rosewood Atelier Decoration',
        category: 'Dekorasi',
        contactPerson: 'Mba Cindy',
        phone: '08133445566',
        instagram: '@rosewood.decor',
        cost: 30000000,
        status: 'Booking (DP)',
        notes: 'Tema rustic warm rose gold, backdrop pelaminan 10 meter.',
      ),
      VendorItem(
        id: 'vnd-4',
        name: 'Lensa Cinta Photography',
        category: 'Dokumentasi',
        contactPerson: 'Mas Fajar',
        phone: '08144556677',
        instagram: '@lensacinta.id',
        cost: 13500000,
        status: 'Booking (DP)',
        notes: 'Prewed selesai, hasil foto sangat estetik dan memuaskan.',
      ),
    ];
  }

  static List<RundownItem> get rundowns {
    return [
      RundownItem(
        id: 'rd-1',
        eventType: 'Akad / Pemberkatan',
        timeRange: '05:30 - 07:00',
        activity: 'Make Up & Persiapan Busana Pengantin dan Orang Tua',
        pic: 'MUA & Bridesmaid',
        location: 'Ruang Rias Pengantin',
        notes: 'Pastikan sarapan sudah selesai sebelum rias dimulai.',
      ),
      RundownItem(
        id: 'rd-2',
        eventType: 'Akad / Pemberkatan',
        timeRange: '07:30 - 08:00',
        activity: 'Penyambutan Rombongan Keluarga Calon Pengantin Pria',
        pic: 'WO & Perwakilan Keluarga',
        location: 'Pintu Masuk Utama',
        notes: 'Pengalungan bunga melati kepada mempelai pria.',
      ),
      RundownItem(
        id: 'rd-3',
        eventType: 'Akad / Pemberkatan',
        timeRange: '08:00 - 09:15',
        activity: 'Prosesi Ijab Qabul & Pembacaan Doa',
        pic: 'Penghulu KUA & Saksi',
        location: 'Meja Akad Pelaminan',
        notes: 'Siapkan mas kawin, buku nikah, dan pulpen tandatangan.',
      ),
      RundownItem(
        id: 'rd-4',
        eventType: 'Akad / Pemberkatan',
        timeRange: '09:15 - 10:00',
        activity: 'Sesi Sungkeman Orang Tua & Foto Keluarga Inti',
        pic: 'MC & Fotografer',
        location: 'Pelaminan',
        notes: 'Sediakan tisu untuk pengantin & orang tua.',
      ),
      RundownItem(
        id: 'rd-5',
        eventType: 'Resepsi',
        timeRange: '10:00 - 11:00',
        activity: 'Retouch Make Up & Ganti Busana Resepsi',
        pic: 'MUA & WO',
        location: 'Ruang Rias',
        notes: 'Tim catering mulai menata buffet dan live food stalls.',
      ),
      RundownItem(
        id: 'rd-6',
        eventType: 'Resepsi',
        timeRange: '11:00 - 11:30',
        activity: 'Grand Entrance Pengantin & Sambutan Keluarga',
        pic: 'MC & Music Band',
        location: 'Ballroom',
        notes: 'Lagu pengiring: A Thousand Years (Acoustic).',
      ),
      RundownItem(
        id: 'rd-7',
        eventType: 'Resepsi',
        timeRange: '11:30 - 13:30',
        activity: 'Ramah Tamah, Makan Siang, & Foto Bersama Tamu Undangan',
        pic: 'WO & Petugas Foto',
        location: 'Pelaminan & Area Ballroom',
        notes: 'Prioritaskan tamu lansia dan VIP untuk sesi foto.',
      ),
      RundownItem(
        id: 'rd-8',
        eventType: 'Resepsi',
        timeRange: '13:30 - 14:00',
        activity: 'Lempar Handbouquet, Doorprize, & Penutupan Acara',
        pic: 'MC & WO',
        location: 'Area Depan Panggung',
        notes: 'Foto tim WO, vendor, dan kedua pengantin.',
      ),
    ];
  }
}
