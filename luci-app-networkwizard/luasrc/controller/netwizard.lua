-- Copyright 2019 X-WRT <dev@x-wrt.com>
-- Copyright 2022-2023 sirpdboy

module("luci.controller.netwizard", package.seeall)
function index()
	
	entry({"admin","netwizard"}).dependent = true
	entry({"admin","netwizard", "show"}, call("show_menu")).leaf = true
	entry({"admin","netwizard", "hide"}, call("hide_menu")).leaf = true

	if not nixio.fs.access("/etc/config/netwizard") then return end
	if not nixio.fs.access("/etc/config/netwizard_hide") then
	        e = entry({"admin","netwizard"}, alias("admin","netwizard"), _("Inital Setup"), 21)
		e.dependent = true
		-- e.acl_depends = { "luci-app-netwizard" }
	end
	entry({"admin","netwizard"}, cbi("netwizard/netwizard"), _("Inital Setup"), 21).dependent = true
end
