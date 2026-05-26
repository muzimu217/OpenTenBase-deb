# OpenTenBase 长期运营维护计划

> 创建时间：2026-05-26
> 维护者：muzimu217

## 当前状态总览

| 模块 | 状态 | 说明 |
|------|------|------|
| 仓库结构 | DONE | config/debian/scripts/docs/test 分目录 |
| DEB 打包 | DONE | Ubuntu 20.04-25.04 + Debian 11-13 (7 目标) |
| RPM 打包 | DONE | Rocky/CentOS/Alma/Fedora/openEuler (8 目标) |
| ARM64 支持 | DONE | EulerOS 2.0 aarch64 手动验证通过 |
| CI 自动构建 | DONE | build-deb.yml + build-rpm.yml + release.yml |
| 多版本管理 | DONE | opentenbase-switch-version + 版本化路径 |
| Docker Compose | DONE | 一键集群部署 |
| 安装脚本 | DONE | install.sh 支持 --version + 自动检测发行版 |
| 文档 | DONE | 中英文安装/配置/故障排除/版本管理 |

---

## 待完成事项

### 阶段一：测试补全（1-2 周）

目标：所有 15 个发行版都通过多节点 CRUD 测试。

| 任务 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| 多节点测试脚本 | P0 | DONE | test/multi-node-test.sh |
| 版本切换测试脚本 | P0 | DONE | test/version-switch-test.sh |
| CI 全量测试工作流 | P0 | DONE | .github/workflows/test-all.yml |
| 跑通 DEB 多节点测试 | P0 | TODO | Ubuntu/Debian 全部 7 个目标 |
| 跑通 RPM 多节点测试 | P0 | TODO | Rocky/CentOS/Alma/Fedora/openEuler 全部 8 个目标 |
| 跑通版本切换测试 | P0 | TODO | 至少在 2 个发行版上验证 |
| 性能基准测试 | P2 | TODO | 10 万行插入/查询性能（TEST-CHECKLIST 第5节） |
| 故障恢复测试 | P2 | TODO | GTM/Datanode 重启后集群恢复 |
| 并发连接测试 | P2 | TODO | 10+ 并发连接稳定性 |

**执行方式：**
```bash
# 触发 CI 全量测试
gh workflow run test-all.yml

# 或在 Docker 中手动测试
docker run --rm -v ./packages:/packages ubuntu:24.04 bash -c "
  apt-get update && apt-get install -y sudo procps libatomic1
  bash /test/multi-node-test.sh
"
```

### 阶段二：APT/RPM 仓库搭建（2-4 周）

目标：用户可以 `curl -sSL setup.sh | sudo bash && apt install opentenbase` 一键安装。

| 任务 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| 申请域名 | P1 | TODO | opentenbase.org 或子域名 |
| 部署仓库服务器 | P1 | TODO | 2核4G，Nginx + reprepro |
| GPG 密钥生成 | P1 | TODO | 用于包签名 |
| APT 仓库配置 | P1 | TODO | reprepro + dists/pool 结构 |
| RPM 仓库配置 | P1 | TODO | createrepo + GPG 签名 |
| setup.sh 一键脚本测试 | P1 | TODO | scripts/setup-apt.sh 实际可用 |
| CI 自动发布到仓库 | P1 | TODO | release.yml 触发后自动更新仓库 |
| 仓库功能验证 | P1 | TODO | apt update + apt install 实际安装 |

**临时方案（无域名时）：**
- 用 GitHub Pages 托管 APT 仓库
- 用 GitHub Releases 直接下载安装

### 阶段三：打包规范化（2-4 周）

目标：符合 Debian/RPM 官方打包规范。

| 任务 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| 版本号规范 | P2 | TODO | 遵循 Debian policy (epoch:upstream-debian) |
| 依赖声明规范 | P2 | TODO | 最小依赖 vs 推荐依赖 |
| systemd 服务文件 | P2 | TODO | systemd/ 目录下已有模板，需完善 |
| 日志路径规范 | P2 | TODO | /var/log/opentenbase/ 统一 |
| 配置文件规范 | P2 | TODO | /etc/opentenbase/ 结构 |
| lintian/rpmlint 零警告 | P2 | TODO | 修复所有打包警告 |

### 阶段四：监控集成（1-2 月）

| 任务 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| Prometheus exporter | P2 | TODO | 导出 GTM/Coord/DN 指标 |
| Grafana dashboard | P2 | TODO | 预置监控面板 |
| 告警规则 | P2 | TODO | 节点宕机/延迟/连接数 |
| 健康检查脚本 | P2 | TODO | opentenbase-ctl healthcheck |

### 阶段五：上游贡献准备（3-6 月）

| 任务 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| 代码质量审查 | P3 | TODO | 补丁代码清理 |
| 测试覆盖率提升 | P3 | TODO | 覆盖所有发行版 + 边界场景 |
| 文档完善 | P3 | TODO | 贡献指南、架构文档 |
| 提交 PR 到 OpenTenBase 官方 | P3 | TODO | 打包系统合入上游 |

---

## 长期维护流程

### 版本发布流程

```
1. OpenTenBase 上游发布新版本
2. 更新 debian/changelog 版本号
3. 测试补丁兼容性（GTM fix, license bypass）
4. git tag v<version>
5. CI 自动构建 30 个目标
6. CI 自动运行 smoke test
7. 人工验证多节点 + CRUD
8. GPG 签名
9. 发布到 APT/RPM 仓库
10. 更新 GitHub Release
```

### 安全更新流程

```
1. 发现安全漏洞
2. 24 小时内发布修复
3. CI 自动构建 + 测试
4. 紧急发布到仓库
5. 通知用户更新
```

### 发行版新增流程

```
1. 新发行版发布（如 Ubuntu 26.04）
2. 在 CI matrix 中添加新目标
3. 测试构建是否成功
4. 测试安装 + 多节点 + CRUD
5. 更新 README 和文档
6. 发布新 release
```

---

## 资源需求

### 立即需要

| 资源 | 用途 | 预算 |
|------|------|------|
| GitHub Actions 额度 | CI 构建（当前免费 2000 分钟/月） | 免费 / $4/月 Pro |

### 中期需要

| 资源 | 用途 | 预算 |
|------|------|------|
| 域名 | APT/RPM 仓库 | ~$10/年 |
| GPG 密钥 | 包签名 | 免费 |
| 云服务器 | 托管仓库（2核4G） | ~$20/月 |

### 长期需要

| 资源 | 用途 | 预算 |
|------|------|------|
| CDN | 加速包下载 | 按量付费 |
| 监控服务器 | Prometheus + Grafana | 可复用仓库服务器 |

---

## 已知问题

| 问题 | 影响 | 解决方案 |
|------|------|----------|
| GTM CPU binding 在 ≤2 核失败 | 所有版本 | 已修复（patch 在源码中） |
| License 限制导致只读 | 所有版本 | 已修复（patch 在源码中） |
| pgsql-http 在 aarch64 编译失败 | ARM64 RPM | 已跳过该 contrib |
| serial 类型分布式表不自增 | 分片表 | 使用 int + 手动 id |
| 仅支持 SHARD 和 REPLICATION 分布 | 表创建 | 文档说明 |

---

**文档版本**: 1.0
**最后更新**: 2026-05-26
**维护者**: muzimu217
