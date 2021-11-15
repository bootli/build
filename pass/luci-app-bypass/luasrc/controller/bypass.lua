module("luci.controller.bypass",package.seeall)
local fs=require"nixio.fs"
local http=require"luci.http"
CALL=luci.sys.call
EXEC=luci.sys.exec
function index()
	if not nixio.fs.access("/etc/config/bypass") then
		return
	end
	local e=entry({"admin","services","bypass"},firstchild(),_("Bypass"),2)
	e.dependent=false
	e.acl_depends={"luci-app-bypass"}
	entry({"admin","services","bypass","base"},cbi("bypass/base"),_("Base Setting"),1).leaf=true
	entry({"admin","services","bypass","servers"},arcombine(cbi("bypass/servers",{autoapply=true}),cbi("bypass/client-config")),_("Severs Nodes"),2).leaf=true
	entry({"admin","services","bypass","shunt"},cbi("bypass/shunt"),_("Shunt Setting"),3).leaf=true
	entry({"admin","services","bypass","control"},cbi("bypass/control"),_("Access Control"),4).leaf=true
	entry({"admin","services","bypass","domain"},cbi("bypass/domain"),_("Domain List"),5).leaf=true
	entry({"admin","services","bypass","advanced"},cbi("bypass/advanced"),_("Advanced Settings"),6).leaf=true
	if luci.sys.call("which ssr-server >/dev/null")==0 or luci.sys.call("which ss-server >/dev/null")==0 or luci.sys.call("which microsocks >/dev/null")==0 then
		entry({"admin","services","bypass","server"},arcombine(cbi("bypass/server"),cbi("bypass/server-config")),_("Server"),7).leaf=true
	end
	entry({"admin","services","bypass","log"},form("bypass/log"),_("Log"),8).leaf=true
	entry({"admin", "services", "bypass", "run"}, call("act_status"))
	entry({"admin", "services", "bypass", "checknet"}, call("check_net"))
	entry({"admin","services","bypass","refresh"},call("refresh"))
	entry({"admin","services","bypass","subscribe"},call("subscribe"))
	entry({"admin","services","bypass","ping"},call("ping"))
	entry({"admin","services","bypass","getlog"},call("getlog"))
	entry({"admin","services","bypass","dellog"},call("dellog"))
end

function act_status()
    local e = {}
    e.tcp = CALL('busybox ps -w | grep bypass-tcp | grep -v grep  >/dev/null ') == 0
    e.udp = CALL('busybox ps -w | grep bypass-udp | grep -v grep  >/dev/null') == 0
    e.smartdns = CALL("pidof smartdns-le >/dev/null")==0

    e.chinadns=CALL("pidof chinadns-ng >/dev/null")==0
    http.prepare_content('application/json')
    http.write_json(e)
end


function check_net()
	local r=0
	local u=http.formvalue("url")
	local p
	if CALL("nslookup www."..u..".com >/dev/null 2>&1")==0 then
		if u=="google" then p="/generate_204" else p="" end
		r=EXEC("curl -m 5 -o /dev/null -sw %{time_starttransfer} http://www."..u..".com"..p.." | awk '{printf ($1*1000)}'")
		if r~="0" then
			r=EXEC("echo -n "..r.." | sed 's/\\..*//'")
			if r=="0" then r="1" end
		end
	end
	http.prepare_content("application/json")
	http.write_json({ret=r})
end


function refresh()
	local set=http.formvalue("set")
	local icount=0
	local r
	if set=="0" then
		sret=CALL("curl -Lfso /tmp/gfw.b64 https://cdn.jsdelivr.net/gh/fangxx3863/overwall_list/GFW_List")
		if sret==0 then
			CALL("/usr/share/bypass/gfw")
			icount=EXEC("cat /tmp/gfwnew.txt | wc -l")
			if tonumber(icount)>1000 then
				oldcount=EXEC("cat /tmp/bypass/gfw.list | wc -l")
				if tonumber(icount)~=tonumber(oldcount) then
					EXEC("cp -f /tmp/gfwnew.txt /tmp/bypass/gfw.list && /etc/init.d/bypass restart >/dev/null 2>&1")
					r=tostring(tonumber(icount))
				else
					r="0"
				end
			else
				r="-1"
			end
			EXEC("rm -f /tmp/gfwnew.txt ")
		else
			r="-1"
		end
	elseif set=="1" then
		sret=CALL("A=`curl -Lfsm 9 https://cdn.jsdelivr.net/gh/fangxx3863/overwall_list/China_IPList || curl -Lfsm 9 https://raw.githubusercontent.com/fangxx3863/overwall_list/main/China_IPList` && echo \"$A\" | base64 -d > /tmp/china.txt")
		icount=EXEC("cat /tmp/china.txt | wc -l")
		if sret==0 and tonumber(icount)>1000 then
			oldcount=EXEC("cat /tmp/bypass/china.txt | wc -l")
			if tonumber(icount)~=tonumber(oldcount) then
				EXEC("cp -f /tmp/china.txt /tmp/bypass/china.txt && ipset list china_v4 >/dev/null 2>&1 && /usr/share/bypass/chinaipset")
				r=tostring(tonumber(icount))
			else
				r="0"
			end
		else
			r="-1"
		end
		EXEC("rm -f /tmp/china.txt ")
	elseif set=="2" then
		sret=CALL("A=`curl -Lfsm 9 https://cdn.jsdelivr.net/gh/fangxx3863/overwall_list/China_IPv6List || curl -Lfsm 9 https://raw.githubusercontent.com/fangxx3863/overwall_list/main/China_IPv6List` && echo \"$A\" | base64 -d > /tmp/china_v6.txt")
		icount=EXEC("cat /tmp/china_v6.txt | wc -l")
		if sret==0 and tonumber(icount)>1000 then
			oldcount=EXEC("cat /tmp/bypass/china_v6.txt | wc -l")
			if tonumber(icount)~=tonumber(oldcount) then
				EXEC("cp -f /tmp/china_v6.txt /tmp/bypass/china_v6.txt && ipset list china_v6 >/dev/null 2>&1 && /usr/share/bypass/chinaipset v6")
				r=tostring(tonumber(icount))
			else
				r="0"
			end
		else
			r="-1"
		end
		EXEC("rm -f /tmp/china_v6.txt ")
	end
	http.prepare_content("application/json")
	http.write_json({ret=r})
end

function subscribe()
	CALL("/usr/share/overwall/subscribe")
	http.prepare_content("application/json")
	http.write_json({ret=1})
end

function ping()
	local e={}
	local domain=http.formvalue("domain")
	local port=http.formvalue("port")
	local dp=EXEC("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
	local ip=EXEC("echo "..domain.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || \\\
	nslookup "..domain.." 127.0.0.1#"..dp.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
	ip=EXEC("echo -n "..ip)
	local iret=CALL("ipset add over_wan_ac "..ip.." 2>/dev/null")
	e.ping=EXEC(string.format("tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print $2}'",port,ip))
	if (iret==0) then
		CALL("ipset del over_wan_ac "..ip)
	end
	http.prepare_content("application/json")
	http.write_json(e)
end

function getlog()
	logfile="/tmp/bypass.log"
	if not fs.access(logfile) then
		http.write("")
		return
	end
	local f=io.open(logfile,"r")
	local a=f:read("*a") or ""
	f:close()
	a=string.gsub(a,"\n$","")
	http.prepare_content("text/plain; charset=utf-8")
	http.write(a)
end

function dellog()
	fs.writefile("/tmp/bypass.log","")
	http.prepare_content("application/json")
	http.write('')
end
