import 'dart:convert';
import 'dart:math';

import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

extension APIExtension on String {}

extension GreekDate on DateTime {
  String toStringWithFormated({required String dateFormat}) {
    final formate = DateFormat(dateFormat);
    final resultDate = formate.format(this);
    return resultDate;
  }

  DateTime addDayinCurrentDate({required int days}) {
    final currentDate = this;
    final newDate = DateTime(
      currentDate.year,
      currentDate.month,
      (currentDate.day + days),
    );
    return newDate;
  }

  DateTime minusDayinCurrentDate({required int days}) {
    final currentDate = this;
    final newDate = DateTime(
      currentDate.year,
      currentDate.month,
      (currentDate.day - days),
    );
    return newDate;
  }

  DateTime getLicenseExpiryDate({
    required GreekLicenseValidity licenseValidity,
  }) {
    final currentDay = day;
    DateTime expiryDate = this;

    if (currentDay < 25) {
      expiryDate = DateTime(
        year,
        (month + ((licenseValidity == GreekLicenseValidity.monthly) ? 1 : 3)),
        5,
      );
    } else {
      expiryDate = DateTime(
        year,
        (month + ((licenseValidity == GreekLicenseValidity.monthly) ? 2 : 4)),
        5,
      );
    }

    return expiryDate;
  }

  String formatNumber(int number) {
    // Pad with zeros to 3 digits
    if (number < 100) {
      return number.toString().padLeft(3, '0');
    }
    return number.toString();
  }
}

extension StringExtension on String {
  String capitalizeFirstofEach() {
    final text = this;
    if (text.isEmpty) {
      return '';
    }

    final l = text.split(" ").where((element) => element.isNotEmpty).toList();
    if (l.isNotEmpty) {
      final joinString = l
          .map((str) {
            final s =
                '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}';
            return s;
          })
          .join(" ");

      return joinString.trim();
    } else if ((text.isNotEmpty) && (l.isEmpty)) {
      return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}'
          .trim();
    }

    return '';
  }

  DateTime? toDate() {
    return DateTime.tryParse(this);
  }

  //==================================================

  String getRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  Tuple5<String, String, String, encrypt.Key, encrypt.IV> encryptASE256CDC() {
    //final secureKey = getRandomString(20);
    const secureKey = "12345678901234567890";
    final key = encrypt.Key.fromBase64(
      base64.encode(utf8.encode("Gl@123${secureKey}321@lG")),
    );

    //final secureIV = getRandomString(4);
    const secureIV = "4567";
    final iv = encrypt.IV.fromBase64(
      base64.encode(utf8.encode("lG@321${secureIV}123@Gl")),
    );

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final base64String = base64.encode(utf8.encode(this));
    final encrypted = encrypter.encrypt(base64String, iv: iv);

    final leftPaddingKeyString = getRandomString(16);
    final aseKey1 = secureKey.substring(0, (secureKey.length ~/ 2));
    final middelPaddingKeyString = getRandomString(8);
    final aseKey2 = secureKey.substring(
      (secureKey.length ~/ 2),
      secureKey.length,
    );
    final rightPaddingKeyString = getRandomString(16);

    final mainKey =
        leftPaddingKeyString +
        aseKey1 +
        middelPaddingKeyString +
        aseKey2 +
        rightPaddingKeyString;

    final leftPaddingIVString = getRandomString(16);
    final aseIV1 = secureIV.substring(0, (secureIV.length ~/ 2));
    final middelPaddingIVString = getRandomString(8);
    final aseIV2 = secureIV.substring((secureIV.length ~/ 2), secureIV.length);
    final rightPaddingIVString = getRandomString(16);

    final mainIV =
        leftPaddingIVString +
        aseIV1 +
        middelPaddingIVString +
        aseIV2 +
        rightPaddingIVString;

    return Tuple5<String, String, String, encrypt.Key, encrypt.IV>(
      encrypted.base64,
      base64.encode(utf8.encode(mainKey)),
      base64.encode(utf8.encode(mainIV)),
      key,
      iv,
    );
  }

  String decryptASE256CDC({required encrypt.Key key, required encrypt.IV iv}) {
    final decrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final decrypted = decrypter.decrypt64(this, iv: iv);
    return decrypted;
  }

  APIErrorCode stringToApiErrorCode() {
    switch (this) {
      case '200':
        return APIErrorCode.success;
      case '204':
        return APIErrorCode.noContent;
      case '601':
        return APIErrorCode.faile;
      case '602':
        return APIErrorCode.nodata;
      case '603':
        return APIErrorCode.sqlConectionfaile;
      case '604':
        return APIErrorCode.queryFaile;
      case '401':
        return APIErrorCode.unauthorized;
      case '403':
        return APIErrorCode.sessionRequired;
      case '408':
        return APIErrorCode.requestTimeOut;
      case '500':
        return APIErrorCode.internalServerError;
      case '5':
        return APIErrorCode.invalidUser;
      case '6':
        return APIErrorCode.invalidPassword;
      default:
        return APIErrorCode.unknown;
    }
  }
}

extension IntExtension on int {
  /*   LicenseType toLicenseTypeEnumValue() {
    switch (this) {
      case 1: /*return LicenseType.newLicense;*/
      case 2:
        return LicenseType.newLicense;
      case 3:
        return LicenseType.uatLicense;
      case 4:
        return LicenseType.demoLicense;
      case 5:
        return LicenseType.mockLicense;
      default:
        return LicenseType.newLicense;
    }
  }
 */
  APIErrorCode intToApiErrorCode() {
    switch (this) {
      case 200:
        return APIErrorCode.success;
      case 204:
        return APIErrorCode.noContent;
      case 601:
        return APIErrorCode.faile;
      case 602:
        return APIErrorCode.nodata;
      case 603:
        return APIErrorCode.sqlConectionfaile;
      case 604:
        return APIErrorCode.queryFaile;
      case 401:
        return APIErrorCode.unauthorized;
      case 403:
        return APIErrorCode.sessionRequired;
      case 408:
        return APIErrorCode.requestTimeOut;
      case 500:
        return APIErrorCode.internalServerError;
      case 5:
        return APIErrorCode.invalidUser;
      case 6:
        return APIErrorCode.invalidPassword;
      default:
        return APIErrorCode.unknown;
    }
  }
}
