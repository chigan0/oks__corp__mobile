/// A downloadable file attached to a facility, as returned by
/// GET /facilities/{uuid}/documents.
class FacilityDocument {
  const FacilityDocument({required this.name, required this.url});

  final String name;
  final String url;

  factory FacilityDocument.fromJson(Map<String, dynamic> json) {
    return FacilityDocument(
      name: json['originalName'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
