{ inputs, config, lib, pkgs, userSettings, systemSettings, pkgs-nwg-dock-hyprland, ... }: let
    pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
    imports = [
        ../../app/terminal/alacritty.nix
        ../../app/terminal/kitty.nix
        (import ../../app/dmenu-scripts/networkmanager-dmenu.nix {
            dmenu_command = "fuzzel -d"; inherit config lib pkgs;
        })
        ../input/nihongo.nix
    ] ++
    (if (systemSettings.profile == "personal") then
        [ (import ./hyprprofiles/hyprprofiles.nix {
            dmenuCmd = "fuzzel -d"; inherit config lib pkgs; })]
    else
        []);

    gtk.cursorTheme = {
        package = pkgs.quintom-cursor-theme;
        name = if (config.stylix.polarity == "light") then "Quintom_Ink" else "Quintom_Snow";
        size = 36;
    };

    wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        plugins = [
            inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
            inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
            inputs.hyprgrass.packages.${pkgs.system}.default
        ];
        settings = { };
        extraConfig = ''
            exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_SESSION_DESKTOP=Hyprland XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_TYPE=wayland
            exec-once = hyprctl setcursor '' + config.gtk.cursorTheme.name + " " + builtins.toString config.gtk.cursorTheme.size + ''

            env = XDG_CURRENT_DESKTOP,Hyprland
            env = XDG_SESSION_DESKTOP,Hyprland
            env = XDG_SESSION_TYPE,wayland
            env = WLR_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1
            env = GDK_BACKEND,wayland,x11,*
            env = QT_QPA_PLATFORM,wayland;xcb
            env = QT_QPA_PLATFORMTHEME,qt5ct
            env = QT_AUTO_SCREEN_SCALE_FACTOR,1
            env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
            env = CLUTTER_BACKEND,wayland
            env = GDK_PIXBUF_MODULE_FILE,${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

            exec-once = hyprprofile Default

            exec-once = ydotoold
            #exec-once = STEAM_FRAME_FORCE_CLOSE=1 steam -silent
            exec-once = nm-applet
            exec-once = blueman-applet
            exec-once = GOMAXPROCS=1 syncthing --no-browser
            #exec-once = protonmail-bridge --noninteractive
            exec-once = waybar

            exec-once = hypridle
            exec-once = sleep 5 && libinput-gestures
            exec-once = obs-notification-mute-daemon

            exec-once = hyprpaper

            bezier = wind, 0.05, 0.9, 0.1, 1.05
            bezier = winIn, 0.1, 1.1, 0.1, 1.0
            bezier = winOut, 0.3, -0.3, 0, 1
            bezier = liner, 1, 1, 1, 1
            bezier = linear, 0.0, 0.0, 1.0, 1.0

            animations {
                     enabled = yes
                     animation = windowsIn, 1, 6, winIn, popin
                     animation = windowsOut, 1, 5, winOut, popin
                     animation = windowsMove, 1, 5, wind, slide
                     animation = border, 1, 10, default
                     animation = borderangle, 1, 100, linear, loop
                     animation = fade, 1, 10, default
                     animation = workspaces, 1, 5, wind
                     animation = windows, 1, 6, wind, slide
                     animation = specialWorkspace, 1, 6, default, slidefadevert -50%
            }

            general {
                layout = master
                border_size = 5
                col.active_border = 0xff'' + config.lib.stylix.colors.base08 + " " + ''0xff'' + config.lib.stylix.colors.base09 + " " + ''0xff'' + config.lib.stylix.colors.base0A + " " + ''0xff'' + config.lib.stylix.colors.base0B + " " + ''0xff'' + config.lib.stylix.colors.base0C + " " + ''0xff'' + config.lib.stylix.colors.base0D + " " + ''0xff'' + config.lib.stylix.colors.base0E + " " + ''0xff'' + config.lib.stylix.colors.base0F + " " + ''270deg

                col.inactive_border = 0xaa'' + config.lib.stylix.colors.base02 + ''

                        resize_on_border = true
                        gaps_in = 7
                        gaps_out = 7
            }

            cursor {
                no_warps = false
                inactive_timeout = 30
            }

            plugin {
                hyprtrails {
                        color = rgba(''+config.lib.stylix.colors.base08+''55)
                }
                hyprexpo {
                        columns = 3
                        gap_size = 5
                        bg_col = rgb(''+config.lib.stylix.colors.base00+'')
                        workspace_method = first 1 # [center/first] [workspace] e.g. first 1 or center m+1
                        enable_gesture = true # laptop touchpad
                }
                touch_gestures {
                        sensitivity = 4.0
                        long_press_delay = 260
                        hyprgrass-bind = , edge:r:l, exec, hyprnome
                        hyprgrass-bind = , edge:l:r, exec, hyprnome --previous
                        hyprgrass-bind = , swipe:3:d, exec, nwggrid-wrapper

                        hyprgrass-bind = , swipe:3:u, hyprexpo:expo, toggleoverview
                        hyprgrass-bind = , swipe:3:d, exec, nwggrid-wrapper

                        hyprgrass-bind = , swipe:3:l, exec, hyprnome --previous
                        hyprgrass-bind = , swipe:3:r, exec, hyprnome

                        hyprgrass-bind = , swipe:4:u, movewindow,u
                        hyprgrass-bind = , swipe:4:d, movewindow,d
                        hyprgrass-bind = , swipe:4:l, movewindow,l
                        hyprgrass-bind = , swipe:4:r, movewindow,r

                        hyprgrass-bind = , tap:3, fullscreen,1
                        hyprgrass-bind = , tap:4, fullscreen,0

                        hyprgrass-bindm = , longpress:2, movewindow
                        hyprgrass-bindm = , longpress:3, resizewindow
                }
            }

            bind=SUPER,code:9,exec,nwggrid-wrapper
            bind=SUPER,code:66,exec,nwggrid-wrapper
            bind=SUPER,SPACE,fullscreen,1
            bind=SUPERSHIFT,F,fullscreen,0
            bind=SUPER,Y,workspaceopt,allfloat
            bind=ALT,TAB,cyclenext
            bind=ALT,TAB,bringactivetotop
            bind=ALTSHIFT,TAB,cyclenext,prev
            bind=ALTSHIFT,TAB,bringactivetotop
            bind=SUPER,TAB,hyprexpo:expo, toggleoverview
            bind=SUPER,V,exec,wl-copy $(wl-paste | tr '\n' ' ')
            bind=SUPERSHIFT,T,exec,screenshot-ocr
            bind=CTRLALT,Delete,exec,hyprctl kill
            bind=SUPERSHIFT,K,exec,hyprctl kill
            bind=SUPER,W,exec,nwg-dock-wrapper

            #bind=,code:172,exec,lollypop -t
            #bind=,code:208,exec,lollypop -t
            #bind=,code:209,exec,lollypop -t
            #bind=,code:174,exec,lollypop -s
            #bind=,code:171,exec,lollypop -n
            #bind=,code:173,exec,lollypop -p

            bind = SUPER,R,pass,^(com\.obsproject\.Studio)$
            bind = SUPERSHIFT,R,pass,^(com\.obsproject\.Studio)$

            bind=SUPER,RETURN,exec,'' + userSettings.term + ''

            bind=SUPER,A,exec,'' + userSettings.spawnEditor + ''

            bind=SUPER,S,exec,'' + userSettings.spawnBrowser + ''

            bind=SUPERCTRL,R,exec,phoenix refresh

            bind = SUPERCTRL, M, exec, killall waybar && waybar
            #hyprctl dispatch exec waybar < this might also work instead of just `waybar`

            bind=SUPER,code:47,exec,fuzzel
            bind=SUPER,X,exec,fnottctl dismiss
            bind=SUPERSHIFT,X,exec,fnottctl dismiss all
            bind=SUPER,Q,killactive
            bind=SUPERSHIFT,Q,exit
            bindm=SUPER,mouse:272,movewindow
            bindm=SUPER,mouse:273,resizewindow
            bind=SUPER,T,togglefloating
            bind=SUPER,G,exec,hyprctl dispatch focusworkspaceoncurrentmonitor 9 && pegasus-fe;
            bind=,code:148,exec,''+ userSettings.term + " "+''-e numbat

            bind=,code:107,exec,grim -g "$(slurp)"
            bind=SHIFT,code:107,exec,grim -g "$(slurp -o)"
            bind=SUPER,code:107,exec,grim
            bind=CTRL,code:107,exec,grim -g "$(slurp)" - | wl-copy
            bind=SHIFTCTRL,code:107,exec,grim -g "$(slurp -o)" - | wl-copy
            bind=SUPERCTRL,code:107,exec,grim - | wl-copy

            bind=,code:122,exec,swayosd-client --output-volume lower
            bind=,code:123,exec,swayosd-client --output-volume raise
            bind=,code:121,exec,swayosd-client --output-volume mute-toggle
            bind=,code:256,exec,swayosd-client --output-volume mute-toggle
            bind=SHIFT,code:122,exec,swayosd-client --output-volume lower
            bind=SHIFT,code:123,exec,swayosd-client --output-volume raise
            bind=,code:232,exec,swayosd-client --brightness lower
            bind=,code:233,exec,swayosd-client --brightness raise
            bind=,code:237,exec,brightnessctl --device='asus::kbd_backlight' set 1-
            bind=,code:238,exec,brightnessctl --device='asus::kbd_backlight' set +1
            bind=,code:255,exec,airplane-mode
            bind=SUPERSHIFT,C,exec,wl-copy $(hyprpicker)

            bind=SUPERSHIFT,S,exec,systemctl suspend
            bindl=,switch:on:Lid Switch,exec,loginctl lock-session
            bind=SUPER,L,exec,loginctl lock-session

            bind=SUPER,Left,movefocus,l
            bind=SUPER,Down,movefocus,d
            bind=SUPER,Up,movefocus,u
            bind=SUPER,Right!W,movefocus,r

            bind=SUPERSHIFT,Left,movewindow,l
            bind=SUPERSHIFT,Down,movewindow,d
            bind=SUPERSHIFT,Up,movewindow,u
            bind=SUPERSHIFT,Right,movewindow,r

            bind=SUPER,1,focusworkspaceoncurrentmonitor,1
            bind=SUPER,2,focusworkspaceoncurrentmonitor,2
            bind=SUPER,3,focusworkspaceoncurrentmonitor,3
            bind=SUPER,4,focusworkspaceoncurrentmonitor,4
            bind=SUPER,5,focusworkspaceoncurrentmonitor,5
            bind=SUPER,6,focusworkspaceoncurrentmonitor,6
            bind=SUPER,7,focusworkspaceoncurrentmonitor,7
            bind=SUPER,8,focusworkspaceoncurrentmonitor,8
            bind=SUPER,9,focusworkspaceoncurrentmonitor,9

            bind=SUPERCTRL,right,exec,hyprnome
            bind=SUPERCTRL,left,exec,hyprnome --previous
            bind=SUPERSHIFT,right,exec,hyprnome --move
            bind=SUPERSHIFT,left,exec,hyprnome --previous --move

            bind=SUPERSHIFT,1,movetoworkspace,1
            bind=SUPERSHIFT,2,movetoworkspace,2
            bind=SUPERSHIFT,3,movetoworkspace,3
            bind=SUPERSHIFT,4,movetoworkspace,4
            bind=SUPERSHIFT,5,movetoworkspace,5
            bind=SUPERSHIFT,6,movetoworkspace,6
            bind=SUPERSHIFT,7,movetoworkspace,7
            bind=SUPERSHIFT,8,movetoworkspace,8
            bind=SUPERSHIFT,9,movetoworkspace,9

            bind=SUPER,Z,exec,if hyprctl clients | grep scratch_term; then echo "scratch_term respawn not needed"; else kitty --class scratch_term; fi
            bind=SUPER,Z,togglespecialworkspace,scratch_term
            bind=SUPER,F,exec,if hyprctl clients | grep scratch_ranger; then echo "scratch_ranger respawn not needed"; else kitty --class scratch_ranger -e ranger; fi
            bind=SUPER,F,togglespecialworkspace,scratch_ranger
            bind=SUPER,N,exec,if hyprctl clients | grep scratch_numbat; then echo "scratch_ranger respawn not needed"; else alacritty --class scratch_numbat -e numbat; fi
            bind=SUPER,N,togglespecialworkspace,scratch_numbat
            bind=SUPER,M,exec,if hyprctl clients | grep lollypop; then echo "scratch_ranger respawn not needed"; else lollypop; fi
            bind=SUPER,M,togglespecialworkspace,scratch_music
            bind=SUPER,B,exec,if hyprctl clients | grep scratch_btm; then echo "scratch_ranger respawn not needed"; else alacritty --class scratch_btm -e btm; fi
            bind=SUPER,B,togglespecialworkspace,scratch_btm
            bind=SUPER,D,exec,if hyprctl clients | grep Element; then echo "scratch_ranger respawn not needed"; else element-desktop; fi
            bind=SUPER,D,togglespecialworkspace,scratch_element
            bind=SUPER,code:172,exec,togglespecialworkspace,scratch_pavucontrol
            bind=SUPER,code:172,exec,if hyprctl clients | grep pavucontrol; then echo "scratch_ranger respawn not needed"; else pavucontrol; fi

            $scratchpadsize = size 90% 95%

            $scratch_term = class:^(scratch_term)$
            windowrulev2 = float,$scratch_term
            windowrulev2 = $scratchpadsize,$scratch_term
            windowrulev2 = workspace special:scratch_term ,$scratch_term
            windowrulev2 = center,$scratch_term

            $scratch_ranger = class:^(scratch_ranger)$
            windowrulev2 = float,$scratch_ranger
            windowrulev2 = $scratchpadsize,$scratch_ranger
            windowrulev2 = workspace special:scratch_ranger silent,$scratch_ranger
            windowrulev2 = center,$scratch_ranger

            $scratch_numbat = class:^(scratch_numbat)$
            windowrulev2 = float,$scratch_numbat
            windowrulev2 = $scratchpadsize,$scratch_numbat
            windowrulev2 = workspace special:scratch_numbat silent,$scratch_numbat
            windowrulev2 = center,$scratch_numbat

            $scratch_btm = class:^(scratch_btm)$
            windowrulev2 = float,$scratch_btm
            windowrulev2 = $scratchpadsize,$scratch_btm
            windowrulev2 = workspace special:scratch_btm silent,$scratch_btm
            windowrulev2 = center,$scratch_btm

            windowrulev2 = float,class:^(Element)$
            windowrulev2 = size 85% 90%,class:^(Element)$
            windowrulev2 = workspace special:scratch_element silent,class:^(Element)$
            windowrulev2 = center,class:^(Element)$

            windowrulev2 = float,class:^(lollypop)$
            windowrulev2 = size 85% 90%,class:^(lollypop)$
            windowrulev2 = workspace special:scratch_music silent,class:^(lollypop)$
            windowrulev2 = center,class:^(lollypop)$

            $savetodisk = title:^(Save to Disk)$
            windowrulev2 = float,$savetodisk
            windowrulev2 = size 70% 75%,$savetodisk
            windowrulev2 = center,$savetodisk

            $pavucontrol = class:^(org.pulseaudio.pavucontrol)$
            windowrulev2 = float,$pavucontrol
            windowrulev2 = size 86% 40%,$pavucontrol
            windowrulev2 = move 50% 6%,$pavucontrol
            windowrulev2 = workspace special silent,$pavucontrol
            windowrulev2 = opacity 0.80,$pavucontrol

            $miniframe = title:\*Minibuf.*
            windowrulev2 = float,$miniframe
            windowrulev2 = size 64% 50%,$miniframe
            windowrulev2 = move 18% 25%,$miniframe
            windowrulev2 = animation popin 1 20,$miniframe

            windowrulev2 = float,class:^(pokefinder)$
            windowrulev2 = float,class:^(Waydroid)$

            windowrulev2 = opacity 0.80,title:ORUI

            windowrulev2 = opacity 0.85,class:^(Element)$
            windowrulev2 = opacity 0.85,class:^(lollypop)$
            windowrulev2 = opacity 0.85,title:^(My Local Dashboard Awesome Homepage - qutebrowser)$
            windowrulev2 = opacity 0.85,title:\[.*\] - My Local Dashboard Awesome Homepage
            #windowrulev2 = opacity 0.85,class:^(org.keepassxc.KeePassXC)$
            #windowrulev2 = opacity 0.85,class:^(org.gnome.Nautilus)$
            #windowrulev2 = opacity 0.85,class:^(org.gnome.Nautilus)$

            layerrule = blur,waybar
            layerrule = xray,waybar
            blurls = waybar
            layerrule = blur,launcher # fuzzel
            blurls = launcher # fuzzel
            layerrule = blur,gtk-layer-shell
            layerrule = xray,gtk-layer-shell
            blurls = gtk-layer-shell
            layerrule = blur,~nwggrid
            layerrule = xray 1,~nwggrid
            layerrule = animation fade,~nwggrid
            blurls = ~nwggrid

            bind=SUPER,equal, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.5}')"
            bind=SUPER,minus, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.5}')"

            bind=SUPER,I,exec,networkmanager_dmenu
            bind=SUPER,P,exec,keepmenu
            bind=SUPERSHIFT,P,exec,hyprprofile-dmenu

            # Laptop
            monitor=eDP-1,preferred,auto,1.5
            
            #monitor=HDMI-A-1,1920x1080,1920x0,1
            #monitor=DP-1,1920x1080,0x0,1

            # hdmi tv
            #monitor=eDP-1,1920x1080,1920x0,1
            #monitor=HDMI-A-1,1920x1080,0x0,1

            # hdmi work projector
            #monitor=eDP-1,1920x1080,1920x0,1
            #monitor=HDMI-A-1,1920x1200,0x0,1

            xwayland {
                force_zero_scaling = false
            }

            binds {
                movefocus_cycles_fullscreen = false
            }

            input {
                kb_layout = gb
                kb_options = caps:escape
                repeat_delay = 350
                repeat_rate = 50
                accel_profile = adaptive
                follow_mouse = 2
                float_switch_override_focus = 0
            }

            misc {
                disable_hyprland_logo = true
                mouse_move_enables_dpms = true
                enable_swallow = true
                swallow_regex = (scratch_term)|(Alacritty)|(kitty)
                font_family = '' + userSettings.font + ''
            }

            decoration {
                rounding = 8
                dim_special = 0.0
                blur {
                    enabled = true
                    size = 5
                    passes = 2
                    ignore_opacity = true
                    contrast = 1.17
                    brightness = '' + (if (config.stylix.polarity == "dark") then "0.8" else "1.25") + ''
                    xray = true
                    special = true
                    popups = true
                }
            }

        '';
        xwayland = { enable = true; };
        systemd.enable = true;
    };

    home.packages = (with pkgs; [
        alacritty
        kitty
        feh
        killall
        polkit_gnome
        nwg-launchers
        papirus-icon-theme
        (pkgs.writeScriptBin "nwggrid-wrapper" ''
            #!/bin/sh
            if pgrep -x "nwggrid-server" > /dev/null
            then
                nwggrid -client
            else
                GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache nwggrid-server -layer-shell-exclusive-zone -1 -g adw-gtk3 -o 0.55 -b ${config.lib.stylix.colors.base00}
            fi
        '')
        libva-utils
        libinput-gestures
        gsettings-desktop-schemas
        (pkgs.makeDesktopItem {
            name = "nwggrid";
            desktopName = "Application Launcher";
            exec = "nwggrid-wrapper";
            terminal = false;
            type = "Application";
            noDisplay = true;
            icon = "/home/"+userSettings.username+"/.local/share/pixmaps/hyprland-logo-stylix.svg";
        })
        (hyprnome.override (oldAttrs: {
                rustPlatform = oldAttrs.rustPlatform // {
                    buildRustPackage = args: oldAttrs.rustPlatform.buildRustPackage (args // {
                        pname = "hyprnome";
                        version = "unstable-2024-05-06";
                        src = fetchFromGitHub {
                            owner = "donovanglover";
                            repo = "hyprnome";
                            rev = "f185e6dbd7cfcb3ecc11471fab7d2be374bd5b28";
                            hash = "sha256-tmko/bnGdYOMTIGljJ6T8d76NPLkHAfae6P6G2Aa2Qo=";
                        };
                        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (oldAttrs: rec {
                            name = "${pname}-vendor.tar.gz";
                            inherit src;
                            outputHash = "sha256-cQwAGNKTfJTnXDI3IMJQ2583NEIZE7GScW7TsgnKrKs=";
                        });
                        cargoHash = "sha256-cQwAGNKTfJTnXDI3IMJQ2583NEIZE7GScW7TsgnKrKs=";
                    });
                };
         })
        )
        gnome.zenity
        wlr-randr
        wtype
        ydotool
        wl-clipboard
        hyprland-protocols
        hyprpicker
        inputs.hyprlock.packages.${pkgs.system}.default
        hypridle
        hyprpaper
        fnott
        keepmenu
        pinentry-gnome3
        wev
        grim
        slurp
        libsForQt5.qt5.qtwayland
        kdePackages.qtwayland
        libsForQt5.qt5.qtsvg
        kdePackages.qtsvg
        
        xdg-utils
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        wlsunset
        pavucontrol
        pamixer
        tesseract4
        (pkgs.writeScriptBin "screenshot-ocr" ''
            #!/bin/sh
            imgname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S).png"
            txtname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S)"
            txtfname=$txtname.txt
            grim -g "$(slurp)" $imgname;
            tesseract $imgname $txtname;
            wl-copy -n < $txtfname
        '')
        (pkgs.writeScriptBin "nwg-dock-wrapper" ''
            #!/bin/sh
            if pgrep -x ".nwg-dock-hyprl" > /dev/null
            then
                nwg-dock-hyprland
            else
                nwg-dock-hyprland -f -x -i 64 -nolauncher -a start -ml 8 -mr 8 -mb 8
            fi
        '')
        (pkgs.writeScriptBin "sct" ''
            #!/bin/sh
            killall wlsunset &> /dev/null;
            if [ $# -eq 1 ]; then
                temphigh=$(( $1 + 1 ))
                templow=$1
                wlsunset -t $templow -T $temphigh &> /dev/null &
            else
                killall wlsunset &> /dev/null;
            fi
        '')
        (pkgs.writeScriptBin "obs-notification-mute-daemon" ''
            #!/bin/sh
            while true; do
                if pgrep -x .obs-wrapped > /dev/null;
                    then
                        pkill -STOP fnott;
                    else
                        pkill -CONT fnott;
                fi
                sleep 10;
            done
        '')
        (pkgs.writeScriptBin "suspend-unless-render" ''
            #!/bin/sh
            if pgrep -x nixos-rebuild > /dev/null || pgrep -x home-manager > /dev/null || pgrep -x kdenlive > /dev/null || pgrep -x FL64.exe > /dev/null || pgrep -x blender > /dev/null || pgrep -x flatpak > /dev/null;
            then echo "Shouldn't suspend"; sleep 10; else echo "Should suspend"; systemctl suspend; fi
        '')])
    ++
    (with pkgs-hyprland; [ ])
    ++ (with pkgs-nwg-dock-hyprland; [
        (nwg-dock-hyprland.overrideAttrs (oldAttrs: {
            patches = ./patches/noactiveclients.patch;
        }))
    ]);
    home.file.".local/share/pixmaps/hyprland-logo-stylix.svg".source =
        config.lib.stylix.colors {
            template = builtins.readFile ../../pkgs/hyprland-logo-stylix.svg.mustache;
            extension = "svg";
        };
    home.file.".config/nwg-dock-hyprland/style.css".text = ''
        window {
            background: rgba(''+config.lib.stylix.colors.base00-rgb-r+'',''+config.lib.stylix.colors.base00-rgb-g+'',''+config.lib.stylix.colors.base00-rgb-b+'',0.0);
            border-radius: 20px;
            padding: 4px;
            margin-left: 4px;
            margin-right: 4px;
            border-style: none;
        }

        #box {
            /* Define attributes of the box surrounding icons here */
            padding: 10px;
            background: rgba(''+config.lib.stylix.colors.base00-rgb-r+'',''+config.lib.stylix.colors.base00-rgb-g+'',''+config.lib.stylix.colors.base00-rgb-b+'',0.55);
            border-radius: 20px;
            padding: 4px;
            margin-left: 4px;
            margin-right: 4px;
            border-style: none;
        }
        button {
            border-radius: 10px;
            padding: 4px;
            margin-left: 4px;
            margin-right: 4px;
            background: rgba(''+config.lib.stylix.colors.base03-rgb-r+'',''+config.lib.stylix.colors.base03-rgb-g+'',''+config.lib.stylix.colors.base03-rgb-b+'',0.55);
            color: #''+config.lib.stylix.colors.base07+'';
            font-size: 12px
        }

        button:hover {
            background: rgba(''+config.lib.stylix.colors.base04-rgb-r+'',''+config.lib.stylix.colors.base04-rgb-g+'',''+config.lib.stylix.colors.base04-rgb-b+'',0.55);
        }

    '';
    home.file.".config/nwg-dock-pinned".text = ''
        nwggrid
        Alacritty
        zen-browser
        writer
        impress
        calc
        draw
        krita
        xournalpp
        obs
        kdenlive
        flstudio
        blender
        openscad
        Cura
        virt-manager
    '';
    home.file.".config/hypr/hypridle.conf".text = ''
        general {
            lock_cmd = pgrep hyprlock || hyprlock
            before_sleep_cmd = loginctl lock-session
            ignore_dbus_inhibit = false
        }

        # FIXME memory leak fries computer inbetween dpms off and suspend
        #listener {
        #    timeout = 150 # in seconds
        #    on-timeout = hyprctl dispatch dpms off
        #    on-resume = hyprctl dispatch dpms on
        #}
        listener {
            timeout = 165 # in seconds
            on-timeout = loginctl lock-session
        }
        listener {
            timeout = 180 # in seconds
            #timeout = 5400 # in seconds
            on-timeout = systemctl suspend
            on-resume = hyprctl dispatch dpms on
        }
    '';
    home.file.".config/hypr/hyprlock.conf".text = ''
    background {
        path = ''+config.stylix.image+''
        blur_passes = 2
        blur_size = 5
        vibrancy = 0.1696
        brightness = 0.5
    }
    # TIME
    label {
        monitor = 
        text = cmd[update:1000] echo "$(date +"%R")"
        color = $foreground
        font_size = 100
        font_family = JetBrainsMono Nerd Font ExtraBold
        position = 0, 400
        halign = center
        valign = center
    }

    # DATE
    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%a, %d %b")"
        color = $foreground
        font_size = 22
        font_family = JetBrainsMono Nerd Font Bold
        position = 0, 300
        halign = center
        valign = center
    }

    # UPTIME
    label {
        monitor =
        text = cmd[update:1000] echo "$(uptime -p | sed "s/u/U/")"
        #Should Try just hex instead of this mess
        color = rgb(''+config.lib.stylix.colors.base05+'')
        font_size = 14
        font_family = ''+userSettings.font+''
        position = 0, -500
        halign = center
        valign = center
    }

    input-field {
        size = 200, 50
        outline_thickness = 2
        dots_size = 0.25
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
        outer_color = rgb(''+config.lib.stylix.colors.base05+'')
        inner_color = rgb(''+config.lib.stylix.colors.base00+'')
        font_color = rgb(''+config.lib.stylix.colors.base05+'')
        fade_on_empty = true
        fade_timeout = 1500 # Milliseconds before fade_on_empty is triggered.
        font_family = ''+userSettings.font+''
        placeholder_text = <i>Enter Password...</i> # Text rendered in the input box when it's empty.
        hide_input = false
        rounding = 15
        check_color = rgb(''+config.lib.stylix.colors.base02+'')
        fail_color = rgb(''+config.lib.stylix.colors.base08+'') # if authentication failed, changes outer_color and fail message color
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i> # can be set to empty
        fail_timeout = 2000 # milliseconds before fail_text and fail_color disappears
        fail_transition = 200 # transition time in ms between normal outer_color and fail_color
    }
    '';
    services.swayosd.enable = true;
    services.swayosd.topMargin = 0.5;
    programs.waybar = {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {
            postPatch = ''
                # use hyprctl to switch workspaces
                sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch focusworkspaceoncurrentmonitor " + std::to_string(id());\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
                sed -i 's/gIPC->getSocket1Reply("dispatch workspace " + std::to_string(id()));/gIPC->getSocket1Reply("dispatch focusworkspaceoncurrentmonitor " + std::to_string(id()));/g' src/modules/hyprland/workspaces.cpp
            '';
            patches = [./patches/waybarpaupdate.patch ./patches/waybarbatupdate.patch];
        });
        settings = {
            mainBar = {
                "font" = "";
                "reload_style_on_change" = true;
                "height" = 30; # Waybar height
                "spacing" = 7; # Gaps between modules (4px)
                "modules-left" = [ "group/quicklinks-left" "wlr/taskbar" "hyprland/window" ];
                "modules-center" = [ "hyprland/workspaces" ];
                "modules-right" = [ "mpd" "network" "pulseaudio" "group/hardware" "clock" "group/quicklinks-right" ];
            
                # Taskbar
                "wlr/taskbar" = {
                  "format" = "{icon}";
                  "icon-size" = "20";
                  "on-click" = "activate";
                  "on-click-right" = "close";
                  "tooltip-format" = "Go to {title}";
                  "ignore-list" = [ "kitty" "kitty-scratchpad" ];
                };
            
                # Hyprland
                "hyprland/workspaces" = {
                  "disable-scroll" = true;
                  "sort-by" = "number";
                  "all-outputs" = true;
                  "warp-on-scroll" = false;
                  "format" = "{icon}";
                  #"format-icons" = {
                  #  "1" = " ";
                  #  "2" = " ";
                  #  "3" = " "
                  #};
                };
                "hyprland/window" = {
                  "format" = "{title}";
                  "icon" = true;
                  "icon-size" = 20;
                  "max-length" = 30;
                  "separate-outputs" = true;
                };
            
                # Tray
                "tray" = {
                  "icon-size" = 21;
                  "spacing" = 10;
                };
            
                # Quicklinks
                "group/quicklinks-left" = {
                  "orientation" = "horizontal";
                  "modules" = [ "image" "custom/settings" "custom/clipboard" ];
                };
                "image" = {
                  "path" = "/home/hrigved/Pictures/Icons/arch.png";
                  "on-click" = "~/.config/rofi/menus/drun.sh";
                  "size" = 18;
                };
                "custom/settings" = {
                  "format" = " ";
                  "tooltip" = true;
                  "tooltip-format" = "Open Settings!";
                  "on-click" = "systemsettings";
                };
                "custom/clipboard" = {
                  "format" = "󱘢 ";
                  "tooltip" = true;
                  "tooltip-format" = "Open Clipboard Manager!";
                  "on-click" = "~/.config/rofi/menus/clipboard.sh";
                };
                #"custom/terminal" = {
                #  "format" = " ";
                #  "tooltip" = true;
                #  "tooltip-format" = " Open Kitty!";
                #  "on-click" = "kitty";
                #};
                #"custom/explorer" = {
                #  "format" = " ";
                #  "tooltip" = true;
                #  "tooltip-format" = " Open Dolphin!";
                #  "on-click" = "dolphin";
                #};
            
                "group/quicklinks-right" = {
                  "orientation" = "horizontal";
                  "modules" = [ "idle_inhibitor" "custom/wallpaper" "custom/notification" "custom/power-menu" ];
                };
                "idle_inhibitor" = {
                  "format" = "{icon}";
                  "format-icons" = {
                    "activated" = " ";
                    "deactivated" = " ";
                  };
                };
                #"group/power-menu" = {
                #  "orientation" = "inherit";
                #  "drawer" = {
                #    "transition-duration" = 500;
                #    "children-class" = "power-child";
                #    "transition-left-to-right" = false;
                #  };
                #  "modules" = [ "custom/wlogout" "custom/reboot" "custom/quit" "custom/suspend" "custom/lock" ]; 
                #};
                "custom/power-menu" = {
                  "format" = " ";
                  "tooltip" = true;
                  "tooltip-format" = " Open Wlogout!";
                  "on-click" = "~/.config/hypr/scripts/power-menu.sh";
                };
                #"custom/lock" = {
                #  "format" = " ";
                #  "on-click" = "hyprlock";
                #};
                #"custom/quit" = {
                #  "format" = "󰍃 ";
                #  "on-click" = "hyprctl dispatch exit";
                #};
                #"custom/suspend" = {
                #  "format" = "⏾ ";
                #  "on-click" = "systemctl suspend";
                #};
                #"custom/reboot" = {
                #  "format" = " ";
                #  "on-click" = "systemctl reboot";
                #};
                "custom/wallpaper" = {
                  "format" = " ";
                  "tooltip" = true;
                  "tooltip-format" = " Change Wallpaper!";
                  "on-click" = "~/.config/rofi/menus/swww.sh";
                };
                "custom/notification" = {
                  "tooltip" = false;
                  "format" = "{icon}";
                  "format-icons" = {
                    "notification" = "<span foreground='red'><sup></sup></span>";
                    "none" = "";
                    "dnd-notification" = "<span foreground='red'><sup></sup></span>";
                    "dnd-none" = "";
                    "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
                    "inhibited-none" = "";
                    "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
                    "dnd-inhibited-none" = "";
                  };
                  "return-type" = "json";
                  "exec-if" = "which swaync-client";
                  "exec" = "swaync-client -swb";
                  "on-click" = "swaync-client -t -sw";
                  "on-click-right" = "swaync-client -d -sw";
                  "escape" = true;
                };
            
                # Settings
                "group/settings" = {
                  "orientation" = "horizontal";
                  "modules" = [];
                };
            
                # Temperature
                "temperature" = {
                  "critical-threshold" = 80;
                  "format" = "{temperatureC}°C {icon}";
                  "hwmon-path-abs" = "/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/nvme/nvme0/hwmon1/temp1_input";
                  "format-icons" = [ "" "" ""];
                };
            
                # Audio setup
                "pulseaudio" = {
                  "format" = "{volume}% {icon}";
                  "format-bluetooth" = "{volume}% {icon} {format_source}";
                  "format-bluetooth-muted" = " {icon} {format_source}";
                  "format-muted" = "󰝟 {format_source}";
                  "format-source" = "{volume}%";
                  "format-source-muted" = "";
                  "format-icons" = {
                    "default" = [ "" " " " " ];
                  };
                  "max-volume" = 150;
                  "on-click" = "pavucontrol";
                };
            
                # Network setup
                "network" = {
                  "format" = "{ifname}";
                  "format-wifi" = "{essid} {bandwidthDownBytes}  ";
                  "format-ethernet" = "{bandwidthDownBytes}  ";
                  "format-disconnected" = "󱍢 No Internet";
                  "tooltip-format" = "{ifname} via {gwaddr} 󰊗";
                  "tooltip-format-wifi" = "{essid} ({signalStrength}%)  ";
                  "tooltip-format-ethernet" = "{ifname}  ";
                  "max-length" = 50;
                  "interval" = 2;
                };
            
                # Hardware info
                "group/hardware" = {
                  "orientation" = "horizontal";
                  "modules" = [ "disk" "cpu" "memory" ];
                };
                "disk" = {
                  "format" = "{percentage_used}%  ";
                  "path" = "/home";
                };
                "cpu" = {
                  "format" = " {usage}%  ";
                  "tooltip" = false;
                };
                "memory" = {
                  "format" = " {}%  ";
                };
            
                # Clock
                "clock" = {
                    "timezone" = "Europe/London";
                    "format" = "󱑂 {%a :%T}"; # Mon 19:28.10
                    "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                    "format-alt" = "󰨳 {:%d %b %Y}"; # 25 Dec 2006
    };
};
        style = ''
            * {
                    /* `otf-font-awesome` is required to be installed for icons */
                    font-family: FontAwesome, ''+userSettings.font+'';

                    font-size: 20px;
            }

            window#waybar {
                    background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.55);
                    border-radius: 8px;
                    color: #'' + config.lib.stylix.colors.base07 + '';
                    transition-property: background-color;
                    transition-duration: .2s;
            }

            tooltip {
                color: #'' + config.lib.stylix.colors.base07 + '';
                background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.9);
                border-style: solid;
                border-width: 3px;
                border-radius: 8px;
                border-color: #'' + config.lib.stylix.colors.base08 + '';
            }

            tooltip * {
                color: #'' + config.lib.stylix.colors.base07 + '';
                background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.0);
            }

            window > box {
                    border-radius: 8px;
                    opacity: 0.94;
            }

            window#waybar.hidden {
                    opacity: 0.2;
            }

            button {
                    border: none;
            }

            #custom-hyprprofile {
                    color: #'' + config.lib.stylix.colors.base0D + '';
            }

            /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
            button:hover {
                    background: inherit;
            }

            #workspaces button {
                    padding: 0px 6px;
                    background-color: transparent;
                    color: #'' + config.lib.stylix.colors.base04 + '';
            }

            #workspaces button:hover {
                    color: #'' + config.lib.stylix.colors.base07 + '';
            }

            #workspaces button.active {
                    color: #'' + config.lib.stylix.colors.base08 + '';
            }

            #workspaces button.focused {
                    color: #'' + config.lib.stylix.colors.base0A + '';
            }

            #workspaces button.visible {
                    color: #'' + config.lib.stylix.colors.base05 + '';
            }

            #workspaces button.urgent {
                    color: #'' + config.lib.stylix.colors.base09 + '';
            }

            #battery,
            #cpu,
            #memory,
            #disk,
            #temperature,
            #backlight,
            #network,
            #pulseaudio,
            #wireplumber,
            #custom-media,
            #tray,
            #mode,
            #idle_inhibitor,
            #scratchpad,
            #custom-hyprprofileicon,
            #custom-quit,
            #custom-lock,
            #custom-reboot,
            #custom-power,
            #mpd {
                    padding: 0 3px;
                    color: #'' + config.lib.stylix.colors.base07 + '';
                    border: none;
                    border-radius: 8px;
            }

            #custom-hyprprofileicon,
            #custom-quit,
            #custom-lock,
            #custom-reboot,
            #custom-power,
            #idle_inhibitor {
                    background-color: transparent;
                    color: #'' + config.lib.stylix.colors.base04 + '';
            }

            #custom-hyprprofileicon:hover,
            #custom-quit:hover,
            #custom-lock:hover,
            #custom-reboot:hover,
            #custom-power:hover,
            #idle_inhibitor:hover {
                    color: #'' + config.lib.stylix.colors.base07 + '';
            }

            #clock, #tray, #idle_inhibitor {
                    padding: 0 5px;
            }

            #window,
            #workspaces {
                    margin: 0 6px;
            }

            /* If workspaces is the leftmost module, omit left margin */
            .modules-left > widget:first-child > #workspaces {
                    margin-left: 0;
            }

            /* If workspaces is the rightmost module, omit right margin */
            .modules-right > widget:last-child > #workspaces {
                    margin-right: 0;
            }

            #clock {
                    color: #'' + config.lib.stylix.colors.base0D + '';
            }

            #battery {
                    color: #'' + config.lib.stylix.colors.base0B + '';
            }

            #battery.charging, #battery.plugged {
                    color: #'' + config.lib.stylix.colors.base0C + '';
            }

            @keyframes blink {
                    to {
                            background-color: #'' + config.lib.stylix.colors.base07 + '';
                            color: #'' + config.lib.stylix.colors.base00 + '';
                    }
            }

            #battery.critical:not(.charging) {
                    background-color: #'' + config.lib.stylix.colors.base08 + '';
                    color: #'' + config.lib.stylix.colors.base07 + '';
                    animation-name: blink;
                    animation-duration: 0.5s;
                    animation-timing-function: linear;
                    animation-iteration-count: infinite;
                    animation-direction: alternate;
            }

            label:focus {
                    background-color: #'' + config.lib.stylix.colors.base00 + '';
            }

            #cpu {
                    color: #'' + config.lib.stylix.colors.base0D + '';
            }

            #memory {
                    color: #'' + config.lib.stylix.colors.base0E + '';
            }

            #disk {
                    color: #'' + config.lib.stylix.colors.base0F + '';
            }

            #backlight {
                    color: #'' + config.lib.stylix.colors.base0A + '';
            }

            label.numlock {
                    color: #'' + config.lib.stylix.colors.base04 + '';
            }

            label.numlock.locked {
                    color: #'' + config.lib.stylix.colors.base0F + '';
            }

            #pulseaudio {
                    color: #'' + config.lib.stylix.colors.base0C + '';
            }

            #pulseaudio.muted {
                    color: #'' + config.lib.stylix.colors.base04 + '';
            }

            #tray > .passive {
                    -gtk-icon-effect: dim;
            }

            #tray > .needs-attention {
                    -gtk-icon-effect: highlight;
            }

            #idle_inhibitor {
                    color: #'' + config.lib.stylix.colors.base04 + '';
            }

            #idle_inhibitor.activated {
                    color: #'' + config.lib.stylix.colors.base0F + '';
            }
            '';
    };
    home.file.".config/gtklock/style.css".text = ''
        window {
            background-image: url("''+config.stylix.image+''");
            background-size: auto 100%;
        }
    '';
    home.file.".config/nwg-launchers/nwggrid/style.css".text = ''
        button, label, image {
                background: none;
                border-style: none;
                box-shadow: none;
                color: #'' + config.lib.stylix.colors.base07 + '';

                font-size: 20px;
        }

        button {
                padding: 5px;
                margin: 5px;
                text-shadow: none;
        }

        button:hover {
                background-color: rgba('' + config.lib.stylix.colors.base07-rgb-r + "," + config.lib.stylix.colors.base07-rgb-g + "," + config.lib.stylix.colors.base07-rgb-b + "," + ''0.15);
        }

        button:focus {
                box-shadow: 0 0 10px;
        }

        button:checked {
                background-color: rgba('' + config.lib.stylix.colors.base07-rgb-r + "," + config.lib.stylix.colors.base07-rgb-g + "," + config.lib.stylix.colors.base07-rgb-b + "," + ''0.15);
        }

        #searchbox {
                background: none;
                border-color: #'' + config.lib.stylix.colors.base07 + '';

                color: #'' + config.lib.stylix.colors.base07 + '';

                margin-top: 20px;
                margin-bottom: 20px;

                font-size: 20px;
        }

        #separator {
                background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.55);

                color: #'' + config.lib.stylix.colors.base07 + '';
                margin-left: 500px;
                margin-right: 500px;
                margin-top: 10px;
                margin-bottom: 10px
        }

        #description {
                margin-bottom: 20px
        }
    '';
    home.file.".config/nwg-launchers/nwggrid/terminal".text = "alacritty -e";
    home.file.".config/nwg-drawer/drawer.css".text = ''
        window {
                background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.55);
                color: #'' + config.lib.stylix.colors.base07 + ''
        }

        /* search entry */
        entry {
                background-color: rgba('' + config.lib.stylix.colors.base01-rgb-r + "," + config.lib.stylix.colors.base01-rgb-g + "," + config.lib.stylix.colors.base01-rgb-b + "," + ''0.45);
        }

        button, image {
                background: none;
                border: none
        }

        button:hover {
                background-color: rgba('' + config.lib.stylix.colors.base02-rgb-r + "," + config.lib.stylix.colors.base02-rgb-g + "," + config.lib.stylix.colors.base02-rgb-b + "," + ''0.45);
        }

        /* in case you wanted to give category buttons a different look */
        #category-button {
                margin: 0 10px 0 10px
        }

        #pinned-box {
                padding-bottom: 5px;
                border-bottom: 1px dotted;
                border-color: #'' + config.lib.stylix.colors.base07 + '';
        }

        #files-box {
                padding: 5px;
                border: 1px dotted gray;
                border-radius: 15px
                border-color: #'' + config.lib.stylix.colors.base07 + '';
        }
    '';
    home.file.".config/libinput-gestures.conf".text = ''
    gesture swipe up 3	hyprctl dispatch hyprexpo:expo toggle
    gesture swipe down 3	nwggrid-wrapper

    gesture swipe right 3	hyprnome
    gesture swipe left 3	hyprnome --previous
    gesture swipe up 4	hyprctl dispatch movewindow u
    gesture swipe down 4	hyprctl dispatch movewindow d
    gesture swipe left 4	hyprctl dispatch movewindow l
    gesture swipe right 4	hyprctl dispatch movewindow r
    gesture pinch in	hyprctl dispatch fullscreen 1
    gesture pinch out	hyprctl dispatch fullscreen 1
    '';

    services.udiskie.enable = true;
    services.udiskie.tray = "always";
    programs.fuzzel.enable = true;
    programs.fuzzel.package = pkgs.fuzzel.overrideAttrs (oldAttrs: {
            patches = ./patches/fuzzelmouseinput.patch;
        });
    programs.fuzzel.settings = {
        main = {
            font = userSettings.font + ":size=20";
            dpi-aware = "no";
            show-actions = "yes";
            terminal = "${pkgs.alacritty}/bin/alacritty";
        };
        colors = {
            background = config.lib.stylix.colors.base00 + "bf";
            text = config.lib.stylix.colors.base07 + "ff";
            match = config.lib.stylix.colors.base05 + "ff";
            selection = config.lib.stylix.colors.base08 + "ff";
            selection-text = config.lib.stylix.colors.base00 + "ff";
            selection-match = config.lib.stylix.colors.base05 + "ff";
            border = config.lib.stylix.colors.base08 + "ff";
        };
        border = {
            width = 3;
            radius = 7;
        };
    };
    services.fnott.enable = true;
    services.fnott.settings = {
        main = {
            anchor = "bottom-right";
            stacking-order = "top-down";
            min-width = 400;
            title-font = userSettings.font + ":size=14";
            summary-font = userSettings.font + ":size=12";
            body-font = userSettings.font + ":size=11";
            border-size = 0;
        };
        low = {
            background = config.lib.stylix.colors.base00 + "e6";
            title-color = config.lib.stylix.colors.base03 + "ff";
            summary-color = config.lib.stylix.colors.base03 + "ff";
            body-color = config.lib.stylix.colors.base03 + "ff";
            idle-timeout = 150;
            max-timeout = 30;
            default-timeout = 8;
        };
        normal = {
            background = config.lib.stylix.colors.base00 + "e6";
            title-color = config.lib.stylix.colors.base07 + "ff";
            summary-color = config.lib.stylix.colors.base07 + "ff";
            body-color = config.lib.stylix.colors.base07 + "ff";
            idle-timeout = 150;
            max-timeout = 30;
            default-timeout = 8;
        };
        critical = {
            background = config.lib.stylix.colors.base00 + "e6";
            title-color = config.lib.stylix.colors.base08 + "ff";
            summary-color = config.lib.stylix.colors.base08 + "ff";
            body-color = config.lib.stylix.colors.base08 + "ff";
            idle-timeout = 0;
            max-timeout = 0;
            default-timeout = 0;
        };
    };
}
