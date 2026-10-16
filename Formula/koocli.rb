class Koocli < Formula
  desc "Huawei Cloud KooCLI command-line tool"
  homepage "https://support.huaweicloud.com/productdesc-hcli/hcli_01.html"
  version "7.3.12"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-arm64.tar.gz"
      sha256 "f41b5b1dd6e7dbe5c5d54793c02c72ad36d11e7fc8c9da851d1291bc600d3797"
    end
    on_intel do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-mac-amd64.tar.gz"
      sha256 "0a4f6fb5d76d16370e1bdc4bccfca63916e85d4c6d7fcc0d0cd9822ba5748850"
    end
  end

  on_linux do
    on_arm do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-linux-arm64.tar.gz"
      sha256 "9247259cd5c79d84a28c2739371c3e0a81d80d9e0a79c2f7a72a096e6c298ae9"
    end
    on_intel do
      url "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest/huaweicloud-cli-linux-amd64.tar.gz"
      sha256 "0b01cee0e943b8ec00fe7cd7df341f161665f8162eae85280fae221a0d9f938b"
    end
  end

  def install
    bin.install "hcloud"
    pkgshare.install "README.md" if (buildpath/"README.md").exist?
    pkgshare.install "OpenSourceSoftwareNotice.md" if (buildpath/"OpenSourceSoftwareNotice.md").exist?
  end

  test do
    # KooCLI writes to the OS user's home even when HOME is overridden.
    # Verify the installed binary offline under Homebrew's sandbox.
    binary = bin/"hcloud"
    assert binary.executable?, "hcloud is not executable"
    embedded_version = "-X hwcloudcli/util.CliVersion=#{version}"
    assert binary.binread.include?(embedded_version), "Embedded KooCLI version #{version} not found"
  end
end
