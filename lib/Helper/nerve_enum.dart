
// ignore_for_file: constant_identifier_names

enum AppPlatform { mobile, web }

enum GreekLicenseValidity { monthly, quarterly }

enum APINames {
  login,
  accountSummary,
  watchedStocks,
  topPositions,
  marketMover,
  activityFeed,
  accountAnalysisPerformance,
  accountAnalysisCalendar,
  addWatchlist,
  deleteWatchlist,
  renameWatchlist,
  addWatchlistSymbol,
  getWatchlist,
  getSymbolFromWatchlist,
}

enum APIErrorCode {
  success,
  noContent,
  faile,
  nodata,
  sqlConectionfaile,
  queryFaile,
  unauthorized,
  query,
  sessionRequired,
  requestTimeOut,
  internalServerError,
  invalidUser,
  invalidPassword,
  unknown,
}
