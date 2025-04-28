enum CachePolicy {
  shortTerm(Duration(minutes: 15)),
  mediumTerm(Duration(hours: 1)),
  longTerm(Duration(hours: 24));

  final Duration validDuration;
  const CachePolicy(this.validDuration);
}