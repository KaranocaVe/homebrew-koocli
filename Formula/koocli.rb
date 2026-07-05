class Koocli < Formula
  desc "Huawei Cloud KooCLI command-line tool"
  homepage "https://support.huaweicloud.com/productdesc-hcli/hcli_01.html"
  version "7.2.2"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-arm64.tar.gz"
      sha256 "b9b8fe9699889aa9c94b26ab6745b6c5bc13c47431f4f489be5d40a2eedebad1"
    end
    on_intel do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-amd64.tar.gz"
      sha256 "fd6005066deb7894001da002fc9079754beeae51ce14cb02519cff7ab19b2dc5"
    end
  end

  on_linux do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-linux-arm64.tar.gz"
      sha256 "ed4026ec6409f781ecbdea394bfe20fe8cc65f88ca9fc33d9341a81761eed0d5"
    end
    on_intel do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-linux-amd64.tar.gz"
      sha256 "eba29414c9e63685d8b5cbad2a67af70c60c1eb0ed576bc779acefd6ba67b71f"
    end
  end

  def install
    bin.install "hcloud"
    pkgshare.install "README.md" if (buildpath/"README.md").exist?
    pkgshare.install "OpenSourceSoftwareNotice.md" if (buildpath/"OpenSourceSoftwareNotice.md").exist?
  end

  test do
    output = pipe_output("#{bin}/hcloud --help", "y\n")
    assert_match "KooCLI Version #{version}", output
    assert_match "Usage:", output
  end
end
