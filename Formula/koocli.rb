class Koocli < Formula
  desc "Huawei Cloud KooCLI command-line tool"
  homepage "https://support.huaweicloud.com/productdesc-hcli/hcli_01.html"
  version "7.2.12"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-arm64.tar.gz"
      sha256 "69940482ead3bf607ccfb2767f55288fc1d7af0d3e5ad69b660bdfabf2efe4bc"
    end
    on_intel do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-amd64.tar.gz"
      sha256 "4d00a27c87950eb39e2fc5ec4a39cde7e8642c6df7580350bff4e283d2717321"
    end
  end

  on_linux do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-linux-arm64.tar.gz"
      sha256 "f15358ee35d4314676e40f875e4917f1c35a2c1f011c41224fae9fa95a9e00ba"
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
    assert_match(/KooCLI Version \d+(?:\.\d+)+/, output)
    assert_match "Usage:", output
  end
end
