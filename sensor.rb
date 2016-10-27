class Sensor < Formula
  desc "PrimeSense sensor module for OpenNI"
  homepage "http://www.primesense.com"
  
  stable do
    url "https://github.com/PrimeSense/Sensor/archive/Stable-5.1.6.6.tar.gz"
    sha256 "d24797ca2d37d618346724378a664d0f37ad75c7e9e78533b8bc9188d3a97fd2"
    patch do
      url "https://github.com/gordonmcshane/Sensor/commit/5e92dfaf72a94eafb7745f5d811edb470b02f8bc.diff"
      sha256 "9f172c3cd4d3905dc9bb5bba877bb0cc2d885c9667120607c2603416454c9931"
    end
  end

  head do
    url "https://github.com/PrimeSense/Sensor.git"
    patch do
      url "https://github.com/gordonmcshane/Sensor/commit/5e92dfaf72a94eafb7745f5d811edb470b02f8bc.diff"
      sha256 "9f172c3cd4d3905dc9bb5bba877bb0cc2d885c9667120607c2603416454c9931"
    end
  end

  conflicts_with "sensor-kinect"

  option :universal

  depends_on "openni" => build.universal? ? ["universal"] : []

  def install
    ENV.universal_binary if build.universal?

    # Fix build files
    inreplace "Source/Utils/XnSensorServer/SensorServer.cpp", "/var/log/primesense/XnSensorServer/", "#{var}/log/primesense/XnSensorServer/"
    inreplace "Platform/Linux/Build/EngineLibMakefile", "/usr/include/ni", "#{HOMEBREW_PREFIX}/include/ni"
    inreplace "Platform/Linux/Build/Utils/EngineUtilMakefile", "/usr/include/ni", "#{HOMEBREW_PREFIX}/include/ni"
    inreplace "Platform/Linux/CreateRedist/RedistMaker", "echo $((N_CORES*2))", "echo $((1))"
    inreplace "Platform/Linux/Build/Common/CommonJavaMakefile", "/usr/share/java", "#{share}/java"

    # Build Sensor
    cd "Platform/Linux/CreateRedist"
    chmod 0755, "RedistMaker"
    system "./RedistMaker"

    cd Dir.glob("../Redist/Sensor-Bin-MacOSX-v*")[0]

    bin.install Dir["Bin/*"]
    lib.install Dir["Lib/*"]
    (etc+"primesense").install "Config/GlobalDefaults.ini"
  end

  def post_install
    system "#{HOMEBREW_PREFIX}/bin/niReg", "#{lib}/libXnDeviceSensorV2.dylib", "#{etc}/primesense"
    system "#{HOMEBREW_PREFIX}/bin/niReg", "#{lib}/libXnDeviceFile.dylib", "#{etc}/primesense"
    mkpath "#{var}/log/primesense/XnSensorServer"
    chmod 0777, "#{var}/log/primesense/XnSensorServer"
  end

  def caveats; <<-EOS.undent
    OpenNI formula is now provided by homebrew-science.
    Tap homebrew-science in advance.
      `brew tap homebrew/science`
    EOS
  end
end
