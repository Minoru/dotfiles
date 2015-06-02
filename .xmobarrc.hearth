Config { font = "xft:Terminus:pixelsize=14:lang=ru"
       , bgColor = "black"
       , fgColor = "#666462"
       , position = TopSize C 100 28
       , commands = [ Run Date "%a %d.%m.%Y %T" "date" 10
                    , Run BatteryP
                        ["BAT0"]
                        [ "-t", "<left>% (<timeleft>)"
                        ]
                        100
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader%}{ : %battery% : <fc=#ffcc00>%date%</fc>"
       }
