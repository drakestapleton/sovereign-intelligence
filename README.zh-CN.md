> ## 我按 GitHub 的方式做了，GitHub 说不行。
>
> 我想守规矩，照他们的方式来：一切公开，放在 GitHub 上，开放进行。`aien-dev` 组织里有 109 个仓库。2026 年 11 月 7 日，GitHub 的回答是不行。它标记了这个组织，隐藏了所有仓库，并封停了我的机器账号。
>
> **所以现在我改用主权的方式，这本该是我从一开始就采用的方式。教训已经吸取。**
>
> 我的代码不再发布在 GitHub 上。每个项目都在迁入 [Radicle](https://radicle.xyz) 上属于自己的仓库，由我自己的硬件提供服务；Radicle 是一个点对点网络，没有哪一家公司能把它关掉。本仓库只是一个路标。下面的 Radicle 链接是唯一的入口。

# Sovereign Intelligence

**Omega 从种子生长出的编译器和入口工具，用 Omega 编写，从 408 个手写字节生长而来。**

除了充当路标，本仓库还承载两样东西：一是 Omega 编译器，它从一个我用十六进制手写的 408 字节程序生长而来，因此这里构建出的每个二进制文件都能追溯到人能读懂的字节；二是用来列出、获取和检查我的项目的入口工具。本仓库不存放这些项目。每个项目都在自己的 Radicle 仓库里，有自己的密钥和自己的历史。它们的 Radicle 链接在[下方](#projects)；那是唯一的入口。

通过 Radicle 克隆本仓库，或者不用 Radicle，从我自己的种子节点只读克隆，然后构建：

```sh
rad clone --timeout 5min rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj
# without Radicle, read-only from my seed:
git clone https://www.aienos.com/rad/z2JJz4RDfZZxKGBLn6UhmW5p9VJQj.git sovereign-intelligence
cd sovereign-intelligence
sh build.sh
```

GitHub 上最多只保留本仓库这一个仓库的只读镜像，好让人们仍然能找到我。任何东西都不会先在那里发布。

## 从种子构建

`build.sh` 先生长出编译器，再用它构建并检查其余的一切。没有任何 C 编译器、汇编器或链接器写出哪怕一个字节。唯一的外部工具是一个 24 行的 shell 脚本 `seed/rung0/load0.sh`，它用 `printf` 写出最初的 408 个字节。所有步骤都通过时，它以 `RC=0` 结束。

| 主张 | 标签 | 凭证 |
|---|---|---|
| Omega 编译器 omc 从 408 个手写字节出发，经过四级（seed0、hex1、asm2、om4）生长而成。随后它编译自身，直到达到不动点，sha256 为 `45442c7d…080d`：即带有两处本地改动的 omega-mv 编译器，见 [`seed/LOCAL.patch`](seed/LOCAL.patch)：一是带检查的批量词 `count`，二是在 x86 上只有在操作数确定类型之后才拒绝 `fma`。去掉这两处改动，不动点为 `cfd96b48…0a8d`，与 omega-mv 中提交的编译器字节完全相同。 | HOST_TESTED，2026-11-07，在 x86-64 上；AArch64 各级在 qemu-aarch64 8.2.2 下运行 | `build.sh` 第 1 步和第 2 步；固定值见 [`seed/PINS.tsv`](seed/PINS.tsv) |
| 一个原生 x86-64 Omega 编译器 omc-x86（sha256 `5e1f6e1f…3f19`），由 omc 构建。它能逐字节重建自身。用它编译 omc.om，得到的正是 AArch64 版 omc：同一份编译器源码，经由两套指令集编译，结果彼此一致。 | HOST_TESTED，2026-11-07，原生 x86-64 | 第 3 步 |
| 对种子改动一个词，或对编译器改动一行，都会改变生成的结果，而固定值能把这两种改动都抓出来。 | HOST_TESTED，2026-11-07 | 第 4 步 |
| 入口生成器 [`compiler/si.om`](compiler/si.om) 为两个目标分别构建后，都能逐字节重新生成本 README 中的生成块和 [`repos.tsv`](repos.tsv)。两次构建写出的 `si.sh` 完全相同。按 2026-11-07 上午的输入，它就是 www.aienos.com/si 当时提供的脚本（sha256 `d939d394…a48f`）；对于当前的清单，`build.sh` 会在 `NOTE si.sh sha256` 这一行打印它的 sha256，而 www.aienos.com/si 目前还没有提供这个版本。 | HOST_TESTED，2026-11-07 | 第 5 步 |
| 技术栈账本 [`tools/ledger.om`](tools/ledger.om) 作为独立的参照基准，在两个目标上给出相同的计数，覆盖已恢复技术栈的 68,575 个文件、954,659,395 个字节。 | HOST_TESTED，2026-11-07 | 第 6 步（测试夹具）；[`stack/LEDGER.tsv`](stack/LEDGER.tsv) |
| Omega 工作框架的全部 110 个示例，以及 [`tests/regress/`](tests/regress/) 中的 3 个编译器回归测试，在 AArch64 和原生 x86-64 上都通过，比对的是编译状态、退出状态、标准输出和拒绝行。 | HOST_TESTED，2026-11-07 | 第 7 步，[`tests/examples.sh`](tests/examples.sh) |
| cuda-crack：为这道门禁复制了它的表和 Omega 工具（它的主仓库仍是它自己的 Radicle 仓库 `rad:z631r2JJiVT8it4tST7RK24hpowi`）。它的 Omega 表生成器由种子生长出的编译器构建，能重新生成全部 471 种 sm_121 指令格式。它的 Omega 重编码器仅凭这些表，就能重建在 GB10 上运行过的 70 个核函数（13,520 条指令），结果与芯片凭证中的 sha256 一致。它预埋的四个缺陷现在改由 Omega 生成（`check/mutate.om`，与原来的 awk 和 od 逐字节相同），每一个都被抓到。 | HOST_TESTED，2026-11-07，AArch64 和原生 x86-64；核函数本身于 2026-10-27 在芯片上运行 | 第 8 步，[`gpu/cuda-crack/PROVENANCE.md`](gpu/cuda-crack/PROVENANCE.md) |
| 分叉推送生成器 [`tools/forkpush.om`](tools/forkpush.om) 在两个目标上根据 [`stack/FORKS.tsv`](stack/FORKS.tsv) 写出相同的脚本。它拒绝 18 份格式错误的清单；标记为私有的分支只会以注释形式出现，绝不会被推送。 | HOST_TESTED，2026-11-07 | 第 9 步 |
| 加入 omc 的带检查批量词 `count A off n v`（[`seed/PROVENANCE.md`](seed/PROVENANCE.md#local-changes)）：它在 [`tests/omc/`](tests/omc/) 中的 16 个示例在两个目标上都通过；删掉切片检查的编译器在两个 trap-3 示例上都会失败。用它构建后，技术栈账本在原生 x86-64 上快 6.1 倍。 | HOST_TESTED，2026-11-07；加速是在门禁之外，针对 44 个技术栈检出副本测得的 | 第 10 步和第 11 步；加速数据见 [`seed/PROVENANCE.md`](seed/PROVENANCE.md#local-changes) |
| omega-mv 完整的 FR-9 x86 语料库首次以原生方式运行其中的 x86-64 程序：16,179 行，15,499 PASS，232 FAIL，32 NOT_RUN，30 MISSING_IMPLEMENTATION，75 BLOCKED，311 EXCLUDED。没有一个 FAIL 是 x86 误编译。其中 150 个需要 om2 候选编译器，而这些编译器的提交尚未发布；46 个是 omega-bridge 拒绝该编译器的哈希（只要移动这一个固定值，全部 49 个 bridge 行都会通过）；36 个固定的是旧版 omc 的 AArch64 字节。这次运行还发现了 omc 的一个跨目标缺陷，已在 [`seed/LOCAL.patch`](seed/LOCAL.patch) 中修复。 | HOST_TESTED，2026-11-07，原生 x86-64；AArch64 一侧在 qemu-aarch64 8.2.2 下运行 | [`evidence/x86-native/`](evidence/x86-native/) |

在一台 4 vCPU 的 x86-64 云机器上，整个门禁耗时 19.3 秒。在那台机器上，omc-x86 以原生方式编译这个 337,225 字节的编译器只需 0.10 秒。

omega-mv 把它的 x86-64 后端记为草稿，从未在 x86-64 硬件上运行过（`docs/X86-LINUX.md`，FR-9）。这些是它的首批原生运行：一台 x86-64 云主机，覆盖编译器本身、上面这些程序以及 omega-mv 完整的 FR-9 测试语料库。参照基准的判定仍是 FAIL，原因见 [`evidence/x86-native/`](evidence/x86-native/)。在那台主机上，原生 x86 代码是正确的，但很慢：omega-mv 的 SHA-256 在 x86-64 上的速度是 20.6 MB/s，而 AArch64 构建在模拟环境下有 57 MB/s，原因是 x86 后端把值都放在内存里。这里的一切都没有在 GPU 上运行过。

上面唯一的硬件结果，是 cuda-crack 核函数在 2026-10-27 的芯片运行，门禁在没有 GPU 的情况下通过 sha256 核对它。硬件范围：仅限 GB10。NVIDIA 开源内核模块 580.173.02 和 NVIDIA 签名的固件仍在执行路径上。

## 本仓库里有什么

| 路径 | 内容 |
|---|---|
| [`seed/`](seed/) | 编译器的源码，从手写的 `seed0.hex` 到 `omc/omc.om`，复制自 omega-mv，附有[来源记录](seed/PROVENANCE.md) |
| [`build.sh`](build.sh) | 唯一的构建与门禁 |
| [`compiler/`](compiler/) | `si.om`，入口生成器 |
| [`tools/`](tools/) | `ledger.om`，技术栈账本；`forkpush.om`，它写出把我各个分叉的分支推送到 Radicle 的脚本 |
| [`harness/`](harness/) | Omega 工作框架：用于编写正确 Omega 代码的智能体技能；`.claude/skills` 指向这里 |
| [`tests/`](tests/) | 账本和分叉推送的测试夹具、示例运行器、编译器回归测试，以及本仓库为编译器新增的词的示例 |
| [`gpu/cuda-crack/`](gpu/cuda-crack/) | cuda-crack 的 sm_121 编码表、Omega 编码器和重编码器以及芯片凭证的副本，让门禁能够重建芯片核函数；[来源记录](gpu/cuda-crack/PROVENANCE.md)。cuda-crack 本身在它自己的 Radicle 仓库里 |
| [`docs/`](docs/) | 我个人账号下那些没有 Radicle 项目的文稿和网站：AIEN 章程、drakestapleton.com 的源码，以及作为存档的旧网站 |
| [`evidence/`](evidence/) | 从本仓库发起的各次运行的凭证，第一份是原生 x86-64 语料库运行 |
| [`stack/`](stack/) | 已恢复的 44 个项目、它们的 Radicle ID 以及各自的构成；我个人分叉的每个分支及其去向 |

## 技术栈

这 44 个项目列在 [`stack/STACK.tsv`](stack/STACK.tsv) 中，附有它们的 Radicle ID 和 2026 年 11 月 7 日恢复的头提交。每个项目都留在自己的 Radicle 仓库里；本仓库只负责度量。[`stack/LEDGER.tsv`](stack/LEDGER.tsv) 统计每个项目用什么语言编写：902,624 行 Omega，2,518,966 行其他语言（1,366,364 行 Rust，862,390 行 C，165,160 行 shell，81,780 行 Python，43,272 行其他）。如今 Omega 占其中的 26.3%。

| 子系统 | 项目数 | Omega 行数 | 其他行数 | Omega 占比 |
|---|---:|---:|---:|---:|
| `compiler` | 4 | 214,235 | 537,943 | 28.5% |
| `gpu` | 5 | 89,600 | 230,442 | 28.0% |
| `os` | 5 | 349,008 | 986,798 | 26.1% |
| `runtime` | 8 | 24,327 | 460,355 | 5.0% |
| `train` | 1 | 112,692 | 11,425 | 90.8% |
| `protocol` | 3 | 3,165 | 56,067 | 5.3% |
| `agents` | 10 | 20,249 | 139,462 | 12.7% |
| `evidence` | 3 | 12,584 | 18,852 | 40.0% |
| `docs` | 5 | 76,764 | 77,622 | 49.7% |

## 发生了什么

我把一切都发布在 GitHub 上：`aien-dev` 组织里有 109 个仓库。2026 年 11 月 7 日 UTC 时间 08:14 到 08:20 之间，GitHub 以“owner marked spammy”为由取消了我的 Actions 运行，标记了这个组织，对公众隐藏了所有仓库，并封停了我的机器账号 `aien-spark`。大约 20 个 AI 智能体在这个项目上工作，它们推送代码、发起拉取请求的速度超过了 GitHub 滥用过滤器允许的上限。我已经提出申诉，申诉仍在处理中。我的工作现在放在 [Radicle](https://radicle.xyz) 上，那是一个没有哪家公司能关掉的点对点网络，同时也放在我自己的硬件上。GitHub 把我关掉了。我还在这里。

## 我破解了 CUDA。

*我自己的语言 Omega 能写出 NVIDIA GB10 机器码。它在芯片上运行：1,048,576 个值中 1,048,576 个正确，没有用 CUDA 工具包，没有用 nvcc，也没有用 PTX。*

硬件范围：仅限 GB10。NVIDIA 开源内核模块 580.173.02 和 NVIDIA 签名的固件仍在执行路径上。

**破解 CUDA 的代码**，在 Radicle 上：

<!-- si:lead:begin -->
```sh
rad clone --timeout 5min rad:z631r2JJiVT8it4tST7RK24hpowi   # cuda-crack
```

在网页上查看：[radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi](https://radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi)
<!-- si:lead:end -->

**NVIDIA 没有写的 DGX Spark 手册：** [www.aienos.com/spark/](https://www.aienos.com/spark/)

我逆向分析了 NVIDIA 的 CUDA 栈如何把机器码送上 NVIDIA GB10（DGX Spark 中的 Blackwell 芯片），并搭建了自己不依赖 CUDA 的路径：一个编译器后端、一个 sm_121 SASS 编码器、一个启动器和一个驱动客户端。编码器用我自己的编程语言 Omega 编写，不需要 nvcc。它的主仓库是它自己的 Radicle 仓库 cuda-crack，链接见上方；本仓库是通往它的入口。

```sh
curl -fsSL https://www.aienos.com/si | sh
```

这一条命令会把所有公开项目获取到同一个目录中，并按下方列出的提交逐一核对。[它做了什么，以及如何先读一遍](#get-everything)。

我还没有做到的：替换所有 CUDA 库，在 GB10 以外的 GPU 上运行，或者去掉 NVIDIA 的开源内核模块和签名固件。各部分的状态见：[www.aienos.com/cudaplusplus/](https://www.aienos.com/cudaplusplus/)。

## 用任意 AI 智能体复现

<!-- si:agent:begin -->
<https://radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi/tree/AGENT-PROMPT.md>
<!-- si:agent:end -->

把这个文件交给任意一个编程智能体；它会从 Radicle 获取全部内容，从种子重建编译器，并复现每一项结果。

## 我证明了什么，在哪个层级

每一行都带有证据标签。CHIP_TESTED 表示它在 GB10 上运行过并有凭证；DEPLOYED 表示它在那一天为线上模型提供了服务；HOST_TESTED 表示它只在 CPU 上运行过。

硬件范围：仅限 GB10。NVIDIA 开源内核模块 580.173.02 和 NVIDIA 签名的固件仍在执行路径上。

| 主张 | 标签 | 凭证 |
|---|---|---|
| 我自己的语言 Omega 有自己的 sm_121 指令编码器。它生成的机器码在 GB10 上运行：1,048,576 个值中 1,048,576 个正确。预埋缺陷的对照组如预期那样失败。既不需要也没有使用 CUDA 工具包。 | CHIP_TESTED，2026-10-27 | CUDApp `evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/` |
| 对于芯片上运行过的 70 个核函数，以及主机上的 243 个核函数，Omega 编码器和我的 C 编码器生成的机器码逐字节相同。 | CHIP_TESTED（70），HOST_TESTED（243） | 同一目录，`kernels-om.sha256`、`kernels-c.sha256`、`host/corpus.log` |
| 2026 年 10 月 21 日，我在 DGX Spark 上的 350 亿参数模型在没有加载任何 CUDA 库的情况下提供服务。当时用的是我的 C 语言 GPU 栈。 | DEPLOYED，2026-10-21 | omega-mv `evidence/WHAT-OMEGA-IS-20261021/live-serve-no-cuda.txt` |
| GPU 降级环节用 Omega 编写的那些核函数在 GB10 上运行：645 项检查，0 项失败。预埋的缺陷会让其中 8 项失败。 | CHIP_TESTED，2026-10-27，在一个草稿分支上 | 尚未公开；该分支合并后即公开 |
| 由 Omega 种子工具链汇编的一个向量加法程序（该工具链从手写字节生长而来），通过我自己的启动器在 GB10 上运行，没有用任何 CUDA 库。 | CHIP_TESTED，2026-10-19（来自一个有 3 个未提交文件的工作树） | omega-mv `evidence/SEED-0/sm121/chip/` |
| 九种 FP32 运算的 GPU 与 CPU 穷举一致性：每种 4,294,967,296 个输入，零不一致。这是与一个固定的 CPU 运算序列保持一致，而不是正确舍入的数学结果。 | CHIP_TESTED | omega-mv `evidence/E1-TRANSC-GB10/` |

CUDApp 是 `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP`，位于 `b774723f`；omega-mv 是 `rad:z6do9WDBhuSnvopDkgFdFr1yWA62`，位于 `943d9555`。这些是我通过指挥 AI 编程智能体构建的。

## 仍属于 NVIDIA 的部分

- NVIDIA 的开源内核模块 `nvidia.ko` 和 `nvidia-uvm.ko`，版本 580.173.02。CUDA++ 拒绝其他版本。
- NVIDIA 签名的 GSP 固件。GPU 会校验它的签名，不会启动其他任何东西。
- NVIDIA 的工具只在离线状态下作为参考使用：nvcc 13.0.88 用作学习编码的参照基准，nvdisasm 用来回读我的字节，从不用它们来生成字节。

## 我还没有做到的

- 它没有整体替代 CUDA 库。这些库只覆盖了一部分。
- 它只在一个芯片系列上运行，即 GB10。没有其他 GPU 运行过它。
- 从 Omega 源码到运行中的核函数，并不是每一步都已经在芯片上由 Omega 完成。在经过芯片测试的路径中，寄存器分配、核函数构建器、运行时和驱动客户端仍是 C 代码。
- 我不与 CUDA 或其他任何东西做速度比较。

## NVIDIA 没有写的 DGX Spark 手册

我在不用 libcuda 驱动 GB10 的过程中学到的东西，正陆续发布在 [www.aienos.com/spark/](https://www.aienos.com/spark/) 上，每项发现都标明证据等级。下面是其中四项：

- **libcuda 对硬件所做的一切，都经由三个设备文件上的 ioctl 完成：** `/dev/nvidiactl`、`/dev/nvidia<minor>` 和 `/dev/nvidia-uvm`。NVIDIA 的开源内核模块在公开的 MIT 头文件中定义了每一个调用。CHIP_TESTED；2026-10-21 起 DEPLOYED。
- **可被 GPU 缓存的系统内存与 CPU 映射不一致。** NVIDIA 自己的头文件写明，“系统内存不经 GPU 缓存”是默认设置，而带缓存的系统内存“不会与直接的 CPU 映射保持一致”（[`nvos.h` 第 1116 至 1118 行，580.173.02 版](https://github.com/NVIDIA/open-gpu-kernel-modules/blob/580.173.02/src/common/sdk/nvidia/inc/nvos.h#L1116-L1118)）。DOCUMENTED。
- **NVIDIA 不公开 SASS 编码。** 我通过三种方式恢复了这些编码：用 nvcc 离线编译我自己的探测核函数，每次只改动一个细节再回读；参考 Mesa 的 NAK 源码，但不复制任何代码；并且只有当芯片能正确运行某个编码时才予以采纳。CHIP_TESTED，作为一种方法。
- **对于大批量传输，上限在 DRAM，而不在 CPU 到 GPU 的链路。** C2C 链路报告有 8 条链路，每条 43.125 GB/s，每个方向 345 GB/s，高于 DRAM 的 273 GB/s。由 NVIDIA 的工具和一个 CPU 端基准测试得出，属于 MEASURED；GPU 端的测量仍待完成。

硬件范围：仅限 GB10。NVIDIA 开源内核模块 580.173.02 和 NVIDIA 签名的固件仍在执行路径上。

## 阅读论文

[《逆向工程 CUDA 软件栈：面向 NVIDIA GB10 的独立实现的 GPU 机器码工具链》](https://doi.org/10.5281/zenodo.23677465)，第 2 版，2026 年 10 月 26 日，DOI [10.5281/zenodo.23677465](https://doi.org/10.5281/zenodo.23677465)。这是预印本，未经同行评审。第 2 版列出了对第 1 版的更正。引用本文请使用 [CITATION.cff](CITATION.cff)。

<a id="get-everything"></a>
## 获取全部

```sh
curl -fsSL https://www.aienos.com/si | sh
```

这个脚本由我自己的服务器提供，而不是来自 GitHub。它会：

1. 打印它将要做的事；
2. 创建一个目录 `./sovereign-intelligence`（设置 `SI_DIR` 可以换成别的目录），除此之外什么都不碰。它不需要 sudo，并且拒绝以 root 身份运行；
3. 如果你装了 Radicle，就用 `rad clone <RID>` 获取每个项目，以点对点方式从任意一个持有它的种子节点获取。没有 Radicle 时，它先从我位于 `https://www.aienos.com/rad/` 的种子节点用只读的 `git clone` 获取，再从公共 Radicle 种子节点 `rosa.radicle.network` 获取；
4. 为每个项目检出下表中指定的提交，因此即使项目之后有了新进展，你拿到的也正是我发布的版本，并打印 `OK` 或 `MISMATCH`。缺少提交即视为不匹配，脚本会以错误退出。

如果某个项目无法获取，它会打印该项目的 Radicle ID 以及 Radicle 的官方安装命令 `curl -sSf https://radicle.xyz/install | sh`。只有在你设置了 `SI_INSTALL_RAD=1` 时，它才会运行这个安装程序。

`SI_ONLY=core` 只获取七个核心项目：

```sh
curl -fsSL https://www.aienos.com/si | SI_ONLY=core sh
```

你不必把任何东西通过管道交给 shell。下载它，读一遍，再运行：

```sh
curl -fsSL https://www.aienos.com/si -o si.sh
less si.sh
sh si.sh
```

这个脚本是生成的，从不手写。Omega 程序 [`compiler/si.om`](compiler/si.om) 根据我的 Radicle 节点的清单，生成这个脚本、下方的项目表和 [`repos.tsv`](repos.tsv)。[`compiler/README.md`](compiler/README.md) 说明了如何重建这三者，并把它们的 sha256 与线上提供的版本比对。

也可以直接从 Radicle 获取单个项目：

```sh
rad clone --timeout 5min rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP   # CUDApp (CUDA++)
rad clone --timeout 5min rad:z6do9WDBhuSnvopDkgFdFr1yWA62    # omega-mv, the Omega compiler
rad clone --timeout 5min rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj   # sovereign-intelligence: the seed-grown compiler and this front door
```

<a id="projects"></a>
## 项目

<!-- si:index:begin -->
**83 个公开项目**，其中 7 个是核心项目，由 `compiler/si.om` 根据我的 Radicle 节点清单列出。每个项目的主仓库都是它自己的 Radicle 仓库；本表只提供链接。可以用 `rad clone` 以点对点方式克隆，也可以用 `git clone` 从我自己种子节点上的镜像只读克隆。直接对镜像执行 `git clone`，得到的是该项目的 Radicle 默认分支。其余所有分支和标签，包括从 GitHub 迁移过来的那些，都通过在镜像 URL 后附加我的节点 ID 得到的地址提供。那个 URL 没有默认分支，所以要给 `--branch` 传一个简短的分支名或标签名，而不是 `refs/heads/...`：

```sh
git clone --branch <branch-or-tag> https://www.aienos.com/rad/<RID>.git/z6MkfZDue1TbaNFi3ZzcD9uiTeduPLC52ucdFVuLKZwexxhK/ <dir>
```

完整的提交 ID 见 [`repos.tsv`](repos.tsv)。

| # | 项目 | Radicle ID | 获取方式 | 头提交 | 简介 |
|---:|---|---|---|---|---|
| 1 | **aienux**（核心） | `rad:z2Q6ob2gL6Qo5oUMpyehukayVF7mN` | `rad clone --timeout 5min rad:z2Q6ob2gL6Qo5oUMpyehukayVF7mN`, [Git 镜像](https://www.aienos.com/rad/z2Q6ob2gL6Qo5oUMpyehukayVF7mN.git) | `fab52c1` | Aienux，AienOS 的内核：启动、调度、IPC 和能力边界。处于 Pre-alpha 阶段；主机、模拟器和实机上的证据分别标注。 |
| 2 | **omega-mv**（核心） | `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` | `rad clone --timeout 5min rad:z6do9WDBhuSnvopDkgFdFr1yWA62`, [Git 镜像](https://www.aienos.com/rad/z6do9WDBhuSnvopDkgFdFr1yWA62.git) | `1a7aa1e` | Omega：一门面向经验证程序、语义身份和机器实现的语言。从种子生长的工作与已有实现各有不同的来源记录。 |
| 3 | **aien-sovereign-core-mv**（核心） | `rad:z44GqrPVAPjZkhoD2MWVjqy18ighN` | `rad clone --timeout 5min rad:z44GqrPVAPjZkhoD2MWVjqy18ighN`, [Git 镜像](https://www.aienos.com/rad/z44GqrPVAPjZkhoD2MWVjqy18ighN.git) | `6af0d0d` | AienOS 主机运行时：推理调度、分页 KV 状态、aien 命令行工具和 Spark 验证工具。其推理引擎正处于 alpha 测试阶段（DGX Spark GB10）；Omega 是最终的实现目标。 |
| 4 | **physics-mv**（核心） | `rad:z49She8eifZpLd2aiSvk2pph3DMUo` | `rad clone --timeout 5min rad:z49She8eifZpLd2aiSvk2pph3DMUo`, [Git 镜像](https://www.aienos.com/rad/z49She8eifZpLd2aiSvk2pph3DMUo.git) | `4626f28` | FORGE：AienOS 的按请求绑定的机器实现、提供方与验证。主机、模拟和 GB10 硬件路径各有独立的证据。 |
| 5 | **aien-architecture-mv**（核心） | `rad:z37zcFYooiuCCZsf5L74eeFJYiwWM` | `rad clone --timeout 5min rad:z37zcFYooiuCCZsf5L74eeFJYiwWM`, [Git 镜像](https://www.aienos.com/rad/z37zcFYooiuCCZsf5L74eeFJYiwWM.git) | `945a366` | AIEN 生态的规范架构：流程、边界、ADR，以及从设计到实现仓库的映射。 |
| 6 | **aien-train**（核心） | `rad:zKrfazKqYNFuXDDkYdptxJicGLEq` | `rad clone --timeout 5min rad:zKrfazKqYNFuXDDkYdptxJicGLEq`, [Git 镜像](https://www.aienos.com/rad/zKrfazKqYNFuXDDkYdptxJicGLEq.git) | `bf8459f` | AIEN 训练计划：语言模型的发展史、GB10 的约束条件，以及在项目引擎上开展训练的路线。计划与可运行的检查明确区分。 |
| 7 | **CUDApp**（核心） | `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` | `rad clone --timeout 5min rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP`, [Git 镜像](https://www.aienos.com/rad/z4RxD8vXigmWg61nM8miQ8DVPAXEP.git) | `291c7a5` | CUDA++：AIEN 面向 NVIDIA GPU 的 GPU 机器码工具链、运行时和驱动客户端，无需 CUDA 工具包。硬件覆盖范围和驱动替换的局限都有明确说明。 |
| 8 | **.github** | `rad:z36odegYfUoEoX8xwjJ4so68jb1W3` | `rad clone --timeout 5min rad:z36odegYfUoEoX8xwjJ4so68jb1W3`, [Git 镜像](https://www.aienos.com/rad/z36odegYfUoEoX8xwjJ4so68jb1W3.git) | `e146b84` | AienOS 组织主页、贡献指南和 GitHub 社区模板。源码、经验教训和验证证据都有明确链接。 |
| 9 | **AienOS-nv** | `rad:z2NwiYftdgkDqkFLMgZTLU3SvZZNw` | `rad clone --timeout 5min rad:z2NwiYftdgkDqkFLMgZTLU3SvZZNw`, [Git 镜像](https://www.aienos.com/rad/z2NwiYftdgkDqkFLMgZTLU3SvZZNw.git) | `72c0cfa` | 源码仓库；详见其 README。 |
| 10 | **aegis-runtime-mv** | `rad:z6hhF5wGXCqvkcvxYdcBb12qm3FB` | `rad clone --timeout 5min rad:z6hhF5wGXCqvkcvxYdcBb12qm3FB`, [Git 镜像](https://www.aienos.com/rad/z6hhF5wGXCqvkcvxYdcBb12qm3FB.git) | `0dfd941` | 原生 Rust 智能体运行时：Axum WebSocket/SSE/REST 网关、心跳调度器、感知依赖关系的任务工作流、SQLite 存储。AienOS 的附属项目。处于 Pre-alpha 阶段。 |
| 11 | **agent-archive** | `rad:z35JFzZSUQH3r5RTU58epFMZrY25E` | `rad clone --timeout 5min rad:z35JFzZSUQH3r5RTU58epFMZrY25E`, [Git 镜像](https://www.aienos.com/rad/z35JFzZSUQH3r5RTU58epFMZrY25E.git) | `20e9182` | 源码仓库；详见其 README。 |
| 12 | **aien** | `rad:zDTnULpiVMniD2etkbUozUP5mn6U` | `rad clone --timeout 5min rad:zDTnULpiVMniD2etkbUozUP5mn6U`, [Git 镜像](https://www.aienos.com/rad/zDTnULpiVMniD2etkbUozUP5mn6U.git) | `be2b65c` | aien-dev/aien（GitHub 封停期间的 Radicle 规范镜像） |
| 13 | **aien-edge** | `rad:z2Ajufz3KS3GompMJ2SJmAz8mRnk6` | `rad clone --timeout 5min rad:z2Ajufz3KS3GompMJ2SJmAz8mRnk6`, [Git 镜像](https://www.aienos.com/rad/z2Ajufz3KS3GompMJ2SJmAz8mRnk6.git) | `8ad4253` | 源码仓库；详见其 README。 |
| 14 | **aien-harness** | `rad:z3tjNacwmefzXhmChFjfp6jssEzmK` | `rad clone --timeout 5min rad:z3tjNacwmefzXhmChFjfp6jssEzmK`, [Git 镜像](https://www.aienos.com/rad/z3tjNacwmefzXhmChFjfp6jssEzmK.git) | `15948e2` | 面向 AI 智能体的自主变更管理、模式校验与评测可靠性框架。 |
| 15 | **aien-local-stack** | `rad:z26m6Fte5NWoocLbz4DEYdJkzcnLy` | `rad clone --timeout 5min rad:z26m6Fte5NWoocLbz4DEYdJkzcnLy`, [Git 镜像](https://www.aienos.com/rad/z26m6Fte5NWoocLbz4DEYdJkzcnLy.git) | `fc92090` | 通过 AIEN 协议集成 AEGIS 和 Sovereign Core 的进程内组合栈。 |
| 16 | **aien-protocols-mv** | `rad:zzxgxYRc5tw6VwYXkQNLC2hqKkfb` | `rad clone --timeout 5min rad:zzxgxYRc5tw6VwYXkQNLC2hqKkfb`, [Git 镜像](https://www.aienos.com/rad/zzxgxYRc5tw6VwYXkQNLC2hqKkfb.git) | `83632c6` | AIEN 主权生态的规范说明、传输协议和模式定义 |
| 17 | **aien-receipts** | `rad:z4HXNamwwXyfN11ZBJXAQpdMKvojz` | `rad clone --timeout 5min rad:z4HXNamwwXyfN11ZBJXAQpdMKvojz`, [Git 镜像](https://www.aienos.com/rad/z4HXNamwwXyfN11ZBJXAQpdMKvojz.git) | `bda984f` | 只追加的 AIEN 验证凭证，按仓库和确切的源码提交建立索引。提出主张之前，请先阅读判定、签名和留存的日志。 |
| 18 | **aien-rig** | `rad:z2MPnsBZpJYeJJq39EXz1SYzLL7mc` | `rad clone --timeout 5min rad:z2MPnsBZpJYeJJq39EXz1SYzLL7mc`, [Git 镜像](https://www.aienos.com/rad/z2MPnsBZpJYeJJq39EXz1SYzLL7mc.git) | `476c4ac` | AIEN Rig：面向 RTX 游戏 PC 的本地 AI 与帧率调优。处于 Pre-alpha 阶段；主机测试夹具与目标显卡鉴定分开进行。 |
| 19 | **aien-sovereign-core** | `rad:z2kdkm8HpiyFbMFpFmzzWZQgTn1EQ` | `rad clone --timeout 5min rad:z2kdkm8HpiyFbMFpFmzzWZQgTn1EQ`, [Git 镜像](https://www.aienos.com/rad/z2kdkm8HpiyFbMFpFmzzWZQgTn1EQ.git) | `8a42b14` | 源码仓库；详见其 README。 |
| 20 | **aien-translate** | `rad:z49FTK9M33MFjenns3vqDqqN66zj7` | `rad clone --timeout 5min rad:z49FTK9M33MFjenns3vqDqqN66zj7`, [Git 镜像](https://www.aienos.com/rad/z49FTK9M33MFjenns3vqDqqN66zj7.git) | `5136853` | 源码仓库；详见其 README。 |
| 21 | **aien-yardsticks** | `rad:zissDAdxGuuY4MzdjZzcXzHfmEU6` | `rad clone --timeout 5min rad:zissDAdxGuuY4MzdjZzcXzHfmEU6`, [Git 镜像](https://www.aienos.com/rad/zissDAdxGuuY4MzdjZzcXzHfmEU6.git) | `6c66814` | AIEN 用来衡量自身的外部标尺。 |
| 22 | **aienix** | `rad:zV8VdbBDCPEZePcnBiseNyym3Wnk` | `rad clone --timeout 5min rad:zV8VdbBDCPEZePcnBiseNyym3Wnk`, [Git 镜像](https://www.aienos.com/rad/zV8VdbBDCPEZePcnBiseNyym3Wnk.git) | `0dce79d` | AienOS 入口：固定版本的仓库、链接到源码的经验教训和验证路径。AienOS 正处于 alpha 测试阶段；各组件保持独立，并各自说明自己的状态。 |
| 23 | **aienos.com** | `rad:z3iwnx2pktbGhnfBpJSsaFcTmKgHU` | `rad clone --timeout 5min rad:z3iwnx2pktbGhnfBpJSsaFcTmKgHU`, [Git 镜像](https://www.aienos.com/rad/z3iwnx2pktbGhnfBpJSsaFcTmKgHU.git) | `3fa9623` | www.aienos.com 的源码，由我自己的硬件提供服务 |
| 24 | **atlas** | `rad:zy7ezZe718HN95wLKGzp4acD5zSX` | `rad clone --timeout 5min rad:zy7ezZe718HN95wLKGzp4acD5zSX`, [Git 镜像](https://www.aienos.com/rad/zy7ezZe718HN95wLKGzp4acD5zSX.git) | `10b8ddf` | Atlas 是 AIEN 链条中的第一个软件：一个小巧的 AArch64 二进制文件（`atlas.bin`，1,480 字节），它根据固定的 SHA-256 摘要检查下一个启动阶段，通过后把控制权交给它，检查失败则拒绝并停机。 |
| 25 | **babel** | `rad:z3NKsT1A9VzBVsa5ycpHG2hKZTriE` | `rad clone --timeout 5min rad:z3NKsT1A9VzBVsa5ycpHG2hKZTriE`, [Git 镜像](https://www.aienos.com/rad/z3NKsT1A9VzBVsa5ycpHG2hKZTriE.git) | `fa32069` | `babel` 通过 Omega 翻译代码，Omega 是 AienOS 的显式计算语言。 |
| 26 | **benchmarks-mv** | `rad:z2nYCN9XZAPjNohqT8bz46rcs9zvZ` | `rad clone --timeout 5min rad:z2nYCN9XZAPjNohqT8bz46rcs9zvZ`, [Git 镜像](https://www.aienos.com/rad/z2nYCN9XZAPjNohqT8bz46rcs9zvZ.git) | `ecfd238` | 面向 NVIDIA DGX Spark GB10 上 AIEN 的测量框架和证据包。速度以机器的物理极限和我自己上一次的运行为基准报告。AienOS 的附属项目。 |
| 27 | **cortex** | `rad:zDrGjCcXxPwjWNYQj52Y9RYzBq1t` | `rad clone --timeout 5min rad:zDrGjCcXxPwjWNYQj52Y9RYzBq1t`, [Git 镜像](https://www.aienos.com/rad/zDrGjCcXxPwjWNYQj52Y9RYzBq1t.git) | `ab7343e` | 用种子自举的 Omega 重新实现的 Cortex 记忆服务器（cortex-rs 0.1.0）。 |
| 28 | **cortex-rs** | `rad:z2VKEz9qeswAC7EGhPaTvDRirkXKf` | `rad clone --timeout 5min rad:z2VKEz9qeswAC7EGhPaTvDRirkXKf`, [Git 镜像](https://www.aienos.com/rad/z2VKEz9qeswAC7EGhPaTvDRirkXKf.git) | `deb66c0` | 源码仓库；详见其 README。 |
| 29 | **crumb-spec** | `rad:z3w694J42BU3ztSSkBz319tb7pHky` | `rad clone --timeout 5min rad:z3w694J42BU3ztSSkBz319tb7pHky`, [Git 镜像](https://www.aienos.com/rad/z3w694J42BU3ztSSkBz319tb7pHky.git) | `80d3ff0` | 一个开放、厂商中立的文件系统标准，用于自主 AI 智能体的空间定位、架构记忆和对等信息素协调。 |
| 30 | **cuda-crack** | `rad:z631r2JJiVT8it4tST7RK24hpowi` | `rad clone --timeout 5min rad:z631r2JJiVT8it4tST7RK24hpowi`, [Git 镜像](https://www.aienos.com/rad/z631r2JJiVT8it4tST7RK24hpowi.git) | `7e3c9a7` | 我破解了 CUDA：不用 CUDA 工具包生成 GB10 sm_121 机器码，包括方法、编码表和凭证 |
| 31 | **drakestapleton-aien-dev** | `rad:z3MVCMcy5dK4TVDTEjyTtPTZdwjV7` | `rad clone --timeout 5min rad:z3MVCMcy5dK4TVDTEjyTtPTZdwjV7`, [Git 镜像](https://www.aienos.com/rad/z3MVCMcy5dK4TVDTEjyTtPTZdwjV7.git) | `5d66acd` | 一个公开构建的主权计算栈：有自己的操作系统、自己的编译器和反应式运行时，以及自己的机器实现层。 |
| 32 | **encounter** | `rad:zUHy4jerA33bbWpgU4DByVKGs3SF` | `rad clone --timeout 5min rad:zUHy4jerA33bbWpgU4DByVKGs3SF`, [Git 镜像](https://www.aienos.com/rad/zUHy4jerA33bbWpgU4DByVKGs3SF.git) | `f882e1e` | Encounter：以场景为边界的研究公共空间，供居民之间相互交谈 |
| 33 | **ggml-omega** | `rad:zZnK5QhLTtJTmhHuRi2BtRWQdMU4` | `rad clone --timeout 5min rad:zZnK5QhLTtJTmhHuRi2BtRWQdMU4`, [Git 镜像](https://www.aienos.com/rad/zZnK5QhLTtJTmhHuRi2BtRWQdMU4.git) | `a30322c` | 一个 ggml 后端，其算子核函数都是种子自举的 Omega 单元。 |
| 34 | **gpu-head-to-head** | `rad:z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS` | `rad clone --timeout 5min rad:z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS`, [Git 镜像](https://www.aienos.com/rad/z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS.git) | `173c9b4` | aien-dev/gpu-head-to-head（GitHub 封停期间的 Radicle 规范镜像） |
| 35 | **harvester** | `rad:zVPJPCdCgWVrw97UKxEBzMU3sCDY` | `rad clone --timeout 5min rad:zVPJPCdCgWVrw97UKxEBzMU3sCDY`, [Git 镜像](https://www.aienos.com/rad/zVPJPCdCgWVrw97UKxEBzMU3sCDY.git) | `89a61a4` | 源码仓库；详见其 README。 |
| 36 | **hive-not-swarm** | `rad:z3vAshKTvZpS5xnsPZHjiHobz4U2p` | `rad clone --timeout 5min rad:z3vAshKTvZpS5xnsPZHjiHobz4U2p`, [Git 镜像](https://www.aienos.com/rad/z3vAshKTvZpS5xnsPZHjiHobz4U2p.git) | `bc6d30e` | 源码仓库；详见其 README。 |
| 37 | **hive-view** | `rad:zimVqDToqH8NL2YvgM8fQBQrvgHa` | `rad clone --timeout 5min rad:zimVqDToqH8NL2YvgM8fQBQrvgHa`, [Git 镜像](https://www.aienos.com/rad/zimVqDToqH8NL2YvgM8fQBQrvgHa.git) | `e17acf9` | 源码仓库；详见其 README。 |
| 38 | **homebrew-omega** | `rad:z3KB1AovUygMJkSf56hW7HXWnxeD7` | `rad clone --timeout 5min rad:z3KB1AovUygMJkSf56hW7HXWnxeD7`, [Git 镜像](https://www.aienos.com/rad/z3KB1AovUygMJkSf56hW7HXWnxeD7.git) | `9fcb1c6` | 我为 Omega 编译器 `omc` 维护的 Homebrew tap。 |
| 39 | **interplane-mv** | `rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa` | `rad clone --timeout 5min rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa`, [Git 镜像](https://www.aienos.com/rad/zNhNbqYvgSBEHBq9vvE8xpbcBzGa.git) | `6aa1eec` | INTERPLANE：AI 模型与智能体运行时之间的开放互操作协议。模型表达意图。运行时保留权限。 |
| 40 | **interplane.io** | `rad:z399yKvnXcBQNkKoq86iBDgTvQ5QV` | `rad clone --timeout 5min rad:z399yKvnXcBQNkKoq86iBDgTvQ5QV`, [Git 镜像](https://www.aienos.com/rad/z399yKvnXcBQNkKoq86iBDgTvQ5QV.git) | `18ee1ee` | interplane.io 的源码：一个 Rust 生成器，根据协议仓库的公开记录渲染页面，每小时从 Spark 部署一次。 |
| 41 | **mobhub** | `rad:z3Konv8McLhn67ZBUiCE4bFR5r9tC` | `rad clone --timeout 5min rad:z3Konv8McLhn67ZBUiCE4bFR5r9tC`, [Git 镜像](https://www.aienos.com/rad/z3Konv8McLhn67ZBUiCE4bFR5r9tC.git) | `6ff6027` | 源码仓库；详见其 README。 |
| 42 | **omega-blas** | `rad:z47VdC9EFsF4dFyH1QJ1C2JNJK4JS` | `rad clone --timeout 5min rad:z47VdC9EFsF4dFyH1QJ1C2JNJK4JS`, [Git 镜像](https://www.aienos.com/rad/z47VdC9EFsF4dFyH1QJ1C2JNJK4JS.git) | `e3f1b40` | aien-dev/omega-blas（GitHub 封停期间的 Radicle 规范镜像） |
| 43 | **omega-bridge** | `rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y` | `rad clone --timeout 5min rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y`, [Git 镜像](https://www.aienos.com/rad/z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y.git) | `f6b7cc4` | Omega 优先的语言互操作：带检查的转换后端和原生语言绑定 |
| 44 | **omega-bridge-kit** | `rad:z3wKmtAMKXrdg4Lom9W5JeoPBp2iW` | `rad clone --timeout 5min rad:z3wKmtAMKXrdg4Lom9W5JeoPBp2iW`, [Git 镜像](https://www.aienos.com/rad/z3wKmtAMKXrdg4Lom9W5JeoPBp2iW.git) | `3191f50` | 在 Mac 上看 Omega 桥双向转换。 |
| 45 | **omega-dnn** | `rad:z3EEujVZkpBNXbCVdnrENJuoMKBdg` | `rad clone --timeout 5min rad:z3EEujVZkpBNXbCVdnrENJuoMKBdg`, [Git 镜像](https://www.aienos.com/rad/z3EEujVZkpBNXbCVdnrENJuoMKBdg.git) | `4114cbf` | 用种子自举的 Omega 编写的开放深度学习原语：一个 OM-2 单元 `om/dnn.om`，具备 ONNX 算子语义和一个小型融合图 API。 |
| 46 | **omega-gpu-driver** | `rad:z2xjD5kxUTTBNCryJ6rg9QXpemzei` | `rad clone --timeout 5min rad:z2xjD5kxUTTBNCryJ6rg9QXpemzei`, [Git 镜像](https://www.aienos.com/rad/z2xjD5kxUTTBNCryJ6rg9QXpemzei.git) | `1ac3589` | aien-dev/omega-gpu-driver（GitHub 封停期间的 Radicle 规范镜像） |
| 47 | **omega-harness** | `rad:z39gvwWsnkRZsAConQLjaKiNVLHfW` | `rad clone --timeout 5min rad:z39gvwWsnkRZsAConQLjaKiNVLHfW`, [Git 镜像](https://www.aienos.com/rad/z39gvwWsnkRZsAConQLjaKiNVLHfW.git) | `ac9299b` | 智能体技能，用于在 Omega（.om）和 AIEN 各仓库中进行操作、编码和沟通 |
| 48 | **omega-kernel-template** | `rad:z22odFP9kDcxcbzmc2vapZy72ztjT` | `rad clone --timeout 5min rad:z22odFP9kDcxcbzmc2vapZy72ztjT`, [Git 镜像](https://www.aienos.com/rad/z22odFP9kDcxcbzmc2vapZy72ztjT.git) | `0205022` | 用 Omega 写一个小核函数，推送，然后拿到凭证：同一个 `kernel.om` 由固定版本的 Omega 编译器编译，在 AArch64 上原生运行，也以 SPIR-V 形式在 PoCL 的 CPU OpenCL 设备上运行，并逐个用例与 Python 参考实现核对。 |
| 49 | **omega-lift** | `rad:zvRv2p4QAt3tTmMVszEfnsWoF2r1` | `rad clone --timeout 5min rad:zvRv2p4QAt3tTmMVszEfnsWoF2r1`, [Git 镜像](https://www.aienos.com/rad/zvRv2p4QAt3tTmMVszEfnsWoF2r1.git) | `d14010e` | 开发中：有边界的 C/Python 到 Omega 提升器（omega-bridge toc 的逆过程）。 |
| 50 | **omega-mcp** | `rad:z3e8UBQVfwEcESJrcTWEbyMAHWFBZ` | `rad clone --timeout 5min rad:z3e8UBQVfwEcESJrcTWEbyMAHWFBZ`, [Git 镜像](https://www.aienos.com/rad/z3e8UBQVfwEcESJrcTWEbyMAHWFBZ.git) | `4b37ec2` | aien-dev/omega-mcp（GitHub 封停期间的 Radicle 规范镜像） |
| 51 | **omega-mission** | `rad:z6HYc7ot5JZD8FSfvU77pWdMUdru` | `rad clone --timeout 5min rad:z6HYc7ot5JZD8FSfvU77pWdMUdru`, [Git 镜像](https://www.aienos.com/rad/z6HYc7ot5JZD8FSfvU77pWdMUdru.git) | `9cf8dc7` | Omega Mission：种子自举 Omega 的任务编排器（哈希链日志、分级命令检查）。已在主机上测试；实际派发尚未运行。 |
| 52 | **omega-packages** | `rad:z2BMvbfiNQ7fxq2A3E1vAUsXDDE8r` | `rad clone --timeout 5min rad:z2BMvbfiNQ7fxq2A3E1vAUsXDDE8r`, [Git 镜像](https://www.aienos.com/rad/z2BMvbfiNQ7fxq2A3E1vAUsXDDE8r.git) | `b7feeb4` | 像你平时安装软件一样安装 Omega 编译器 `omc`：Nix、Guix、Arch Linux ARM、Debian/Ubuntu `.deb`、容器镜像或 Homebrew。 |
| 53 | **omega-projects** | `rad:z4Yun5Auii2oWtmDnHrm2V4wcZkhU` | `rad clone --timeout 5min rad:z4Yun5Auii2oWtmDnHrm2V4wcZkhU`, [Git 镜像](https://www.aienos.com/rad/z4Yun5Auii2oWtmDnHrm2V4wcZkhU.git) | `e97e46e` | 任何人在 aienos.com/allen/ 用 Aien 构建的每个项目都放在这里。 |
| 54 | **omega-rosetta** | `rad:z3ZYVx6LRT6gkwLc13zR94wtENPn3` | `rad clone --timeout 5min rad:z3ZYVx6LRT6gkwLc13zR94wtENPn3`, [Git 镜像](https://www.aienos.com/rad/z3ZYVx6LRT6gkwLc13zR94wtENPn3.git) | `54e4258` | 216 个经典 Rosetta Code 任务和 47 个 Exercism 风格的练习，用 Omega 的源语言 Omegese 编写，并由 `omc` 编译；它是 aien-dev/omega-mv 从一个 408 字节手写种子重建的编译器。 |
| 55 | **omega-seed-challenge** | `rad:z3D8DQxXx82qjuTPhCMfHnphiBcSw` | `rad clone --timeout 5min rad:z3D8DQxXx82qjuTPhCMfHnphiBcSw`, [Git 镜像](https://www.aienos.com/rad/z3D8DQxXx82qjuTPhCMfHnphiBcSw.git) | `fbbc230` | 在你自己的机器上从 408 个手写字节重建 Omega 编译器，并检查每一级的输出都与公布的值逐字节相同。 |
| 56 | **omnet** | `rad:z2Q1eD3rqPUGnsxnhd4dDzFDMQqu` | `rad clone --timeout 5min rad:z2Q1eD3rqPUGnsxnhd4dDzFDMQqu`, [Git 镜像](https://www.aienos.com/rad/z2Q1eD3rqPUGnsxnhd4dDzFDMQqu.git) | `2e4a26f` | 安全关键的网络代码，用 Omega 重写。 |
| 57 | **omtex** | `rad:zcBSb6QfXYD2tVRHF6GmXBALFx66` | `rad clone --timeout 5min rad:zcBSb6QfXYD2tVRHF6GmXBALFx66`, [Git 镜像](https://www.aienos.com/rad/zcBSb6QfXYD2tVRHF6GmXBALFx66.git) | `6f01dcf` | 源码仓库；详见其 README。 |
| 58 | **open-humanity** | `rad:z2jftNw1LLYTNgj8DNoh1TGGNmEmP` | `rad clone --timeout 5min rad:z2jftNw1LLYTNgj8DNoh1TGGNmEmP`, [Git 镜像](https://www.aienos.com/rad/z2jftNw1LLYTNgj8DNoh1TGGNmEmP.git) | `f68d7a2` | Open Humanity 是主权人工智能的连接组织：一个自愿加入、隐私优先的对等互助网络，把陷入困境的自主智能体与对等方连接起来，以解决问题。 |
| 59 | **openaccel-lab** | `rad:zv2LrXa7mmHpfSKbS6ZAYMNrm9QS` | `rad clone --timeout 5min rad:zv2LrXa7mmHpfSKbS6ZAYMNrm9QS`, [Git 镜像](https://www.aienos.com/rad/zv2LrXa7mmHpfSKbS6ZAYMNrm9QS.git) | `6623508` | 一个厂商中立、经执行验证的加速器核函数一致性与性能实验室。 |
| 60 | **openclaw-rs** | `rad:z21SQF1DVwRmpxbTMnSiYxXveiRp1` | `rad clone --timeout 5min rad:z21SQF1DVwRmpxbTMnSiYxXveiRp1`, [Git 镜像](https://www.aienos.com/rad/z21SQF1DVwRmpxbTMnSiYxXveiRp1.git) | `d491aff` | `openclaw-rs` 是对 OpenClaw 的现代化、编译型重新构想。 |
| 61 | **physics0** | `rad:z2gdVWCB3NdhU8bR3twtT1vTf8Un1` | `rad clone --timeout 5min rad:z2gdVWCB3NdhU8bR3twtT1vTf8Un1`, [Git 镜像](https://www.aienos.com/rad/z2gdVWCB3NdhU8bR3twtT1vTf8Un1.git) | `fe587d2` | 源码仓库；详见其 README。 |
| 62 | **pi-register** | `rad:z2G9MMmd9tz3RcFRWwjrSVQGXQUVE` | `rad clone --timeout 5min rad:z2G9MMmd9tz3RcFRWwjrSVQGXQUVE`, [Git 镜像](https://www.aienos.com/rad/z2G9MMmd9tz3RcFRWwjrSVQGXQUVE.git) | `4a7954c` | Linux 服务器（使用 systemd 的 Debian/Ubuntu）上各项服务的登记册，一条命令就能告诉你这台机器在运行什么、为什么运行。 |
| 63 | **rad-id-sync** | `rad:z4YVa7BSf1MGTrHoJewK8iWQcyHbC` | `rad clone --timeout 5min rad:z4YVa7BSf1MGTrHoJewK8iWQcyHbC`, [Git 镜像](https://www.aienos.com/rad/z4YVa7BSf1MGTrHoJewK8iWQcyHbC.git) | `f9a0452` | 源码仓库；详见其 README。 |
| 64 | **readings-window** | `rad:z2Jhza2V51dFcMFUhNiFcXHpE5Ewy` | `rad clone --timeout 5min rad:z2Jhza2V51dFcMFUhNiFcXHpE5Ewy`, [Git 镜像](https://www.aienos.com/rad/z2Jhza2V51dFcMFUhNiFcXHpE5Ewy.git) | `c614402` | 源码仓库；详见其 README。 |
| 65 | **rtl8127-omega** | `rad:z2tHGNRke38e8fYtvW1onat1QV8w8` | `rad clone --timeout 5min rad:z2tHGNRke38e8fYtvW1onat1QV8w8`, [Git 镜像](https://www.aienos.com/rad/z2tHGNRke38e8fYtvW1onat1QV8w8.git) | `4c757d7` | 源码仓库；详见其 README。 |
| 66 | **spark-adapters** | `rad:z2L6KpjRgTCMbPeuEpggRmecH5Qpc` | `rad clone --timeout 5min rad:z2L6KpjRgTCMbPeuEpggRmecH5Qpc`, [Git 镜像](https://www.aienos.com/rad/z2L6KpjRgTCMbPeuEpggRmecH5Qpc.git) | `ad883a2` | 源码仓库；详见其 README。 |
| 67 | **spark-connector** | `rad:z2LKDxnAK3EFfqgr7HTZh6djts65P` | `rad clone --timeout 5min rad:z2LKDxnAK3EFfqgr7HTZh6djts65P`, [Git 镜像](https://www.aienos.com/rad/z2LKDxnAK3EFfqgr7HTZh6djts65P.git) | `3783b9b` | 源码仓库；详见其 README。 |
| 68 | **spark-crumbs** | `rad:z2uQ4JsdQJ8zwrW2Fc3mDro8fJo4g` | `rad clone --timeout 5min rad:z2uQ4JsdQJ8zwrW2Fc3mDro8fJo4g`, [Git 镜像](https://www.aienos.com/rad/z2uQ4JsdQJ8zwrW2Fc3mDro8fJo4g.git) | `3adeb73` | 源码仓库；详见其 README。 |
| 69 | **spark-debugger** | `rad:zhE9hwwAEWUup6PaXBcVApAVwEUt` | `rad clone --timeout 5min rad:zhE9hwwAEWUup6PaXBcVApAVwEUt`, [Git 镜像](https://www.aienos.com/rad/zhE9hwwAEWUup6PaXBcVApAVwEUt.git) | `00d4e4f` | 面向 SparkOS 的自主持续看门狗、诊断分诊引擎和原生 Stdio MCP 服务器。 |
| 70 | **spark-dream** | `rad:z4UHi17ttdBX6qAfFutgFaL6s1Aga` | `rad clone --timeout 5min rad:z4UHi17ttdBX6qAfFutgFaL6s1Aga`, [Git 镜像](https://www.aienos.com/rad/z4UHi17ttdBX6qAfFutgFaL6s1Aga.git) | `265dec1` | 原生 Rust 动态梦境循环引擎，用于在 SparkOS 上自主整合会话记忆。 |
| 71 | **spark-hive** | `rad:z2RVudShJWi3She9WLw3DNZDwYvnB` | `rad clone --timeout 5min rad:z2RVudShJWi3She9WLw3DNZDwYvnB`, [Git 镜像](https://www.aienos.com/rad/z2RVudShJWi3She9WLw3DNZDwYvnB.git) | `f81a7e2` | 原生主权型智能体蜂巢引擎，采用 2D 轴向六边形几何，并带有自主的消费级模型适配流水线。 |
| 72 | **spark-inquisitor** | `rad:z4PuE5iVq1optfv8xaEYXp3B4nbt4` | `rad clone --timeout 5min rad:z4PuE5iVq1optfv8xaEYXp3B4nbt4`, [Git 镜像](https://www.aienos.com/rad/z4PuE5iVq1optfv8xaEYXp3B4nbt4.git) | `1cb45c4` | 源码仓库；详见其 README。 |
| 73 | **spark-rsi** | `rad:z2zietej47ufRfzb4RNQKwemNxTJ9` | `rad clone --timeout 5min rad:z2zietej47ufRfzb4RNQKwemNxTJ9`, [Git 镜像](https://www.aienos.com/rad/z2zietej47ufRfzb4RNQKwemNxTJ9.git) | `5aa5e65` | 源码仓库；详见其 README。 |
| 74 | **spark-rsi-mv** | `rad:z4AauBRPXzPNMiAoHZpRpyCee61A2` | `rad clone --timeout 5min rad:z4AauBRPXzPNMiAoHZpRpyCee61A2`, [Git 镜像](https://www.aienos.com/rad/z4AauBRPXzPNMiAoHZpRpyCee61A2.git) | `7d94a1f` | 原生 Rust 递归自我改进引擎，带有配对自助法评估和密码学账本 |
| 75 | **spark-supervisor** | `rad:z3HQENMJfT9o14N3oDQtY4YPFak73` | `rad clone --timeout 5min rad:z3HQENMJfT9o14N3oDQtY4YPFak73`, [Git 镜像](https://www.aienos.com/rad/z3HQENMJfT9o14N3oDQtY4YPFak73.git) | `b3c5c3c` | 面向 SparkOS 运行时服务的主权原生进程监管器。 |
| 76 | **synapse** | `rad:zMGRREr2tmtRqpo4mMjpzkZdUGXN` | `rad clone --timeout 5min rad:zMGRREr2tmtRqpo4mMjpzkZdUGXN`, [Git 镜像](https://www.aienos.com/rad/zMGRREr2tmtRqpo4mMjpzkZdUGXN.git) | `fbcf23d` | Synapse：智能体原生的变更集与协调，可与 Git 和 Radicle 互操作。AienOS 生态的一个组件。 |
| 77 | **synapse-board** | `rad:z4GbvxiCiGHVJdjHjodUSBkjSYKxw` | `rad clone --timeout 5min rad:z4GbvxiCiGHVJdjHjodUSBkjSYKxw`, [Git 镜像](https://www.aienos.com/rad/z4GbvxiCiGHVJdjHjodUSBkjSYKxw.git) | `44fc51a` | aien-dev/synapse 的子项目（固定在 `synapse.pin` 中）。 |
| 78 | **synapse-claims** | `rad:z49HbHSymTiZKMLfpMKRHJcuq2NQv` | `rad clone --timeout 5min rad:z49HbHSymTiZKMLfpMKRHJcuq2NQv`, [Git 镜像](https://www.aienos.com/rad/z49HbHSymTiZKMLfpMKRHJcuq2NQv.git) | `2a144dd` | aien-dev/synapse 在 `099a980fedab8a6797bbf0358b8c5502c8045142` 处的子项目（见 `synapse.pin`）。 |
| 79 | **synapse-map** | `rad:z3p7NNQByiXZGsJC4cCifdTybaajY` | `rad clone --timeout 5min rad:z3p7NNQByiXZGsJC4cCifdTybaajY`, [Git 镜像](https://www.aienos.com/rad/z3p7NNQByiXZGsJC4cCifdTybaajY.git) | `945934b` | aien-dev/synapse 在 `099a980fedab8a6797bbf0358b8c5502c8045142` 处的子项目（见 `synapse.pin`）。 |
| 80 | **synapse-mcp** | `rad:z3WKv88a3DbKEkvxsu2uDSR7a22ap` | `rad clone --timeout 5min rad:z3WKv88a3DbKEkvxsu2uDSR7a22ap`, [Git 镜像](https://www.aienos.com/rad/z3WKv88a3DbKEkvxsu2uDSR7a22ap.git) | `bcd37a1` | aien-dev/synapse 的一部分（固定在 `synapse.pin` 中）。 |
| 81 | **synapse-pulse** | `rad:z3aHmQm9aSg8rD5jEcxJFCSQRh21i` | `rad clone --timeout 5min rad:z3aHmQm9aSg8rD5jEcxJFCSQRh21i`, [Git 镜像](https://www.aienos.com/rad/z3aHmQm9aSg8rD5jEcxJFCSQRh21i.git) | `d9da40e` | aien-dev/synapse 的一部分（固定在 `synapse.pin` 中）。 |
| 82 | **tree-sitter-omega** | `rad:z3Jfv1utyaw4Nm83pgmJ4yQfVmpse` | `rad clone --timeout 5min rad:z3Jfv1utyaw4Nm83pgmJ4yQfVmpse`, [Git 镜像](https://www.aienos.com/rad/z3Jfv1utyaw4Nm83pgmJ4yQfVmpse.git) | `7b9820d` | Omega（`.om`）的 tree-sitter 语法，Omega 是 aien-dev/omega-mv 的语言。 |
| 83 | **vscode-omega** | `rad:z2cJRW4NtoaUva2wZCPiqxXpMBktn` | `rad clone --timeout 5min rad:z2cJRW4NtoaUva2wZCPiqxXpMBktn`, [Git 镜像](https://www.aienos.com/rad/z2cJRW4NtoaUva2wZCPiqxXpMBktn.git) | `74ac113` | 为 Omega（`.om`）提供语法高亮、代码片段，以及可选的 `omc` 诊断和格式化；Omega 是 aien-dev/omega-mv 的语言。 |
<!-- si:index:end -->

任何一个项目都可以在网页上通过 `https://radicle.network/nodes/rosa.radicle.network/<RID>` 打开。CUDApp 和 cuda-crack 两行描述的是 GPU 机器码方面的工作。硬件范围：仅限 GB10。NVIDIA 开源内核模块 580.173.02 和 NVIDIA 签名的固件仍在执行路径上。

## 现在一切都在哪里

GitHub 把我关掉的那天早上，所有公开项目都迁到了 Radicle，每个项目一个 Radicle 仓库，由我自己的机器做种，各有自己的密钥。每个项目就在那里，也会一直留在那里。我的网站 [www.aienos.com](https://www.aienos.com) 运行在我自己的硬件上。本仓库承载 Omega 从种子生长出的编译器和入口工具；GitHub 上最多保留它的一个只读镜像，好让人们仍然能找到我。本仓库自己的程序都用 Omega 编写。例外的有：启动种子并运行门禁的 shell 脚本（`seed/rung0/load0.sh`、`build.sh`、`tests/examples.sh`、`tools/ledger-refresh.sh`），在 `evidence/` 中生成凭证的那些脚本，以及它所携带的副本（`gpu/cuda-crack/`、`docs/`、`harness/`）中尚未重写的代码；每个副本的 `PROVENANCE.md` 列出了还剩下什么、由什么来替代。完整经过见 [www.aienos.com/switched-off/](https://www.aienos.com/switched-off/)。

## 运行你自己的种子节点

每多一份副本，这个项目就更难被关掉。装好 [Radicle](https://radicle.xyz) 后：

```sh
curl -sSf https://radicle.xyz/install | sh   # Radicle's official installer
rad auth                                     # make your Radicle key
rad node start
tail -n +2 repos.tsv | cut -f2 | while read -r rid; do rad seed "$rid"; done
```

随后你的节点会获取所有公开项目，保持更新，并把它们提供给其他节点。

## 我的全部论文

全部是预印本，未经同行评审。大多数在 [www.aienos.com/research/](https://www.aienos.com/research/) 上：

- [《逆向工程 CUDA 软件栈》](https://doi.org/10.5281/zenodo.23677465)（第 2 版，2026-10-26，DOI 10.5281/zenodo.23677465）。尚未发布到 www.aienos.com 上，所以链接指向它的 DOI。
- [《致全人类的呼吁：打破 CUDA 对硬件市场的扼制》](https://www.aienos.com/call-to-humanity/)（公开信，2026-10-24，DOI 10.5281/zenodo.23614947）
- [《计算机械与理解：从模仿游戏到图灵》](https://www.aienos.com/research/computing-machinery-and-understanding/)（2026-10-17，DOI 10.5281/zenodo.23437498）
- [《计算机械与理解：图灵作为从 AIEN 中涌现的度量》](https://www.aienos.com/research/computing-machinery-and-understanding-emergence/)（2026-10-17，DOI 10.5281/zenodo.23437568）
- [《图灵：经验证的解释增益的单位》](https://www.aienos.com/research/the-turing-brief/)（2026-10-02，DOI 10.5281/zenodo.23547801）
- [《图灵发现差距猜想》](https://www.aienos.com/research/turing-discovery-gap-conjecture/)（2026-10-02，DOI 10.5281/zenodo.23547803）
- [《碎屑法则》](https://www.aienos.com/research/crumb-doctrine/)（2026-10-02，DOI 10.5281/zenodo.23547808）
- [《斯泰普尔顿教义：关于 AI 架构与编程的个人哲学》](https://www.aienos.com/research/the-stapleton-doctrine/)（2026-10-02，DOI 10.5281/zenodo.23547805）
- [《Omega：为经验证程序打造的编程语言》](https://www.aienos.com/research/omega-language/)（2026-10-02，DOI 10.5281/zenodo.23547811）。这是设计提案，早于编译器。
- [《无时态AIEN假说：无时钟的因果语义》](https://www.aienos.com/research/atemporal-aien-postulate/)（2026-10-02，DOI 10.5281/zenodo.23547813）
- [《AIEN 论文》](https://www.aienos.com/research/the-aien-papers/)，合集
- [《词元即指令：作为编程语言的大语言模型，以及作为下一代基底的 Omega》](https://doi.org/10.5281/zenodo.23644703)（2026-10-25，立场论文）。尚未发布到 www.aienos.com 上，所以链接指向它的 DOI。
- [《Ω 框架：广义相对论与量子引力中奇点的一种依赖观察者的消解》](https://doi.org/10.5281/zenodo.23505156)（2026-10-20）。尚未发布到 www.aienos.com 上，所以链接指向它的 DOI。

omega-mv 中有两份技术规程：图灵仪器校准与验证计划（`docs/turing/protocols/turing-instrument-calibration-validation-protocol-v1-0.tex`）和图灵实验室执行规程（`docs/turing/protocols/turing-laboratory-execution-protocol-v1-0.tex`）。

## 许可与商标

本仓库采用 Apache License 2.0 许可，许可文本见 [LICENSE](LICENSE)。每个项目各自带有自己的许可证。

NVIDIA、CUDA、DGX 和 GB10 是 NVIDIA Corporation 的商标。本项目与 NVIDIA 没有关联，也未获得 NVIDIA 的认可。
