class FileCoverage {
  final String path;
  final int totalLines;
  final int hitLines;

  FileCoverage({
    required this.path,
    required this.totalLines,
    required this.hitLines,
  });

  double get percentage =>
      totalLines > 0 ? (hitLines / totalLines) * 100 : 0.0;
}
