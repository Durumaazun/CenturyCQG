class AccountAnalysisPerformanceRequest {
  const AccountAnalysisPerformanceRequest({
    required this.accountId,
    required this.period,
    required this.marketImpact,
    this.customRange,
  });

  final String accountId;
  final String period;
  final String marketImpact;
  final String? customRange;

  Map<String, dynamic> toJson() => {
    'accnt_id': accountId,
    'period': period,
    'market_impact': marketImpact,
    'custom_range': customRange,
  };
}

class AccountAnalysisCalendarRequest {
  const AccountAnalysisCalendarRequest({
    required this.accountId,
    required this.year,
    required this.month,
  });

  final String accountId;
  final int year;
  final int month;

  Map<String, dynamic> toJson() => {
    'accnt_id': accountId,
    'year': year,
    'month': month,
  };
}

class AccountAnalysisDayDetailsRequest {
  const AccountAnalysisDayDetailsRequest({
    required this.accountId,
    required this.date,
  });

  final String accountId;
  final String date;

  Map<String, dynamic> toJson() => {'accnt_id': accountId, 'date': date};
}
