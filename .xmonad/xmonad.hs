import qualified XMonad.StackSet as W
import XMonad hiding ((|||))
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, xmobarPP, ppTitle, ppOrder, ppSep, ppUrgent, ppCurrent, xmobarColor, ppOutput, shorten)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks hiding (docksEventHook)
import XMonad.Hooks.ManageHelpers(isFullscreen, doFullFloat)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.UrgencyHook (focusUrgent, clearUrgents, withUrgencyHook, NoUrgencyHook(NoUrgencyHook))
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.IM (withIM, Property(Role))
import XMonad.Layout.LayoutCombinators ((|||))
import XMonad.Layout.LayoutCombinators (JumpToLayout(JumpToLayout))
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.TwoPane (TwoPane(TwoPane))
import XMonad.Prompt (defaultXPConfig, XPConfig(font))
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe)

import Graphics.X11.ExtraTypes.XF86 (
    xF86XK_AudioLowerVolume
  , xF86XK_AudioRaiseVolume
  , xF86XK_AudioMute
  , xF86XK_AudioPrev
  , xF86XK_AudioPlay
  , xF86XK_AudioNext
  )

import Control.Applicative (liftA2, (<*))
import Control.Monad (liftM2, msum, when)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Writer (tell)
import Control.Monad.Writer (WriterT, execWriterT)
import Data.List (intercalate, stripPrefix)
import Data.Maybe (catMaybes, mapMaybe)
import Data.Monoid (All(All))
import Data.Monoid (Last(Last), getLast)
import Data.Traversable (traverse)
import System.IO (hPutStrLn)

import AlmostFull (AlmostFull(AlmostFull))

myWorkspaces = ["1:anki", "2:gtd", "3:web", "4:dev", "5:video", "6", "7:im",
                "8:mail", "9"]

myManageHook = composeAll
    [ isFullscreen --> doFullFloat

    , className =? "feh"      --> doFloat
    , className =? "Pqiv"     --> doFloat
    , className =? "Xmessage" --> doFloat
    , className =? "kvm"      --> doFloat

    , className =? "Anki" --> doShift "1:gtd"

    , className =? "Firefox" --> doShift "3:web"

    , className =? "Chromium-browser"  --> doShift "3:web"

    , className =? "Gimp" --> (unfloat <+> doShift "10:gimp")

    , className =? "mpv"      --> videoMode
    , className =? "MPlayer"  --> videoMode
    , className =? "mplayer2" --> videoMode

    , stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog"
      --> unfloat
    ]
    where
      unfloat :: ManageHook
      unfloat = ask >>= doF . W.sink

      videoMode = unfloat
               <+> doShift "5:video"
               <+> doF (W.greedyView "5:video")

myLayout = onWorkspace "5:video" absoluteFull $
           smartBorders $ avoidStruts $
           Full |||
           onWorkspace
             "3:web"
             (twoPane ||| Mirror twoPane)
             (tall ||| Mirror tall ||| almostFull)
    where tall = Tall 1 (5/100) (1/2)
          almostFull = AlmostFull (5/9) (5/100) tall
          twoPane = TwoPane (3/100) (1/2)
          absoluteFull = noBorders $ fullscreenFull Full

myKeys = [  -- names of keys can be found in haskell-X11 package in files
            -- Graphics/X11/Types.hsc and Graphics.X11.ExtraTypes.hsc

            -- screenshot of whole screen; compressed at max rate
            ((0, xK_Print), spawn "scrot --quality 0")
          , ((mod1Mask, xK_Print), spawn "scrot --focused --quality 0")

          , ((mod1Mask .|. shiftMask, xK_f), spawn "firefox")
          , ((mod1Mask .|. shiftMask, xK_h), spawn "chromium --disable-gpu")

            -- MPD key bindings
          , ((mod1Mask .|. shiftMask, xK_Left),  spawn "mpc prev")
          , ((mod1Mask .|. shiftMask, xK_Right), spawn "mpc next")
          , ((mod1Mask .|. shiftMask, xK_Down),  spawn "mpc toggle")
          , ((mod1Mask .|. shiftMask, xK_Up),    spawn "urxvtc -fn 'xft:Terminus:pixelsize=16:lang=ru' -rv +sb -e proxychains -f /home/minoru/.proxychains/ncmpcpp.conf ncmpcpp")

            -- toggle statusbar
          , ((mod1Mask .|. shiftMask, xK_b), sendMessage ToggleStruts)

            -- choose application to run
          , ((mod1Mask .|. shiftMask, xK_p), shellPrompt defaultXPConfig { font = "xft:Terminus:pixelsize=12:lang=ru" })

            -- lock the screen (switching to English layout first so I can input the password later)
          , ((mod1Mask .|. shiftMask, xK_l), spawn "setxkbmap -layout 'us' -option -option 'compose:lwin' -option 'terminate:ctrl_alt_bksp' -option 'ctrl:swapcaps'; sleep 1; i3lock --dpms --no-unlock-indicator --image=/home/minoru/pictures/wallpapers/current.png")

            -- handle volume
          , ((0, xF86XK_AudioLowerVolume), spawn "amixer sset Master 1dB-")
          , ((0, xF86XK_AudioRaiseVolume), spawn "amixer sset Master 1dB+")
          , ((0, xF86XK_AudioMute), spawn "amixer sset 'Master' toggle")
          , ((0, xF86XK_AudioPrev), spawn "mpc prev")
          , ((0, xF86XK_AudioPlay), spawn "mpc toggle")
          , ((0, xF86XK_AudioNext), spawn "mpc next")

            -- things to work with urgency hook
            -- jump to the window that considers itself to be urgent
          , ((mod1Mask, xK_BackSpace), focusUrgent)
            -- make urgency notifications go away
          , ((mod1Mask .|. shiftMask, xK_BackSpace), clearUrgents)
          ]


-- custom event hook to refresh layout if new dock does appear
-- via http://www.haskell.org/pipermail/xmonad/2011-August/011644.html
docksEventHook :: Event -> X All
docksEventHook (MapNotifyEvent {ev_window = w}) = do
  whenX ((not `fmap` (isClient w)) <&&> runQuery checkDock w) refresh
  return (All True)
docksEventHook _ = return (All True)

-- Implementation is the same as here save for a minor fixes:
-- https://www.haskell.org/pipermail/xmonad/2012-February/012414.html
resetLayoutHook :: Event -> X All
resetLayoutHook (DestroyWindowEvent {}) = do
  -- W.index turns current window stack set into a list of windows
  empty <- withWindowSet $ (return . null . W.index)
  when empty $ sendMessage $ JumpToLayout "Full"
  return (All True)
resetLayoutHook _ = return (All True)

main = do
    -- spawning different XMoBar configurations depending on the host
    xmproc  <- spawnPipe "xmobar $HOME/.xmobarrc.`hostname --short`"
    xmonad $ ewmh $
      withUrgencyHook NoUrgencyHook
      defaultConfig
        { manageHook = manageDocks <+> myManageHook
                                   <+> manageHook defaultConfig
        , layoutHook = myLayout
        , logHook =
               dynamicLogWithPP (xmobarPP
                 { ppOutput  = hPutStrLn xmproc
                 -- show current window's title in nice darkish green, limited
                 -- to 92 symbols in length
                 , ppTitle   = xmobarColor "#00cc00" "" . shorten 92
                 -- show urgent window in pretty red
                 , ppUrgent  = xmobarColor "#ff2c4b" ""
                 -- current workspace is highlighted with a nice bluish
                 , ppCurrent = xmobarColor "#0a9dff" ""
                 -- I can *see* what layout is in effect, no need to put its
                 -- name into the XMobar
                 , ppOrder   =
                     \(workspaces:layout:title:_) -> [workspaces,title]
                 , ppSep     = " "
                 })
            -- move mouse pointer to the center of the focused window
            >> updatePointer (0.5, 0.5) (0, 0)
        -- custom event hook to refresh layout if new dock does appear
        -- via http://www.haskell.org/pipermail/xmonad/2011-August/011644.html
        , handleEventHook = docksEventHook <+> resetLayoutHook
        , startupHook = setWMName "LG3D"
        , workspaces = myWorkspaces
        , terminal = "urxvtc -fn 'xft:Terminus:pixelsize=16:lang=ru' -rv +sb"
        , focusedBorderColor = "#0a9dff"
        , normalBorderColor = "#666462"
        } `additionalKeys` myKeys

