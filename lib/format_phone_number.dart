class FormatPhoneNumber{
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '+63${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('9')) {
      return '+63$phoneNumber';
    } else if (!phoneNumber.startsWith('+')) {
      return '+$phoneNumber';
    } else {
      return phoneNumber;
    }
  }

}