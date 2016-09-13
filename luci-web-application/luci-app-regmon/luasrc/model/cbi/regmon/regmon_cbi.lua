
m = Map("regmon", translate("Regmon Config"), translate("Set options for Regmon"))

c = m:section(TypedSection, "regmon", translate("regmon entries"))
c.anonymous = true

regmon_path = c:option(DynamicList, "regmonpath", translate("Regmon path")) 
regmon_path.optional = false
regmon_path.rmempty = false

sampling_rate = c:option(Value, "samplingrate", translate("Sampling rate")) 
sampling_rate.optional = false
sampling_rate.rmempty = false

time_from = c:option (Value, "timefrom", translate ("Time from field"))
time_from.optional = false
time_from.rmempty = false

use_sys_time = c:option(Flag, "usesystime", translate("Use System Time"))
use_sys_time.optional = false
use_sys_time.rmempty = false

absolute_counter = c:option ( Value, "absolutecounter", translate ("Absolute counter from field"))
absolute_counter.optional = false
absolute_counter.rmempty = false

busy_counter = c:option ( Value, "busycounter", translate ("Busy counter field"))
busy_counter.optional = false
busy_counter.rmempty = false

startindex = c:option(Value, "startindex", translate("Start index of relative counter fields"))
startindex.optional = false
startindex.rmempty = false

metrics = c:option(DynamicList, "metrics", translate("Register Log Fields"))
metrics.optional = false
metrics.rmempty = false

d = m:section(TypedSection, "collectd", translate("collectd entries"))
d.anonymous = true

interval = d:option(Value, "interval", translate("Data collection interval"))
interval.optional = false
interval.rmempty = false

enable_log = d:option(Flag, "enablelog", translate("Enable collectd logging")) 
enable_log.optional = false
enable_log.rmempty = false

e = m:section(TypedSection, "rrdtool", translate("rrdtool entries"))
e.anonymous = true

imgpath = e:option(Value, "imagepath", translate("RRDTool image path"))
imgpath.optional = false
imgpath.rmempty = false

imgwidth = e:option(Value, "width", translate("RRDTool image width"))
imgwidth.optional = false
imgwidth.rmempty = false

imgheight = e:option(Value, "height", translate("RRDTool image height"))
imgheight.optional = false
imgheight.rmempty = false

stack = e:option(Flag, "stacked", translate("RRDTool stacked graph"))
stack.optional = false
stack.rmempty = false

shapes = { "LINE2", "AREA" }
shape = e:option(ListValue, "shape", translate("RRDTool graph shape"))
shape.optional = false
shape.rmempty = false

for _,s in ipairs(shapes) do
    shape:value(s)
end

return m
