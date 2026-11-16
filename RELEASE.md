# 正式版构建

Actions → Signed Android release → Run workflow。需要仓库 Secrets：KEYSTORE_BASE64、KEYSTORE_PASSWORD、KEY_ALIAS、KEY_PASSWORD。

main 分支提交会构建并上传 smsforwarder-signed-release，其中包含正式签名 APK 和 SHA256SUMS.txt。推送 v* 标签会同时创建 GitHub Release。

可手工填写 version_name 和 version_code；默认版本名取项目当前版本（标签构建取去掉 v 的标签），版本号为该工作流运行编号加 1000。发布更新时请确保 version_code 大于已发布版本。

签名证书为 Lucian，SHA-256：EB:60:A9:7D:66:89:C0:0F:B2:32:07:E6:50:BE:4F:19:E8:49:E5:20:77:65:C0:5F:C9:69:F3:D4:85:DF:89:77。流程会校验此指纹、包名及非调试属性；Secrets 缺失或签名不符会失败。

更换签名后不能直接覆盖安装使用旧签名的同包名应用；请先备份数据。
