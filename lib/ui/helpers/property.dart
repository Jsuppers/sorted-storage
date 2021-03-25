class Property {
  static T getValueOrDefault<T>(T input, T defaultValue) {
    if (input == null || input == '') {
      return defaultValue;
    }
    return input;
  }
}
