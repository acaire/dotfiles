-- Start with a clear console
hs.console.clearConsole()

-- Logger setup (change level to 'debug' for verbose output)
local log = hs.logger.new('chezmoi', 'info')

-- Load and install the Hyper key extension. Binding to F18
local hyper = require('hyper')
hyper.install('F18')

-- Reset Caps Lock Remap
hs.execute('hidutil property --set \'{"UserKeyMapping":[]}\'')

-- Turn off Caps Lock
if hs.hid.capslock.get() then
  log.i('Turning off Caps Lock')
  hs.hid.capslock.set(false)
else
  log.i('Caps Lock already off')
end

-- Remap Caps Lock to F18
hs.execute('hidutil property --set \'{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}\'')
log.i('Caps Lock remapped to F18 (Hyper)')

-- Hyper key bindings
hyper.bindKey('0', function()
  log.d('⟳ Reloading Hammerspoon config')
  hs.reload()
end)
hyper.bindKey('c', function()
  log.d('🖥 Toggling console')
  hs.toggleConsole()
end)
hyper.bindKey('down', function() moveActiveWindow("down") end)
hyper.bindKey('g', function()
  log.d('👻 Launching/focusing Ghostty')
  hs.application.launchOrFocus("ghostty")
end)
hyper.bindKey('l', function()
  log.d('🔒 Locking screen')
  hs.caffeinate.lockScreen()
end)
hyper.bindKey('left', function() moveActiveWindow("left") end)
hyper.bindKey('o', function()
  log.d('🌐 Launching/focusing Orion')
  hs.application.launchOrFocus("Orion")
end)
hyper.bindKey('return', function()
  local win = hs.window.focusedWindow()
  if win then
    log.d(('⛶ Maximizing: %s'):format(win:title()))
    win:maximize()
  end
end)
hyper.bindKey('right', function() moveActiveWindow("right") end)
hyper.bindKey('up', function() moveActiveWindow("up") end)
hyper.bindKey('z', function()
  log.d('💤 Sleeping')
  hs.caffeinate.systemSleep()
end)

function getScreenInDirection(direction)
  local focusedWin = hs.window.focusedWindow()
  local focusedScreen = focusedWin:screen()
  local allScreens = hs.screen.allScreens()
  local focusedScreenIndex = hs.fnutils.indexOf(allScreens, focusedScreen)

  log.d("  🔍 Scanning for screen to the " .. direction .. " of \"" .. focusedScreen:name() .. "\"")
  log.d("     Focused screen index: " .. focusedScreenIndex .. " / " .. #allScreens .. " total")

  for i, screen in ipairs(allScreens) do
    if screen == focusedScreen then
      log.d("     [skip] Screen " .. i .. ": " .. screen:name() .. " (current)")
    else
      local screenFrame = screen:frame()
      local focusedFrame = focusedScreen:frame()
      local isLeft   = screenFrame.x + screenFrame.w <= focusedFrame.x
      local isRight  = screenFrame.x >= focusedFrame.x + focusedFrame.w
      local isAbove  = screenFrame.y + screenFrame.h <= focusedFrame.y
      local isBelow  = screenFrame.y >= focusedFrame.y + focusedFrame.h

      local tags = {}
      if isLeft  then table.insert(tags, "←") end
      if isRight then table.insert(tags, "→") end
      if isAbove then table.insert(tags, "↑") end
      if isBelow then table.insert(tags, "↓") end
      local tagStr = #tags > 0 and table.concat(tags, " ") or "(none)"
      log.d("     [check] Screen " .. i .. ": " .. screen:name() .. " [" .. tagStr .. "]")

      if direction == 'left' and isLeft then
        log.d("     ✅ Found screen to left: " .. screen:name())
        return i
      elseif direction == 'right' and isRight then
        log.d("     ✅ Found screen to right: " .. screen:name())
        return i
      elseif direction == 'up' and isAbove then
        log.d("     ✅ Found screen above: " .. screen:name())
        return i
      elseif direction == 'down' and isBelow then
        log.d("     ✅ Found screen below: " .. screen:name())
        return i
      end
    end
  end

  log.d("     ⚠️  No screen found in direction: " .. direction)
  return nil
end

function moveActiveWindow(direction)
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local cell = hs.grid.get(win)
  hs.grid.setGrid('3x1', screen)
  hs.grid.setMargins({w=0, h=0})
  local nextCell = cell
  local nextScreen = screen
  local screenIndex = hs.fnutils.indexOf(hs.screen.allScreens(), screen)
  local windowTitle = win:title()

  local action, icon
  if direction == "left" then
    if cell.x == 0 then
      -- At left edge, try crossing to adjacent monitor
      local nextScreenIndex = getScreenInDirection('left')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(2, 0, 1, 1)
        action = ("crossed screen left: %s → %s"):format(screen:name(), nextScreen:name())
        icon = "◀──"
      else
        action = "at left edge of " .. screen:name() .. ", no adjacent screen"
        icon = "┃←"
      end
    else
      nextCell.x = nextCell.x - 1
      action = ("shifted left on %s (cell %d → %d)"):format(screen:name(), cell.x, nextCell.x)
      icon = "◀"
    end
  elseif direction == "right" then
    if cell.x == 2 then
      -- At right edge, try crossing to adjacent monitor
      local nextScreenIndex = getScreenInDirection('right')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 0, 1, 1)
        action = ("crossed screen right: %s → %s"):format(screen:name(), nextScreen:name())
        icon = "──▶"
      else
        action = "at right edge of " .. screen:name() .. ", no adjacent screen"
        icon = "→┃"
      end
    else
      nextCell.x = nextCell.x + 1
      action = ("shifted right on %s (cell %d → %d)"):format(screen:name(), cell.x, nextCell.x)
      icon = "▶"
    end
  elseif direction == "up" then
    if cell.y == 0 then
      local nextScreenIndex = getScreenInDirection('up')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 0, 1, 1)
        action = ("crossed screen up: %s → %s"):format(screen:name(), nextScreen:name())
        icon = "▲──"
      else
        action = "at top edge of " .. screen:name() .. ", no adjacent screen"
        icon = "┃↑"
      end
    else
      nextCell.y = nextCell.y - 1
      action = ("shifted up on %s (cell %d → %d)"):format(screen:name(), cell.y, nextCell.y)
      icon = "▲"
    end
  elseif direction == "down" then
    if cell.y == 0 then
      local nextScreenIndex = getScreenInDirection('down')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 2, 1, 1)
        action = ("crossed screen down: %s → %s"):format(screen:name(), nextScreen:name())
        icon = "──▼"
      else
        action = "at bottom edge of " .. screen:name() .. ", no adjacent screen"
        icon = "↓┃"
      end
    else
      nextCell.y = nextCell.y + 1
      action = ("shifted down on %s (cell %d → %d)"):format(screen:name(), cell.y, nextCell.y)
      icon = "▼"
    end
  end

  if nextScreen ~= screen then
    win:moveToScreen(nextScreen)
  end

  hs.grid.set(win, nextCell, nextScreen)

  log.d(('  %s [%s] %s'):format(icon, windowTitle, action))
end
