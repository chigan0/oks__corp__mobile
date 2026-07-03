import 'dart:math' as math;

import 'package:flutter/services.dart';

class KzPhoneInputFormatter extends TextInputFormatter {
  static const _prefix = '+7 ';
  static const _maxDigits = 10;

  /// Returns subscriber digits only (up to 10 digits, no country code).
  ///
  /// When [text] already carries our own "+7 " chrome (i.e. it's the result
  /// of a previous formatting pass), everything after that literal prefix is
  /// real subscriber input — no guessing needed. Only fresh/pasted text that
  /// doesn't yet have the chrome (first keystroke, or a full number pasted
  /// with its country code) is checked for a redundant leading 7/8, and only
  /// when there are more than [_maxDigits] digits — KZ mobile numbers
  /// themselves commonly start with 7 (705, 707, 771, 775-778, ...), so a
  /// plain leading-digit check would misread a real subscriber digit.
  static String digitsOnly(String text) {
    final hasOwnPrefix = text.startsWith(_prefix);
    final content = hasOwnPrefix ? text.substring(_prefix.length) : text;
    final raw = content.replaceAll(RegExp(r'\D'), '');
    if (raw.isEmpty) return '';

    final hasForeignCountryCode = !hasOwnPrefix &&
        raw.length > _maxDigits &&
        (raw.startsWith('7') || raw.startsWith('8'));
    if (hasForeignCountryCode) {
      return raw.substring(1, math.min(raw.length, _maxDigits + 1));
    }

    return raw.substring(0, math.min(raw.length, _maxDigits));
  }

  static String format(String digits) {
    if (digits.isEmpty) return _prefix;

    final buffer = StringBuffer(_prefix);
    buffer.write(digits.substring(0, math.min(3, digits.length)));

    if (digits.length > 3) {
      buffer.write(' ');
      buffer.write(digits.substring(3, math.min(6, digits.length)));
    }

    if (digits.length > 6) {
      buffer.write(' ');
      buffer.write(digits.substring(6, math.min(8, digits.length)));
    }

    if (digits.length > 8) {
      buffer.write(' ');
      buffer.write(digits.substring(8, math.min(10, digits.length)));
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep the "+7 " prefix intact — don't let edits delete into it.
    if (oldValue.text.startsWith(_prefix) &&
        !newValue.text.startsWith(_prefix)) {
      return const TextEditingValue(
        text: _prefix,
        selection: TextSelection.collapsed(offset: _prefix.length),
      );
    }

    final digits = digitsOnly(newValue.text);
    final formatted = format(digits);

    final digitIndex = _digitIndexBeforeCursor(
      newValue.text,
      newValue.selection.end,
    );
    final selectionIndex = _cursorAfterDigitIndex(formatted, digitIndex);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  static int _digitIndexBeforeCursor(String text, int cursor) {
    final start = text.startsWith(_prefix) ? _prefix.length : 0;
    final end = math.max(start, math.min(cursor, text.length));

    var count = 0;
    for (var i = start; i < end; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) {
        count++;
      }
    }

    return count;
  }

  static int _cursorAfterDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return _prefix.length;

    var seen = 0;
    for (var i = _prefix.length; i < formatted.length; i++) {
      if (!RegExp(r'\d').hasMatch(formatted[i])) continue;

      seen++;
      if (seen >= digitIndex) {
        return i + 1;
      }
    }

    return formatted.length;
  }
}
