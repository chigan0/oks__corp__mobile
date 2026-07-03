enum ServiceType {
  worker,
  guard,
}

extension ServiceTypeX on ServiceType {
  String get title {
    return switch (this) {
      ServiceType.worker => 'Сервис юзеров',
      ServiceType.guard => 'Сервис охранников',
    };
  }

  String get description {
    return switch (this) {
      ServiceType.worker =>
        'Этот сервис предназначен для тех, кто посещает объекты компании OKS Group',
      ServiceType.guard =>
        'Этот сервис предназначен для контроля пропуска на объекты компании OKS Group',
    };
  }

  String get route {
    return switch (this) {
      ServiceType.worker => '/worker',
      ServiceType.guard => '/guard',
    };
  }
}
