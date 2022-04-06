local o = require "luci.sys"
local a, t, e
a = Map("parentcontrol", translate("家长控制"), translate("<b><font color=\"green\">利用防火墙iptables来管控上网时间、过滤网址和端口协议等。</font> </b></br>\
* 时间限制必须指定MAC地址。</br>*网址过滤指定“关键词/URL” 可以是字符串或网址。</br>*协议过滤：端口可以是端口范围如5000:5100或多端口5100,5110。" ))

a.template = "parentcontrol/index"
t = a:section(TypedSection, "basic", translate(""))
t.anonymous = true
e = t:option(DummyValue, "parentcontrol_status", translate("当前状态"))
e.template = "parentcontrol/parentcontrol"
e.value = translate("Collecting data...")


e = t:option(Flag, "enabled", translate("开启"))
e.rmempty = false

e = t:option(ListValue, "algos", translate("过滤力度"))
e:value("bm", "一般过滤")
e:value("kmp", "强效过滤")
e.default = "kmp"


e = t:option(ListValue, "control_mode",translate("网址过滤模式"), translate("儿童模式即黑名单：全网不允访问名单内容;自定义:单机设置不允许访问"))
e.rmempty = false
e:value("black_mode", "儿童模式")
--e:value("white_mode", "白名单")
e:value("custom_mode", "自定义")
e.default = "custom_mode"

t = a:section(TypedSection, "macbind3", translate("协议过滤"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'
e = t:option(Value, "macaddr", translate("黑名单MAC<font color=\"green\">(留空则过滤全部客户端)</font>"))
e.placeholder = "ALL"
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)
e = t:option(ListValue, "proto", translate("<font color=\"gray\">端口协议</font>"))
e.rmempty = false
e.default = 'tcp'
e:value("tcp", translate("TCP"))
e:value("udp", translate("UDP"))
e = t:option(Value, "sport", translate("<font color=\"gray\">源端口</font>"))
e.rmempty = true
e = t:option(Value, "dport", translate("<font color=\"gray\">目的端口</font>"))
e:value("",translate("PORT"))
e:value("80", "TCP-HTTP")
e:value("443", "TCP-HTTPS")
e:value("22", "TCP-SSH")
e:value("1723", "TCP-PPTP")
e:value("25", "TCP-SMTP")
e:value("110", "TCP-POP3")
e:value("21", "TCP-FTP21")
e:value("23", "TCP-TELNET")
e:value("53", "TCP-DNS53")
e:value("20", "UDP-FTP20")
e:value("1701", "UDP-L2TP")
e:value("69", "UDP-TFTP")
e:value("500", "UDP-IPSEC")
e:value("53", "UDP-DNS53")
e:value("161", "UDP-SNMP")
e.rmempty = true
e = t:option(Value, "timeon", translate("起控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.rmempty = true
e = t:option( Value, "timeoff", translate("停控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.rmempty = true
e = t:option(MultiValue, "daysofweek", translate("星期<font color=\"green\">(至少选一天，某天不选则该天不进行控制)</font>"))
e.optional = false
e.rmempty = false
e.default = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
e:value("Monday", translate("一"))
e:value("Tuesday", translate("二"))
e:value("Wednesday", translate("三"))
e:value("Thursday", translate("四"))
e:value("Friday", translate("五"))
e:value("Saturday", translate("六"))
e:value("Sunday", translate("日"))
return a



