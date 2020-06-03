class DateTimeFormatter {
  static DateTime dateTimeParser(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static formatDateDMY(String date, {bool shortYear = true}) {
    if (!shortYear) {
      return "${dateTimeParser(date).day}/${dateTimeParser(date).month}/${dateTimeParser(date).year}";
    }
    return "${dateTimeParser(date).day}/${dateTimeParser(date).month}/${dateTimeParser(date).year.remainder(100)}";
  }
}
