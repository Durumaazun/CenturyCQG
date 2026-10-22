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
  addWatchlist,
  deleteWatchlist,
  renameWatchlist,
  addWatchlistSymbol,
  getWatchlist,
}

enum APIErrorCode {
  success,
  noContent,
  faile,
  nodata,
  sqlConectionfaile,
  queryFaile,
  unauthorized,
  sessionRequired,
  requestTimeOut,
  internalServerError,
  invalidUser,
  invalidPassword,
  unknown,
}
