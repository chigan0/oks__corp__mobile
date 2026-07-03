enum ObjectStatus {
  underConstruction,
  completed,
}

extension ObjectStatusX on ObjectStatus {
  String labelRu(bool isKz) {
    if (isKz) {
      return switch (this) {
        ObjectStatus.underConstruction => 'Құрылыс процесінде',
        ObjectStatus.completed => 'Тапсырылған',
      };
    }
    return switch (this) {
      ObjectStatus.underConstruction => 'В процессе строительства',
      ObjectStatus.completed => 'Сдан',
    };
  }
}
