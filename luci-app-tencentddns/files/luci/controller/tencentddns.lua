module("luci.controller.tencentddns",package.seeall)
function index()
entry({"admin", "network", "tencentddns"},cbi("tencentddns"),_("腾讯云DDNS"), 12)
end
