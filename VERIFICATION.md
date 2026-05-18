# OpenTenBase .deb 安装验证报告

**日期：** 2026-05-18
**验证人：** muzimu217
**Release 版本：** v5.0

---

## 一、验证环境

### 测试服务器 1

| 项目 | 配置 |
|------|------|
| 平台 | 腾讯 CloudStudio |
| OS | Ubuntu 24.04.2 LTS (Noble Numbat) |
| CPU | 32 核 |
| 内存 | 4GB |
| 磁盘 | 16GB |
| 用户 | root |

### 测试服务器 2

| 项目 | 配置 |
|------|------|
| 平台 | 腾讯 CloudStudio |
| OS | Ubuntu 24.04.2 LTS (Noble Numbat) |
| CPU | 多核 |
| 内存 | 8GB |
| 磁盘 | 20GB |
| 用户 | root |

---

## 二、验证步骤与结果

### 步骤 1：下载安装包

```bash
wget https://github.com/muzimu217/opentenbase-deb/releases/download/v5.0/opentenbase-5.0-ubuntu24.04-amd64.tar.gz
tar xzf opentenbase-5.0-ubuntu24.04-amd64.tar.gz
```

**结果：** 6 个 .deb 文件成功解压

```
libopentenbase-dev_5.0-1ubuntu1_amd64.deb   (1.5 MB)
opentenbase_5.0-1ubuntu1_all.deb            (2.2 KB)
opentenbase-client_5.0-1ubuntu1_amd64.deb   (737 KB)
opentenbase-contrib_5.0-1ubuntu1_amd64.deb  (1.4 MB)
opentenbase-doc_5.0-1ubuntu1_all.deb        (2.6 MB)
opentenbase-server_5.0-1ubuntu1_amd64.deb   (6.2 MB)
```

### 步骤 2：安装

```bash
apt update
apt install -y ./*.deb
```

**结果：** 6 个包全部安装成功，依赖自动解决（libossp-uuid16, libpqxx-7.8t64）

### 步骤 3：初始化集群

```bash
opentenbase-ctl init
```

**结果：** 成功初始化 GTM、Coordinator、Datanode

### 步骤 4：启动集群

```bash
opentenbase-ctl start
```

**结果：** 三节点全部启动成功

```
starting gtm
starting coord
registering GTM node in pgxc_node ...
registering coordinator node ...
registering datanode node ...
reloading connection pool ...
starting dn1
registering GTM node in pgxc_node ...
registering coordinator node ...
registering datanode node ...
reloading connection pool ...
propagating nodes to datanode ...
>> start complete
```

### 步骤 5：验证状态

```bash
opentenbase-ctl status
```

**结果：**

```
gtm:   RUNNING
dn1:   RUNNING
coord: RUNNING
```

### 步骤 6：验证数据库连接

```bash
opentenbase-psql -h 127.0.0.1 -p 5432 -U opentenbase -d postgres
```

**结果：** 连接成功，查询正常

```
PostgreSQL 10.0 @ OpenTenBase_v5.0 OpenTenBase V5.21 2026-05-17 15:25:22

 node_name  | node_type | node_port | node_host
------------+-----------+-----------+-----------
 gtm_master | G         |      6666 | 127.0.0.1
 coord1     | C         |      5432 | 127.0.0.1
 dn001      | D         |     15432 | 127.0.0.1

 count: 492 (pg_class)
```

---

## 三、验证结论

| 检查项 | 状态 |
|--------|------|
| .deb 包下载 | 通过 |
| 依赖自动解决 | 通过 |
| 安装成功 | 通过 |
| 集群初始化 | 通过 |
| 集群启动 | 通过 |
| GTM 注册 | 通过 |
| Coordinator 连接 | 通过 |
| Datanode 查询 | 通过 |

**结论：** OpenTenBase v5.0 .deb 安装包在 Ubuntu 24.04 上可正常安装和运行，已验证通过。

---

## 四、已知限制

1. **License 限制：** 开源版本为只读模式，写操作（CREATE TABLE, INSERT 等）需要企业版 license
2. **单机部署：** 当前配置仅支持单机多节点，跨机器部署需要修改配置
3. **系统要求：** 需要先执行 `apt update` 确保依赖库可用

---

## 五、安装命令汇总

```bash
# 完整安装流程
wget https://github.com/muzimu217/opentenbase-deb/releases/download/v5.0/opentenbase-5.0-ubuntu24.04-amd64.tar.gz
tar xzf opentenbase-5.0-ubuntu24.04-amd64.tar.gz
apt update
apt install -y ./*.deb
opentenbase-ctl init
opentenbase-ctl start
opentenbase-ctl status
```

---

**验证完成日期：** 2026-05-18
