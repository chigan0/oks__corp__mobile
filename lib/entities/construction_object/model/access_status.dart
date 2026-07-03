enum AccessStatus {
  granted,
  denied,
}

extension AccessStatusX on AccessStatus {
  bool get isGranted => this == AccessStatus.granted;

  String labelRu(bool isKz) {
    if (isKz) {
      return isGranted ? 'Рұқсат бар' : 'Рұқсат жоқ';
    }
    return isGranted ? 'Допуск есть' : 'Допуска нет';
  }
}
