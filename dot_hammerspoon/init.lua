-- Load and install the Hyper key extension. Binding to F18
local hyper = require('hyper')
hyper.install('F18')

-- Remap Caps Lock to F18
-- hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039, "HIDKeyboardModifierMappingDst":0x70000006D}]}'

-- Quick Reloading of Hammerspoon
hyper.bindKey('0', hs.reload)
hyper.bindKey('c', hs.toggleConsole)
hyper.bindKey('down', function() moveActiveWindow("down") end)
hyper.bindKey('f', function() hs.application.launchOrFocus("Firefox") end)
hyper.bindKey('i', function() hs.application.launchOrFocus("iTerm") end)
hyper.bindKey('l', hs.caffeinate.lockScreen)
hyper.bindKey('left', function() moveActiveWindow("left") end)
hyper.bindKey('return', function() hs.window.focusedWindow():maximize() end)
hyper.bindKey('right', function() moveActiveWindow("right") end)
hyper.bindKey('up', function() moveActiveWindow("up") end)
hyper.bindKey('z', hs.caffeinate.systemSleep)

function getScreenInDirection(direction)
  local focusedWin = hs.window.focusedWindow()
  local focusedScreen = focusedWin:screen()
  local allScreens = hs.screen.allScreens()
  local focusedScreenIndex = hs.fnutils.indexOf(allScreens, focusedScreen)
--  print('Focused screen index:', focusedScreenIndex)
--  print('Number of screens:', #allScreens)
  for i, screen in ipairs(allScreens) do
--    print('Checking screen', i, screen:name())
    if screen == focusedScreen then
--      print('Skipping focused screen')
    else
      local screenFrame = screen:frame()
      local focusedFrame = focusedScreen:frame()
      local isLeft = screenFrame.x + screenFrame.w <= focusedFrame.x
      local isRight = screenFrame.x >= focusedFrame.x + focusedFrame.w
      local isAbove = screenFrame.y + screenFrame.h <= focusedFrame.y
      local isBelow = screenFrame.y >= focusedFrame.y + focusedFrame.h
      if direction == 'left' and isLeft then
        return i
      elseif direction == 'right' and isRight then
        return i
      elseif direction == 'up' and isAbove then
        return i
      elseif direction == 'down' and isBelow then
        return i
      end
    end
  end
  return nil
end

function moveActiveWindow(direction)
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local cell = hs.grid.get(win)
  hs.grid.setGrid('3x1', screen)
  hs.grid.setMargins({w=0, h=0}) -- Prevent spacing between windows
  local nextCell = cell
  local nextScreen = screen
  local screenIndex = hs.fnutils.indexOf(hs.screen.allScreens(), screen)

  if direction == "left" then
    if cell.x == 0 then
      local nextScreenIndex = getScreenInDirection('left')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(2, 0, 1, 1)
      end
    else
      nextCell.x = nextCell.x - 1
    end
  elseif direction == "right" then
    if cell.x == 2 then
      local nextScreenIndex = getScreenInDirection('right')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 0, 1, 1)
      end
    else
      nextCell.x = nextCell.x + 1
    end
  elseif direction == "up" then
    if cell.y == 0 then
      local nextScreenIndex = getScreenInDirection('up')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 0, 1, 1)
      end
    else
      nextCell.y = nextCell.y - 1
    end
  elseif direction == "down" then
    if cell.y == 0 then
      local nextScreenIndex = getScreenInDirection('down')
      if nextScreenIndex then
        nextScreen = hs.screen.allScreens()[nextScreenIndex]
        nextCell = hs.geometry.rect(0, 2, 1, 1)
      end
    else
      nextCell.y = nextCell.y + 1
    end
  end

  if nextScreen ~= screen then
    win:moveToScreen(nextScreen)
  end

  hs.grid.set(win, nextCell, nextScreen)
end
