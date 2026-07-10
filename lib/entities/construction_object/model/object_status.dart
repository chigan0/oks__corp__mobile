enum ObjectStatus {
  planning,
  active,
  frozen,
  completed;

  static ObjectStatus fromJson(String? value) {
    return ObjectStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ObjectStatus.planning,
    );
  }
}

extension ObjectStatusX on ObjectStatus {
  String labelRu(bool isKz) {
    if (isKz) {
      return switch (this) {
        ObjectStatus.planning => 'Жоспарлануда',
        ObjectStatus.active => 'Құрылыс процесінде',
        ObjectStatus.frozen => 'Тоқтатылған',
        ObjectStatus.completed => 'Тапсырылған',
      };
    }
    return switch (this) {
      ObjectStatus.planning => 'Планируется',
      ObjectStatus.active => 'В процессе строительства',
      ObjectStatus.frozen => 'Заморожен',
      ObjectStatus.completed => 'Сдан',
    };
  }
}
