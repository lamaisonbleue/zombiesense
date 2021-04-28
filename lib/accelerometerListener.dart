class AccelerometerChangeListener {
  int startX = 0;
  int startY = 0;
  int startZ = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  AccelerometerChangeListener(List<int> accelData) {
    if (accelData.length == 3) {
      this.startX = transform(accelData[0]);
      this.startY = transform(accelData[1]);
      this.startZ = transform(accelData[2]);
    }
  }

  void setAccl(List<int> accelData) {
    if (accelData.length == 3) {
    // grenzen hardcoden
      this.x = (this.startX - transform(accelData[0])).toDouble();

      // used for player-movement
      double a = mmin(10, (mmax(-20.0, this.startY - transform(accelData[1]) - 10) + 10)).toDouble();
      this.y = a == 0 ? 0 : a / 10;//a == 0 ? 0 : 10.0 / a;
      double b = mmin(10, (mmax(-20.0, this.startZ - transform(accelData[2]) - 10) + 10)).toDouble();
      this.z = b == 0 ? 0 : b / 10;
    }
  }

  // Float value in m/s^2 = (Acc value / Acc scale factor) * 9.80665
  // scale-factor = 2048
  int transform(int d) {
    double scaleFac = 2048;
    return ((d / scaleFac) * 9.8).round();
  }

   num mmax(num a, num b) {
    if (a > b)
      return a;

    return b;
  }
  num mmin(num a, num b) {
    if (a < b)
      return a;

    return b;
  }

}