# homebrew-koocli

这个仓库是 KooCLI 的 Homebrew tap，依据华为云 KooCLI 快速入门页面公开的下载入口来生成 formula，并通过 GitHub Actions 每天检查上游 `latest` 包是否更新。

参考页面：

- [华为云命令行工具服务 KooCLI 快速入门](https://support.huaweicloud.com/qs-hcli/hcli_02_003_03.html)

## 安装

```bash
brew tap <owner>/koocli
brew install <owner>/koocli/koocli
```

对应的 GitHub 仓库名建议为 `homebrew-koocli`。

## 设计说明

- 上游文档公开的是 `latest` 固定下载地址，而不是带版本号的归档地址。
- 因此这里不依赖 `brew livecheck`，而是用 GitHub Actions 每天下载上游最新归档。
- 更新脚本会同时抓取 macOS/Linux 与 arm64/x86_64 的 `.sha256` 文件。
- 真实版本号不是从页面 HTML 提取，而是从 KooCLI 二进制里的 Go build ldflags 中提取 `CliVersion`。
- 只有当 `Formula/koocli.rb` 发生实际变化时，workflow 才会审计、安装、测试并提交。

## 仓库结构

- `Formula/koocli.rb`：KooCLI formula
- `scripts/update-koocli-formula.sh`：抓取上游 `latest` 包并改写 formula
- `.github/workflows/update-koocli.yml`：每日自动检查更新

## GitHub Actions

默认计划任务是每天 UTC `02:17` 执行一次。当前用户时区 `Asia/Shanghai` 下等于每天 `10:17`。

推到 GitHub 后，workflow 会执行以下流程：

1. 拉取仓库
2. 运行更新脚本
3. 若 formula 无变化则退出
4. 若有变化则执行 `brew audit`
5. 本地 tap 安装并运行 `brew test`
6. 提交并推送更新

## 本地手动更新

```bash
bash scripts/update-koocli-formula.sh
brew tap <owner>/koocli "$(pwd)"
HOMEBREW_NO_INSTALL_FROM_API=1 brew audit --strict <owner>/koocli/koocli
HOMEBREW_NO_INSTALL_FROM_API=1 brew reinstall <owner>/koocli/koocli
HOMEBREW_NO_INSTALL_FROM_API=1 brew test <owner>/koocli/koocli
```

## 注意

- 这个仓库当前需要托管在 GitHub 上，定时检查才会生效。
- `brew test koocli` 会向 `hcloud --help` 输入 `y`，绕过 KooCLI 首次运行时的隐私确认提示。
