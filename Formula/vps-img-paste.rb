class VpsImgPaste < Formula
  desc "Menu-bar app to send Mac clipboard images (or a screenshot) to a host over SSH"
  homepage "https://github.com/SerenityTn/vps-img-paste"
  url "https://github.com/SerenityTn/vps-img-paste/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "255d7d640c0a7447f6472379abc339138a0d07b4a006ae901820dd730907b4e5"
  license "MIT"

  depends_on :macos
  depends_on "pngpaste"

  def install
    app = prefix/"VpsImgPaste.app"
    (app/"Contents/MacOS").mkpath

    (app/"Contents/Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key><string>VpsImgPaste</string>
        <key>CFBundleDisplayName</key><string>VPS Image Paste</string>
        <key>CFBundleIdentifier</key><string>com.khaireddine.vpsimgpaste</string>
        <key>CFBundleExecutable</key><string>VpsImgPaste</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>CFBundleVersion</key><string>#{version}</string>
        <key>LSUIElement</key><true/>
        <key>LSMinimumSystemVersion</key><string>13.0</string>
        <key>NSHighResolutionCapable</key><true/>
      </dict>
      </plist>
    PLIST

    system "swiftc", "-O", "-o", app/"Contents/MacOS/VpsImgPaste",
           "src/VpsImgPaste.swift", "-framework", "AppKit"
    system "codesign", "--force", "--sign", "-", app

    bin.install "bin/vps-img-paste"
    pkgshare.install "vps-img-paste.env.example"
  end

  service do
    run [opt_prefix/"VpsImgPaste.app/Contents/MacOS/VpsImgPaste"]
    keep_alive false
    run_type :immediate
  end

  def caveats
    <<~EOS
      Configure your host (first time only):
        mkdir -p ~/.config
        cp #{opt_pkgshare}/vps-img-paste.env.example ~/.config/vps-img-paste.env
        $EDITOR ~/.config/vps-img-paste.env      # set VPS_HOST / VPS_REMOTE_HOME
        ssh user@your-vps-host 'mkdir -p ~/img-uploads'

      Start the menu-bar app (now and at login):
        brew services start vps-img-paste

      The screenshot fallback needs Screen Recording permission:
        System Settings > Privacy & Security > Screen Recording > VPS Image Paste
    EOS
  end

  test do
    assert_predicate bin/"vps-img-paste", :executable?
    assert_path_exists pkgshare/"vps-img-paste.env.example"
  end
end
