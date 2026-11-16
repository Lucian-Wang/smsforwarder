/*
 * 短信转发助手
 *
 * 著作权人：Lucian (https://lucian.wang/)
 * 开发者：Lucian
 *
 * Copyright (c) 2026 Lucian. All rights reserved.
 * 联系邮箱：im@lucian.wang
 */

package wang.lucian.smsforwarder

/**
 * 应用导出配置数据类
 *
 * 封装导出/导入所需的全部配置项，避免函数参数列表过长（原 16 个参数）。
 * 所有与配置导出相关的函数均使用此类作为参数载体。
 */
data class ExportConfig(
    val channels: List<Channel>,
    val keywordConfigs: List<KeywordConfig>,
    val showReceiverPhone: Boolean,
    val showSenderPhone: Boolean,
    val highlightVerificationCode: Boolean,
    val globalMessageTemplate: String? = null,
    val batteryReminderEnabled: Boolean,
    val lowBatteryReminderEnabled: Boolean,
    val highBatteryReminderEnabled: Boolean,
    val chargingReminderEnabled: Boolean,
    val batteryReminderChannelId: String?,
    val lowBatteryThreshold: Int,
    val highBatteryThreshold: Int,
    val customSim1Phone: String?,
    val customSim2Phone: String?,
    val startOnBoot: Boolean,
    val senderWhitelist: List<String> = emptyList(),
    val senderBlacklist: List<String> = emptyList(),
    val contentWhitelist: List<String> = emptyList(),
    val contentBlacklist: List<String> = emptyList()
)
