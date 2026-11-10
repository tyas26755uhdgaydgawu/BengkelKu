class Motorcycle {
  final String brandAndModel;
  final String plateNumber;
  final String year;

  Motorcycle({
    required this.brandAndModel,
    required this.plateNumber,
    required this.year,
  });

  Motorcycle copyWith({
    String? brandAndModel,
    String? plateNumber,
    String? year,
  }) {
    return Motorcycle(
      brandAndModel: brandAndModel ?? this.brandAndModel,
      plateNumber: plateNumber ?? this.plateNumber,
      year: year ?? this.year,
    );
  }
}

enum UserRole {
  customer,
  owner,
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final Motorcycle? motorcycle;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.motorcycle,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    UserRole? role,
    Motorcycle? motorcycle,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      motorcycle: motorcycle ?? this.motorcycle,
    );
  }
}

class ServiceItem {
  final String id;
  final String name;
  final int durationMinutes;
  final int price;
  final String description;

  ServiceItem({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.description = '',
  });

  ServiceItem copyWith({
    String? name,
    int? durationMinutes,
    int? price,
    String? description,
  }) {
    return ServiceItem(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}

class Mechanic {
  final String id;
  final String name;
  final String avatarInitial;
  final bool isActive;

  Mechanic({
    required this.id,
    required this.name,
    required this.avatarInitial,
    this.isActive = true,
  });

  Mechanic copyWith({
    String? name,
    String? avatarInitial,
    bool? isActive,
  }) {
    return Mechanic(
      id: id,
      name: name ?? this.name,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum BookingStatus {
  menunggu,
  diterima,
  dikerjakan,
  selesai,
  ditolak,
  dibatalkan,
}

enum PaymentMethod {
  transfer,
  cash,
}

enum PaymentStatus {
  belumDibayar,
  lunas,
}

class Booking {
  final String id;
  final String code;
  final String customerName;
  final String customerPhone;
  final Motorcycle motorcycle;
  final ServiceItem service;
  final DateTime date;
  final String timeSlot;
  final Mechanic mechanic;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.code,
    required this.customerName,
    required this.customerPhone,
    required this.motorcycle,
    required this.service,
    required this.date,
    required this.timeSlot,
    required this.mechanic,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
  });

  Booking copyWith({
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    Mechanic? mechanic,
  }) {
    return Booking(
      id: id,
      code: code,
      customerName: customerName,
      customerPhone: customerPhone,
      motorcycle: motorcycle,
      service: service,
      date: date,
      timeSlot: timeSlot,
      mechanic: mechanic ?? this.mechanic,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
