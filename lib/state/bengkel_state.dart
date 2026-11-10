import 'package:flutter/material.dart';
import '../models/models.dart';

class BengkelState extends ChangeNotifier {
  // Current user & authentication
  UserProfile? _currentUser;
  bool _isLoggedIn = false; // start with welcome & login screen

  // Workshop info
  bool _isWorkshopOpen = true;
  final String workshopName = 'Revora Garage';
  final String workshopAddress = 'Jl. Minggir No. 21, Sleman, Yogyakarta';
  final String workshopHours =
      'Sen–Jum 08.00–17.00 · Sab 08.00–15.00 · Min tutup';
  final String bcaAccountNumber = '1234 5678 90';
  final String bcaAccountName = 'Revora Garage';
  final String workshopPhone = '0812 3456 7890';

  // Services
  final List<ServiceItem> _services = [
    ServiceItem(
      id: 'srv-1',
      name: 'Servis rutin',
      durationMinutes: 45,
      price: 75000,
      description: 'Pengecekan standar, busi, filter udara, dan kelistrikan.',
    ),
    ServiceItem(
      id: 'srv-2',
      name: 'Ganti oli',
      durationMinutes: 20,
      price: 55000,
      description: 'Kuras dan ganti oli mesin berkualitas tinggi.',
    ),
    ServiceItem(
      id: 'srv-3',
      name: 'Servis CVT',
      durationMinutes: 60,
      price: 120000,
      description: 'Pembersihan pulley, v-belt, roller, dan pelumasan grease.',
    ),
    ServiceItem(
      id: 'srv-4',
      name: 'Ganti ban',
      durationMinutes: 30,
      price: 40000,
      description: 'Jasa pasang dan balancing ban depan atau belakang.',
    ),
    ServiceItem(
      id: 'srv-5',
      name: 'Tune up',
      durationMinutes: 60,
      price: 100000,
      description: 'Kalibrasi throttle body, injeksi, dan stel klep presisi.',
    ),
  ];

  // Mechanics
  final List<Mechanic> _mechanics = [
    Mechanic(id: 'mec-1', name: 'Devanda', avatarInitial: 'D', isActive: true),
    Mechanic(id: 'mec-2', name: 'Yodha', avatarInitial: 'Y', isActive: true),
    Mechanic(id: 'mec-3', name: 'Cakra', avatarInitial: 'C', isActive: true),
  ];

  // Bookings
  final List<Booking> _bookings = [];

  // Active booking draft (wizard)
  ServiceItem? draftService;
  DateTime? draftDate;
  String? draftTimeSlot;
  Mechanic? draftMechanic;
  PaymentMethod draftPaymentMethod = PaymentMethod.transfer;
  Booking? latestConfirmedBooking;

  BengkelState() {
    _initDefaultData();
  }

  void _initDefaultData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final past1 = today.subtract(const Duration(days: 23));
    final past2 = today.subtract(const Duration(days: 47));

    // Default user is Budi Santoso
    _currentUser = UserProfile(
      id: 'usr-budi',
      name: 'Budi Santoso',
      phone: '0812 3456 7890',
      role: UserRole.customer,
      motorcycle: Motorcycle(
        brandAndModel: 'Honda Beat',
        plateNumber: 'AB 1234 XY',
        year: '2020',
      ),
    );

    // Initial bookings matching wireframe
    _bookings.addAll([
      Booking(
        id: 'bk-1',
        code: 'BK-2100',
        customerName: 'Rudi H.',
        customerPhone: '0819 8888 7777',
        motorcycle: Motorcycle(
          brandAndModel: 'NMAX',
          plateNumber: 'AB 2210 KL',
          year: '2021',
        ),
        service: _services[2], // Servis CVT
        date: today,
        timeSlot: '13.00',
        mechanic: _mechanics[0], // Devanda
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.belumDibayar,
        status: BookingStatus.menunggu,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Booking(
        id: 'bk-2',
        code: 'BK-2099',
        customerName: 'Budi Santoso',
        customerPhone: '0812 3456 7890',
        motorcycle: _currentUser!.motorcycle!,
        service: _services[0], // Servis rutin
        date: tomorrow,
        timeSlot: '09.00',
        mechanic: _mechanics[0], // Devanda
        paymentMethod: PaymentMethod.transfer,
        paymentStatus: PaymentStatus.belumDibayar,
        status: BookingStatus.diterima,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Booking(
        id: 'bk-3',
        code: 'BK-2084',
        customerName: 'Budi Santoso',
        customerPhone: '0812 3456 7890',
        motorcycle: _currentUser!.motorcycle!,
        service: _services[1], // Ganti oli
        date: past1,
        timeSlot: '09.00',
        mechanic: _mechanics[1], // Yodha
        paymentMethod: PaymentMethod.transfer,
        paymentStatus: PaymentStatus.lunas,
        status: BookingStatus.selesai,
        createdAt: past1,
      ),
      Booking(
        id: 'bk-4',
        code: 'BK-2083',
        customerName: 'Budi Santoso',
        customerPhone: '0812 3456 7890',
        motorcycle: _currentUser!.motorcycle!,
        service: _services[0], // Servis rutin
        date: past2,
        timeSlot: '10.00',
        mechanic: _mechanics[0], // Devanda
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.lunas,
        status: BookingStatus.selesai,
        createdAt: past2,
      ),
    ]);
  }

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isWorkshopOpen => _isWorkshopOpen;
  bool get isOwner => _currentUser?.role == UserRole.owner;
  List<ServiceItem> get services => List.unmodifiable(_services);
  List<Mechanic> get mechanics => List.unmodifiable(_mechanics);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  int get activeMechanicsCount =>
      _mechanics.where((m) => m.isActive).length;

  // Customer Bookings
  Booking? get nextCustomerBooking {
    if (_currentUser == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      return _bookings.firstWhere((b) =>
          b.customerPhone == _currentUser!.phone &&
          (b.status == BookingStatus.diterima ||
              b.status == BookingStatus.menunggu ||
              b.status == BookingStatus.dikerjakan) &&
          !b.date.isBefore(today));
    } catch (_) {
      return null;
    }
  }

  List<Booking> get customerHistory {
    if (_currentUser == null) return [];
    return _bookings
        .where((b) => b.customerPhone == _currentUser!.phone)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Booking> get customerRecentHistory {
    return customerHistory
        .where((b) => b.status == BookingStatus.selesai)
        .take(2)
        .toList();
  }

  // Owner stats & queries
  List<Booking> get pendingOwnerBookings =>
      _bookings.where((b) => b.status == BookingStatus.menunggu).toList();

  List<Booking> get todayBookings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _bookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      return bDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<Booking> get tomorrowBookings {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    return _bookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      return bDate.isAtSameMomentAs(tomorrow);
    }).toList();
  }

  int get todayCompletedCount => todayBookings
      .where((b) => b.status == BookingStatus.selesai)
      .length;

  int get todayInProgressCount => todayBookings
      .where((b) => b.status == BookingStatus.dikerjakan)
      .length;

  int get todayTotalRevenue {
    int total = 0;
    for (var b in todayBookings) {
      if (b.status == BookingStatus.selesai ||
          b.paymentStatus == PaymentStatus.lunas) {
        total += b.service.price;
      }
    }
    return total > 0 ? total : 55000;
  }

  // Slot calculations
  static const List<String> availableHours = [
    '08.00',
    '09.00',
    '10.00',
    '11.00',
    '13.00',
    '14.00',
    '15.00',
    '16.00',
  ];

  int getRemainingSlots(DateTime date, String hour) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final bookedCount = _bookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      return bDate.isAtSameMomentAs(targetDate) &&
          b.timeSlot == hour &&
          b.status != BookingStatus.ditolak &&
          b.status != BookingStatus.dibatalkan;
    }).length;

    final remaining = activeMechanicsCount - bookedCount;
    return remaining < 0 ? 0 : remaining;
  }

  bool isMechanicBusy(Mechanic mechanic, DateTime date, String hour) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _bookings.any((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      return bDate.isAtSameMomentAs(targetDate) &&
          b.timeSlot == hour &&
          b.mechanic.id == mechanic.id &&
          b.status != BookingStatus.ditolak &&
          b.status != BookingStatus.dibatalkan;
    });
  }

  // Authentication & Mode Switching
  void loginWithPhone(String name, String phone) {
    final isOwnerNumber = phone.replaceAll(RegExp(r'\s+'), '') == '081111111111';
    _currentUser = UserProfile(
      id: isOwnerNumber ? 'usr-owner' : 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? (isOwnerNumber ? 'Pemilik Bengkel' : 'Budi Santoso') : name,
      phone: phone,
      role: isOwnerNumber ? UserRole.owner : UserRole.customer,
      motorcycle: isOwnerNumber
          ? null
          : (_currentUser?.motorcycle ??
              Motorcycle(
                brandAndModel: 'Honda Beat',
                plateNumber: 'AB 1234 XY',
                year: '2020',
              )),
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void registerCustomer({
    required String name,
    required String phone,
    required Motorcycle motorcycle,
  }) {
    _currentUser = UserProfile(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Budi Santoso' : name.trim(),
      phone: phone.trim().isEmpty ? '0812 3456 7890' : phone.trim(),
      role: UserRole.customer,
      motorcycle: motorcycle,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsCustomerDemo() {
    loginWithPhone('Budi Santoso', '0812 3456 7890');
  }

  void loginAsOwnerDemo() {
    loginWithPhone('Revora Owner', '0811 1111 1111');
  }

  void switchRole(UserRole newRole) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      role: newRole,
      motorcycle: newRole == UserRole.customer
          ? (_currentUser!.motorcycle ??
              Motorcycle(
                brandAndModel: 'Honda Beat',
                plateNumber: 'AB 1234 XY',
                year: '2020',
              ))
          : null,
    );
    notifyListeners();
  }

  void updateMotorcycle(Motorcycle motor) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(motorcycle: motor);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Booking Wizard flow
  void resetDraft() {
    draftService = _services.isNotEmpty ? _services[0] : null;
    final now = DateTime.now();
    draftDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    draftTimeSlot = '09.00';
    draftMechanic = _mechanics.isNotEmpty ? _mechanics[0] : null;
    draftPaymentMethod = PaymentMethod.transfer;
    notifyListeners();
  }

  Booking confirmBookingDraft() {
    if (_currentUser == null ||
        draftService == null ||
        draftDate == null ||
        draftTimeSlot == null ||
        draftMechanic == null) {
      throw Exception('Data booking belum lengkap');
    }

    final codeNumber = 2100 + _bookings.length;
    final newBooking = Booking(
      id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
      code: 'BK-$codeNumber',
      customerName: _currentUser!.name,
      customerPhone: _currentUser!.phone,
      motorcycle: _currentUser!.motorcycle ??
          Motorcycle(
            brandAndModel: 'Honda Beat',
            plateNumber: 'AB 1234 XY',
            year: '2020',
          ),
      service: draftService!,
      date: draftDate!,
      timeSlot: draftTimeSlot!,
      mechanic: draftMechanic!,
      paymentMethod: draftPaymentMethod,
      paymentStatus: PaymentStatus.belumDibayar,
      status: BookingStatus.menunggu,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, newBooking);
    latestConfirmedBooking = newBooking;
    notifyListeners();
    return newBooking;
  }

  // Status transitions
  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] =
          _bookings[index].copyWith(status: BookingStatus.dibatalkan);
      notifyListeners();
    }
  }

  void acceptBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] =
          _bookings[index].copyWith(status: BookingStatus.diterima);
      notifyListeners();
    }
  }

  void rejectBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] =
          _bookings[index].copyWith(status: BookingStatus.ditolak);
      notifyListeners();
    }
  }

  void startService(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] =
          _bookings[index].copyWith(status: BookingStatus.dikerjakan);
      notifyListeners();
    }
  }

  void completeService(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.selesai,
        paymentStatus: PaymentStatus.lunas,
      );
      notifyListeners();
    }
  }

  void markAsPaid(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      _bookings[index] =
          _bookings[index].copyWith(paymentStatus: PaymentStatus.lunas);
      notifyListeners();
    }
  }

  // Workshop management
  void toggleWorkshopOpen() {
    _isWorkshopOpen = !_isWorkshopOpen;
    notifyListeners();
  }

  void toggleMechanicActive(String id) {
    final index = _mechanics.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _mechanics[index] = _mechanics[index]
          .copyWith(isActive: !_mechanics[index].isActive);
      notifyListeners();
    }
  }

  void addService({
    required String name,
    required int price,
    required int durationMinutes,
    required String description,
  }) {
    final newService = ServiceItem(
      id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      durationMinutes: durationMinutes,
      price: price,
      description: description,
    );
    _services.add(newService);
    notifyListeners();
  }

  void updateService({
    required String id,
    required String name,
    required int price,
    required int durationMinutes,
    required String description,
  }) {
    final index = _services.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _services[index] = _services[index].copyWith(
        name: name,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
      );
      notifyListeners();
    }
  }
}

class BengkelScope extends InheritedNotifier<BengkelState> {
  const BengkelScope({
    super.key,
    required BengkelState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static BengkelState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BengkelScope>();
    assert(scope != null, 'No BengkelScope found in context');
    return scope!.notifier!;
  }
}
