-- Tags

require("shifty")
keydoc = loadrc("keydoc", "vbe/keydoc")

local tagicon = function(icon)
   return beautiful.icons .. "/taglist/" .. icon .. ".png"
end

shifty.config.tags = {
   ["3↭www"] = {
      mwfact = 0.7,
      exclusive = true,
      max_clients = 1,
      position = 3,
      screen = math.max(screen.count(), 2),
      spawn = browser,
      icon = tagicon("web")
   },
   ["2↭emacs"] = {
      mwfact = 0.6,
      exclusive = true,
      position = 2,
      spawn = "emacs",
      icon = tagicon("dev"),
   },
   ["1↭xterm"] = {
      layout = awful.layout.suit.fair,
      exclusive = true,
      position = 1,
      slave = true,
      spawn = config.terminal,
      icon = tagicon("main"),
   },
   ["4↭im"] = {
      mwfact = 0.2,
      exclusive = true,
      position = 4,
      icon = tagicon("im"),
      nopopup = true
   }
}

-- Also, see rules.lua
shifty.config.apps = {
   {
      match = {
         "Iceweasel",
         "Firefox",
         "Chromium",
         "Conkeror",
         "Xulrunner-15.0"
      },
      tag = "3↭www",
   },
   {
      match = { "emacs" },
      tag = "2↭emacs",
   },
   {
      match = { "Pidgin" },
      tag = "4↭im",
   },
   {
      match = { "URxvt" },
      -- tag = "1↭xterm",
      intrusive = true,         -- Display even on exclusive tags
   },
}

shifty.config.defaults = {
   layout = config.layouts[1],
   floatBars = false,
   mwfact = 0.6,
   ncol = 1,
   guess_name = true,
   guess_position = true,
}
shifty.config.sloppy = false

shifty.taglist = config.taglist -- Set in widget.lua
shifty.config.modkey = modkey
shifty.config.clientkeys = config.keys.client
shifty.init()

config.keys.global = awful.util.table.join(
   config.keys.global,
   keydoc.group("Tag management"),
   awful.key({ modkey }, "Escape", awful.tag.history.restore, "Switch to previous tag"),
   awful.key({ modkey }, "Left", awful.tag.viewprev, "View previous tag"),
   awful.key({ modkey }, "Right", awful.tag.viewnext, "View next tag"),
   awful.key({ modkey, "Shift"}, "o",
             function()
                local t = awful.tag.selected()
                local s = awful.util.cycle(screen.count(), t.screen + 1)
                awful.tag.history.restore()
                t = shifty.tagtoscr(s, t)
                awful.tag.viewonly(t)
             end,
             "Send tag to next screen"))
   

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, (shifty.config.maxtags or 9) do
   config.keys.global = awful.util.table.join(
      config.keys.global,
      keydoc.group("Tag management"),
      awful.key({ modkey }, i,
                function ()
                   local t = shifty.getpos(i)
                   local s = t.screen
                   local c = awful.client.focus.history.get(s, 0)
                   awful.tag.viewonly(t)
                   mouse.screen = s
                   if c then client.focus = c end
                end,
                i == 5 and "Display only this tag" or nil),
      awful.key({ modkey, "Control" }, i,
                function ()
                   local t = shifty.getpos(i)
                   t.selected = not t.selected
                end,
                i == 5 and "Toggle display of this tag" or nil),
      awful.key({ modkey, "Shift" }, i,
                function ()
                   if client.focus then
                      local t = shifty.getpos(i)
                      awful.client.movetotag(t)
                   end
                end,
                i == 5 and "Move window to this tag" or nil),
      awful.key({ modkey, "Control", "Shift" }, i,
                function ()
                   if client.focus then
                      awful.client.toggletag(shifty.getpos(i))
                   end
                end,
                i == 5 and "Toggle this tag on this window" or nil),
      keydoc.group("Misc"))
end
