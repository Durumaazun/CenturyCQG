// ignore_for_file: constant_identifier_names

enum AppPlatform { mobile, web }

enum GreekLicenseValidity { monthly, quarterly }

enum APINames {
  login,
  accountSummary,
  accountOverview,
  accountAllocation,
  watchedStocks,
  topPositions,
  marketMover,
  activityFeed,
  accountAnalysisPerformanceStats,
  accountAnalysisPerformanceChart,
  accountAnalysisCalendar,
  accountAnalysisCalendarDetails,
  addWatchlist,
  deleteWatchlist,
  renameWatchlist,
  addWatchlistSymbol,
  getWatchlist,
  getSymbolFromWatchlist,
  tradePositions,
  tradeSymbolDetails,
  deleteTradePosition,
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
