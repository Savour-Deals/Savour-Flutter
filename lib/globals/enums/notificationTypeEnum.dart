class NotificationTypeEnum {
  final _value;
  const NotificationTypeEnum._internal(this._value);

  static const NOTIFICATION = NotificationTypeEnum._internal('NOTIFICATION');
  static const DEAL = NotificationTypeEnum._internal('DEAL');
  static const LINK = NotificationTypeEnum._internal('LINK');

  //Used to specify a value not defined above. We dont handle these.
  static const UNKNOWN = NotificationTypeEnum._internal('UNKNOWN');
  static const _types = [
    NOTIFICATION,
    DEAL,
    LINK
  ];

  static NotificationTypeEnum fromString(String str) {
    for (var type in NotificationTypeEnum._types) {
      if (type._value == str){
        return type;
      }
    }
    print('No known notification type for string "$str"');
    return UNKNOWN;
  }
}