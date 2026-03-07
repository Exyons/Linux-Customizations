#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "======================================================="
echo "      HyprPanel: Custom Theme & Modules Injector       "
echo "======================================================="

# Define the target directories
HP_DIR="$HOME/.config/hyprpanel"
SCRIPTS_DIR="$HP_DIR/scripts"

echo "---> [1/4] Creating HyprPanel directory structure..."
mkdir -p "$SCRIPTS_DIR"

echo "---> [2/4] Injecting config.json..."
cat << 'EOF' > "$HP_DIR/config.json"
{
  "bar.customModules.storage.paths": [
    "/"
  ],
  "scalingPriority": "both",
  "theme.bar.scaling": 65,
  "theme.bar.transparent": true,
  "theme.bar.buttons.padding_x": "0.5rem",
  "theme.bar.border.location": "none",
  "theme.bar.enableShadow": false,
  "theme.bar.dropdownGap": "2.2em",
  "theme.bar.menus.menu.dashboard.scaling": 80,
  "theme.bar.menus.menu.dashboard.confirmation_scaling": 80,
  "theme.bar.menus.menu.media.scaling": 80,
  "theme.bar.menus.menu.volume.scaling": 80,
  "theme.bar.menus.menu.network.scaling": 80,
  "theme.bar.menus.menu.bluetooth.scaling": 80,
  "theme.bar.menus.menu.battery.scaling": 80,
  "theme.bar.menus.menu.clock.scaling": 80,
  "theme.bar.menus.menu.notifications.scaling": 80,
  "theme.bar.menus.menu.power.scaling": 80,
  "theme.bar.menus.popover.scaling": 70,
  "theme.tooltip.scaling": 80,
  "theme.bar.menus.menu.notifications.scrollbar.color": "#b4befe",
  "theme.bar.menus.menu.notifications.pager.label": "#9399b2",
  "theme.bar.menus.menu.notifications.pager.button": "#b4befe",
  "theme.bar.menus.menu.notifications.pager.background": "#11111b",
  "theme.bar.menus.menu.notifications.switch.puck": "#454759",
  "theme.bar.menus.menu.notifications.switch.disabled": "#313245",
  "theme.bar.menus.menu.notifications.switch.enabled": "#b4befe",
  "theme.bar.menus.menu.notifications.clear": "#f38ba8",
  "theme.bar.menus.menu.notifications.switch_divider": "#45475a",
  "theme.bar.menus.menu.notifications.border": "#313244",
  "theme.bar.menus.menu.notifications.card": "#1e1e2e",
  "theme.bar.menus.menu.notifications.background": "#11111b",
  "theme.bar.menus.menu.notifications.no_notifications_label": "#313244",
  "theme.bar.menus.menu.notifications.label": "#b4befe",
  "theme.bar.menus.menu.power.buttons.sleep.icon": "#181824",
  "theme.bar.menus.menu.power.buttons.sleep.text": "#89dceb",
  "theme.bar.menus.menu.power.buttons.sleep.icon_background": "#89dceb",
  "theme.bar.menus.menu.power.buttons.sleep.background": "#1e1e2e",
  "theme.bar.menus.menu.power.buttons.logout.icon": "#181824",
  "theme.bar.menus.menu.power.buttons.logout.text": "#a6e3a1",
  "theme.bar.menus.menu.power.buttons.logout.icon_background": "#a6e3a1",
  "theme.bar.menus.menu.power.buttons.logout.background": "#1e1e2e",
  "theme.bar.menus.menu.power.buttons.restart.icon": "#181824",
  "theme.bar.menus.menu.power.buttons.restart.text": "#fab387",
  "theme.bar.menus.menu.power.buttons.restart.icon_background": "#fab387",
  "theme.bar.menus.menu.power.buttons.restart.background": "#1e1e2e",
  "theme.bar.menus.menu.power.buttons.shutdown.icon": "#181824",
  "theme.bar.menus.menu.power.buttons.shutdown.text": "#f38ba8",
  "theme.bar.menus.menu.power.buttons.shutdown.icon_background": "#f38ba7",
  "theme.bar.menus.menu.power.buttons.shutdown.background": "#1e1e2e",
  "theme.bar.menus.menu.power.border.color": "#313244",
  "theme.bar.menus.menu.power.background.color": "#11111b",
  "theme.bar.menus.menu.dashboard.monitors.disk.label": "#f5c2e7",
  "theme.bar.menus.menu.dashboard.monitors.disk.bar": "#f5c2e8",
  "theme.bar.menus.menu.dashboard.monitors.disk.icon": "#f5c2e7",
  "theme.bar.menus.menu.dashboard.monitors.gpu.label": "#a6e3a1",
  "theme.bar.menus.menu.dashboard.monitors.gpu.bar": "#a6e3a2",
  "theme.bar.menus.menu.dashboard.monitors.gpu.icon": "#a6e3a1",
  "theme.bar.menus.menu.dashboard.monitors.ram.label": "#f9e2af",
  "theme.bar.menus.menu.dashboard.monitors.ram.bar": "#f9e2ae",
  "theme.bar.menus.menu.dashboard.monitors.ram.icon": "#f9e2af",
  "theme.bar.menus.menu.dashboard.monitors.cpu.label": "#eba0ac",
  "theme.bar.menus.menu.dashboard.monitors.cpu.bar": "#eba0ad",
  "theme.bar.menus.menu.dashboard.monitors.cpu.icon": "#eba0ac",
  "theme.bar.menus.menu.dashboard.monitors.bar_background": "#45475a",
  "theme.bar.menus.menu.dashboard.directories.right.bottom.color": "#b4befe",
  "theme.bar.menus.menu.dashboard.directories.right.middle.color": "#cba6f7",
  "theme.bar.menus.menu.dashboard.directories.right.top.color": "#94e2d5",
  "theme.bar.menus.menu.dashboard.directories.left.bottom.color": "#eba0ac",
  "theme.bar.menus.menu.dashboard.directories.left.middle.color": "#f9e2af",
  "theme.bar.menus.menu.dashboard.directories.left.top.color": "#f5c2e7",
  "theme.bar.menus.menu.dashboard.controls.input.text": "#181824",
  "theme.bar.menus.menu.dashboard.controls.input.background": "#f5c2e7",
  "theme.bar.menus.menu.dashboard.controls.volume.text": "#181824",
  "theme.bar.menus.menu.dashboard.controls.volume.background": "#eba0ac",
  "theme.bar.menus.menu.dashboard.controls.notifications.text": "#181824",
  "theme.bar.menus.menu.dashboard.controls.notifications.background": "#f9e2af",
  "theme.bar.menus.menu.dashboard.controls.bluetooth.text": "#181824",
  "theme.bar.menus.menu.dashboard.controls.bluetooth.background": "#89dceb",
  "theme.bar.menus.menu.dashboard.controls.wifi.text": "#181824",
  "theme.bar.menus.menu.dashboard.controls.wifi.background": "#cba6f7",
  "theme.bar.menus.menu.dashboard.controls.disabled": "#585b70",
  "theme.bar.menus.menu.dashboard.shortcuts.recording": "#a6e3a1",
  "theme.bar.menus.menu.dashboard.shortcuts.text": "#181824",
  "theme.bar.menus.menu.dashboard.shortcuts.background": "#b4befe",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.button_text": "#11111a",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.deny": "#f38ba8",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.confirm": "#a6e3a1",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.body": "#cdd6f4",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.label": "#b4befe",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.border": "#313244",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.background": "#11111b",
  "theme.bar.menus.menu.dashboard.powermenu.confirmation.card": "#1e1e2e",
  "theme.bar.menus.menu.dashboard.powermenu.sleep": "#89dceb",
  "theme.bar.menus.menu.dashboard.powermenu.logout": "#a6e3a1",
  "theme.bar.menus.menu.dashboard.powermenu.restart": "#fab387",
  "theme.bar.menus.menu.dashboard.powermenu.shutdown": "#f38ba8",
  "theme.bar.menus.menu.dashboard.profile.name": "#f5c2e7",
  "theme.bar.menus.menu.dashboard.border.color": "#313244",
  "theme.bar.menus.menu.dashboard.background.color": "#11111b",
  "theme.bar.menus.menu.dashboard.card.color": "#1e1e2e",
  "theme.bar.menus.menu.clock.weather.hourly.temperature": "#f5c2e7",
  "theme.bar.menus.menu.clock.weather.hourly.icon": "#f5c2e7",
  "theme.bar.menus.menu.clock.weather.hourly.time": "#f5c2e7",
  "theme.bar.menus.menu.clock.weather.thermometer.extremelycold": "#89dceb",
  "theme.bar.menus.menu.clock.weather.thermometer.cold": "#89b4fa",
  "theme.bar.menus.menu.clock.weather.thermometer.moderate": "#b4befe",
  "theme.bar.menus.menu.clock.weather.thermometer.hot": "#fab387",
  "theme.bar.menus.menu.clock.weather.thermometer.extremelyhot": "#f38ba8",
  "theme.bar.menus.menu.clock.weather.stats": "#f5c2e7",
  "theme.bar.menus.menu.clock.weather.status": "#94e2d5",
  "theme.bar.menus.menu.clock.weather.temperature": "#cdd6f4",
  "theme.bar.menus.menu.clock.weather.icon": "#f5c2e7",
  "theme.bar.menus.menu.clock.calendar.contextdays": "#585b70",
  "theme.bar.menus.menu.clock.calendar.days": "#cdd6f4",
  "theme.bar.menus.menu.clock.calendar.currentday": "#f5c2e7",
  "theme.bar.menus.menu.clock.calendar.paginator": "#f5c2e6",
  "theme.bar.menus.menu.clock.calendar.weekdays": "#f5c2e7",
  "theme.bar.menus.menu.clock.calendar.yearmonth": "#94e2d5",
  "theme.bar.menus.menu.clock.time.timeperiod": "#94e2d5",
  "theme.bar.menus.menu.clock.time.time": "#f5c2e7",
  "theme.bar.menus.menu.clock.text": "#cdd6f4",
  "theme.bar.menus.menu.clock.border.color": "#313244",
  "theme.bar.menus.menu.clock.background.color": "#11111b",
  "theme.bar.menus.menu.clock.card.color": "#1e1e2e",
  "theme.bar.menus.menu.battery.slider.puck": "#6c7086",
  "theme.bar.menus.menu.battery.slider.backgroundhover": "#45475a",
  "theme.bar.menus.menu.battery.slider.background": "#585b71",
  "theme.bar.menus.menu.battery.slider.primary": "#f9e2af",
  "theme.bar.menus.menu.battery.icons.active": "#f9e2af",
  "theme.bar.menus.menu.battery.icons.passive": "#9399b2",
  "theme.bar.menus.menu.battery.listitems.active": "#f9e2af",
  "theme.bar.menus.menu.battery.listitems.passive": "#cdd6f3",
  "theme.bar.menus.menu.battery.text": "#cdd6f4",
  "theme.bar.menus.menu.battery.label.color": "#f9e2af",
  "theme.bar.menus.menu.battery.border.color": "#313244",
  "theme.bar.menus.menu.battery.background.color": "#11111b",
  "theme.bar.menus.menu.battery.card.color": "#1e1e2e",
  "theme.bar.menus.menu.systray.dropdownmenu.divider": "#1e1e2e",
  "theme.bar.menus.menu.systray.dropdownmenu.text": "#cdd6f4",
  "theme.bar.menus.menu.systray.dropdownmenu.background": "#11111b",
  "theme.bar.menus.menu.bluetooth.iconbutton.active": "#89dceb",
  "theme.bar.menus.menu.bluetooth.iconbutton.passive": "#cdd6f4",
  "theme.bar.menus.menu.bluetooth.icons.active": "#89dceb",
  "theme.bar.menus.menu.bluetooth.icons.passive": "#9399b2",
  "theme.bar.menus.menu.bluetooth.listitems.active": "#89dcea",
  "theme.bar.menus.menu.bluetooth.listitems.passive": "#cdd6f4",
  "theme.bar.menus.menu.bluetooth.switch.puck": "#454759",
  "theme.bar.menus.menu.bluetooth.switch.disabled": "#313245",
  "theme.bar.menus.menu.bluetooth.switch.enabled": "#89dceb",
  "theme.bar.menus.menu.bluetooth.switch_divider": "#45475a",
  "theme.bar.menus.menu.bluetooth.status": "#6c7086",
  "theme.bar.menus.menu.bluetooth.text": "#cdd6f4",
  "theme.bar.menus.menu.bluetooth.label.color": "#89dceb",
  "theme.bar.menus.menu.bluetooth.scroller.color": "#89dceb",
  "theme.bar.menus.menu.bluetooth.border.color": "#313244",
  "theme.bar.menus.menu.bluetooth.background.color": "#11111b",
  "theme.bar.menus.menu.bluetooth.card.color": "#1e1e2e",
  "theme.bar.menus.menu.network.iconbuttons.active": "#cba6f7",
  "theme.bar.menus.menu.network.iconbuttons.passive": "#cdd6f4",
  "theme.bar.menus.menu.network.icons.active": "#cba6f7",
  "theme.bar.menus.menu.network.icons.passive": "#9399b2",
  "theme.bar.menus.menu.network.listitems.active": "#cba6f6",
  "theme.bar.menus.menu.network.listitems.passive": "#cdd6f4",
  "theme.bar.menus.menu.network.status.color": "#6c7086",
  "theme.bar.menus.menu.network.text": "#cdd6f4",
  "theme.bar.menus.menu.network.label.color": "#cba6f7",
  "theme.bar.menus.menu.network.scroller.color": "#cba6f7",
  "theme.bar.menus.menu.network.border.color": "#313244",
  "theme.bar.menus.menu.network.background.color": "#11111b",
  "theme.bar.menus.menu.network.card.color": "#1e1e2e",
  "theme.bar.menus.menu.volume.input_slider.puck": "#585b70",
  "theme.bar.menus.menu.volume.input_slider.backgroundhover": "#45475a",
  "theme.bar.menus.menu.volume.input_slider.background": "#585b71",
  "theme.bar.menus.menu.volume.input_slider.primary": "#eba0ac",
  "theme.bar.menus.menu.volume.audio_slider.puck": "#585b70",
  "theme.bar.menus.menu.volume.audio_slider.backgroundhover": "#45475a",
  "theme.bar.menus.menu.volume.audio_slider.background": "#585b71",
  "theme.bar.menus.menu.volume.audio_slider.primary": "#eba0ac",
  "theme.bar.menus.menu.volume.icons.active": "#eba0ac",
  "theme.bar.menus.menu.volume.icons.passive": "#9399b2",
  "theme.bar.menus.menu.volume.iconbutton.active": "#eba0ac",
  "theme.bar.menus.menu.volume.iconbutton.passive": "#cdd6f4",
  "theme.bar.menus.menu.volume.listitems.active": "#eba0ab",
  "theme.bar.menus.menu.volume.listitems.passive": "#cdd6f4",
  "theme.bar.menus.menu.volume.text": "#cdd6f4",
  "theme.bar.menus.menu.volume.label.color": "#eba0ac",
  "theme.bar.menus.menu.volume.border.color": "#313244",
  "theme.bar.menus.menu.volume.background.color": "#11111b",
  "theme.bar.menus.menu.volume.card.color": "#1e1e2e",
  "theme.bar.menus.menu.media.slider.puck": "#6c7086",
  "theme.bar.menus.menu.media.slider.backgroundhover": "#45475a",
  "theme.bar.menus.menu.media.slider.background": "#585b71",
  "theme.bar.menus.menu.media.slider.primary": "#f5c2e7",
  "theme.bar.menus.menu.media.buttons.text": "#11111b",
  "theme.bar.menus.menu.media.buttons.background": "#b4beff",
  "theme.bar.menus.menu.media.buttons.enabled": "#94e2d4",
  "theme.bar.menus.menu.media.buttons.inactive": "#585b70",
  "theme.bar.menus.menu.media.border.color": "#313244",
  "theme.bar.menus.menu.media.card.color": "#1e1e2e",
  "theme.bar.menus.menu.media.background.color": "#11111b",
  "theme.bar.menus.menu.media.album": "#f5c2e8",
  "theme.bar.menus.menu.media.timestamp": "#cdd6f4",
  "theme.bar.menus.menu.media.artist": "#94e2d6",
  "theme.bar.menus.menu.media.song": "#b4beff",
  "theme.bar.menus.tooltip.text": "#cdd6f4",
  "theme.bar.menus.tooltip.background": "#11111b",
  "theme.bar.menus.dropdownmenu.divider": "#1e1e2e",
  "theme.bar.menus.dropdownmenu.text": "#cdd6f4",
  "theme.bar.menus.dropdownmenu.background": "#11111b",
  "theme.bar.menus.slider.puck": "#6c7086",
  "theme.bar.menus.slider.backgroundhover": "#45475a",
  "theme.bar.menus.slider.background": "#585b71",
  "theme.bar.menus.slider.primary": "#b4befe",
  "theme.bar.menus.progressbar.background": "#45475a",
  "theme.bar.menus.progressbar.foreground": "#b4befe",
  "theme.bar.menus.iconbuttons.active": "#b4beff",
  "theme.bar.menus.iconbuttons.passive": "#cdd6f3",
  "theme.bar.menus.buttons.text": "#181824",
  "theme.bar.menus.buttons.disabled": "#585b71",
  "theme.bar.menus.buttons.active": "#f5c2e6",
  "theme.bar.menus.buttons.default": "#b4befe",
  "theme.bar.menus.check_radio_button.active": "#b4beff",
  "theme.bar.menus.check_radio_button.background": "#45475a",
  "theme.bar.menus.switch.puck": "#454759",
  "theme.bar.menus.switch.disabled": "#313245",
  "theme.bar.menus.switch.enabled": "#b4befe",
  "theme.bar.menus.icons.active": "#b4befe",
  "theme.bar.menus.icons.passive": "#585b70",
  "theme.bar.menus.listitems.active": "#b4befd",
  "theme.bar.menus.listitems.passive": "#cdd6f4",
  "theme.bar.menus.popover.border": "#181824",
  "theme.bar.menus.popover.background": "#181824",
  "theme.bar.menus.popover.text": "#b4befe",
  "theme.bar.menus.label": "#b4befe",
  "theme.bar.menus.feinttext": "#313244",
  "theme.bar.menus.dimtext": "#585b70",
  "theme.bar.menus.text": "#cdd6f4",
  "theme.bar.menus.border.color": "#313244",
  "theme.bar.menus.cards": "#1e1e2e",
  "theme.bar.menus.background": "#11111b",
  "theme.bar.buttons.modules.power.icon_background": "#f38ba8",
  "theme.bar.buttons.modules.power.icon": "#181825",
  "theme.bar.buttons.modules.power.background": "#242438",
  "theme.bar.buttons.modules.power.border": "#f38ba8",
  "theme.bar.buttons.modules.weather.icon_background": "#b4befe",
  "theme.bar.buttons.modules.weather.icon": "#242438",
  "theme.bar.buttons.modules.weather.text": "#b4befe",
  "theme.bar.buttons.modules.weather.background": "#242438",
  "theme.bar.buttons.modules.weather.border": "#b4befe",
  "theme.bar.buttons.modules.updates.icon_background": "#cba6f7",
  "theme.bar.buttons.modules.updates.icon": "#181825",
  "theme.bar.buttons.modules.updates.text": "#cba6f7",
  "theme.bar.buttons.modules.updates.background": "#242438",
  "theme.bar.buttons.modules.updates.border": "#cba6f7",
  "theme.bar.buttons.modules.kbLayout.icon_background": "#89dceb",
  "theme.bar.buttons.modules.kbLayout.icon": "#181825",
  "theme.bar.buttons.modules.kbLayout.text": "#89dceb",
  "theme.bar.buttons.modules.kbLayout.background": "#242438",
  "theme.bar.buttons.modules.kbLayout.border": "#89dceb",
  "theme.bar.buttons.modules.netstat.icon_background": "#a6e3a1",
  "theme.bar.buttons.modules.netstat.icon": "#181825",
  "theme.bar.buttons.modules.netstat.text": "#a6e3a1",
  "theme.bar.buttons.modules.netstat.background": "#242438",
  "theme.bar.buttons.modules.netstat.border": "#a6e3a1",
  "theme.bar.buttons.modules.storage.icon_background": "#f5c2e7",
  "theme.bar.buttons.modules.storage.icon": "#181825",
  "theme.bar.buttons.modules.storage.text": "#f5c2e7",
  "theme.bar.buttons.modules.storage.background": "#242438",
  "theme.bar.buttons.modules.storage.border": "#f5c2e7",
  "theme.bar.buttons.modules.cpu.icon_background": "#f38ba8",
  "theme.bar.buttons.modules.cpu.icon": "#181825",
  "theme.bar.buttons.modules.cpu.text": "#f38ba8",
  "theme.bar.buttons.modules.cpu.background": "#242438",
  "theme.bar.buttons.modules.cpu.border": "#f38ba8",
  "theme.bar.buttons.modules.ram.icon_background": "#f9e2af",
  "theme.bar.buttons.modules.ram.icon": "#181825",
  "theme.bar.buttons.modules.ram.text": "#f9e2af",
  "theme.bar.buttons.modules.ram.background": "#242438",
  "theme.bar.buttons.modules.ram.border": "#f9e2af",
  "theme.bar.buttons.notifications.total": "#b4befe",
  "theme.bar.buttons.notifications.icon_background": "#b4befe",
  "theme.bar.buttons.notifications.icon": "#1e1e2e",
  "theme.bar.buttons.notifications.background": "#242438",
  "theme.bar.buttons.notifications.border": "#b4befe",
  "theme.bar.buttons.clock.icon_background": "#f5c2e7",
  "theme.bar.buttons.clock.icon": "#232338",
  "theme.bar.buttons.clock.text": "#f5c2e7",
  "theme.bar.buttons.clock.background": "#242438",
  "theme.bar.buttons.clock.border": "#f5c2e7",
  "theme.bar.buttons.battery.icon_background": "#f9e2af",
  "theme.bar.buttons.battery.icon": "#242438",
  "theme.bar.buttons.battery.text": "#f9e2af",
  "theme.bar.buttons.battery.background": "#242438",
  "theme.bar.buttons.battery.border": "#f9e2af",
  "theme.bar.buttons.systray.background": "#242438",
  "theme.bar.buttons.systray.border": "#b4befe",
  "theme.bar.buttons.systray.customIcon": "#cdd6f4",
  "theme.bar.buttons.bluetooth.icon_background": "#89dbeb",
  "theme.bar.buttons.bluetooth.icon": "#1e1e2e",
  "theme.bar.buttons.bluetooth.text": "#89dceb",
  "theme.bar.buttons.bluetooth.background": "#242438",
  "theme.bar.buttons.bluetooth.border": "#89dceb",
  "theme.bar.buttons.network.icon_background": "#caa6f7",
  "theme.bar.buttons.network.icon": "#242438",
  "theme.bar.buttons.network.text": "#cba6f7",
  "theme.bar.buttons.network.background": "#242438",
  "theme.bar.buttons.network.border": "#cba6f7",
  "theme.bar.buttons.volume.icon_background": "#eba0ac",
  "theme.bar.buttons.volume.icon": "#242438",
  "theme.bar.buttons.volume.text": "#eba0ac",
  "theme.bar.buttons.volume.background": "#242438",
  "theme.bar.buttons.volume.border": "#eba0ac",
  "theme.bar.buttons.media.icon_background": "#b4befe",
  "theme.bar.buttons.media.icon": "#1e1e2e",
  "theme.bar.buttons.media.text": "#b4befe",
  "theme.bar.buttons.media.background": "#242438",
  "theme.bar.buttons.media.border": "#b4befe",
  "theme.bar.buttons.windowtitle.icon_background": "#f5c2e7",
  "theme.bar.buttons.windowtitle.icon": "#1e1e2e",
  "theme.bar.buttons.windowtitle.text": "#f5c2e7",
  "theme.bar.buttons.windowtitle.border": "#f5c2e7",
  "theme.bar.buttons.windowtitle.background": "#242438",
  "theme.bar.buttons.workspaces.numbered_active_underline_color": "#f5c2e7",
  "theme.bar.buttons.workspaces.numbered_active_highlighted_text_color": "#181825",
  "theme.bar.buttons.workspaces.hover": "#f5c2e7",
  "theme.bar.buttons.workspaces.active": "#f5c2e7",
  "theme.bar.buttons.workspaces.occupied": "#f2cdcd",
  "theme.bar.buttons.workspaces.available": "#89dceb",
  "theme.bar.buttons.workspaces.border": "#f5c2e7",
  "theme.bar.buttons.workspaces.background": "#242438",
  "theme.bar.buttons.dashboard.icon": "#1e1e2e",
  "theme.bar.buttons.dashboard.border": "#f9e2af",
  "theme.bar.buttons.dashboard.background": "#f9e2af",
  "theme.bar.buttons.icon": "#242438",
  "theme.bar.buttons.text": "#b4befe",
  "theme.bar.buttons.hover": "#45475a",
  "theme.bar.buttons.icon_background": "#b4befe",
  "theme.bar.buttons.background": "#242438",
  "theme.bar.buttons.borderColor": "#b4befe",
  "theme.bar.buttons.style": "split",
  "theme.bar.background": "#11111b",
  "theme.osd.label": "#b4beff",
  "theme.osd.icon": "#11111b",
  "theme.osd.bar_overflow_color": "#f38ba7",
  "theme.osd.bar_empty_color": "#313244",
  "theme.osd.bar_color": "#b4beff",
  "theme.osd.icon_container": "#b4beff",
  "theme.osd.bar_container": "#11111b",
  "theme.notification.close_button.label": "#11111b",
  "theme.notification.close_button.background": "#f38ba7",
  "theme.notification.labelicon": "#b4befe",
  "theme.notification.text": "#cdd6f4",
  "theme.notification.time": "#7f849b",
  "theme.notification.border": "#313243",
  "theme.notification.label": "#b4befe",
  "theme.notification.actions.text": "#181825",
  "theme.notification.actions.background": "#b4befd",
  "theme.notification.background": "#181826",
  "theme.bar.buttons.modules.submap.icon": "#181825",
  "theme.bar.buttons.modules.submap.background": "#242438",
  "theme.bar.buttons.modules.submap.icon_background": "#94e2d5",
  "theme.bar.buttons.modules.submap.text": "#94e2d5",
  "theme.bar.buttons.modules.submap.border": "#94e2d5",
  "theme.bar.menus.menu.network.switch.enabled": "#cba6f7",
  "theme.bar.menus.menu.network.switch.disabled": "#313245",
  "theme.bar.menus.menu.network.switch.puck": "#454759",
  "theme.bar.border.color": "#b4befe",
  "theme.bar.buttons.modules.hyprsunset.icon": "#242438",
  "theme.bar.buttons.modules.hyprsunset.background": "#242438",
  "theme.bar.buttons.modules.hyprsunset.icon_background": "#fab387",
  "theme.bar.buttons.modules.hyprsunset.text": "#fab387",
  "theme.bar.buttons.modules.hyprsunset.border": "#fab387",
  "theme.bar.buttons.modules.hypridle.icon": "#242438",
  "theme.bar.buttons.modules.hypridle.background": "#242438",
  "theme.bar.buttons.modules.hypridle.icon_background": "#f5c2e7",
  "theme.bar.buttons.modules.hypridle.text": "#f5c2e7",
  "theme.bar.buttons.modules.hypridle.border": "#f5c2e7",
  "theme.bar.buttons.modules.cava.text": "#94e2d5",
  "theme.bar.buttons.modules.cava.background": "#242438",
  "theme.bar.buttons.modules.cava.icon_background": "#94e2d5",
  "theme.bar.buttons.modules.cava.icon": "#242438",
  "theme.bar.buttons.modules.cava.border": "#94e2d5",
  "theme.bar.buttons.modules.worldclock.text": "#f5c2e7",
  "theme.bar.buttons.modules.worldclock.background": "#242438",
  "theme.bar.buttons.modules.worldclock.icon_background": "#f5c2e7",
  "theme.bar.buttons.modules.worldclock.icon": "#242438",
  "theme.bar.buttons.modules.worldclock.border": "#f5c2e7",
  "theme.bar.buttons.modules.microphone.border": "#a6e3a1",
  "theme.bar.buttons.modules.microphone.background": "#242438",
  "theme.bar.buttons.modules.microphone.text": "#a6e3a1",
  "theme.bar.buttons.modules.microphone.icon": "#242438",
  "theme.bar.buttons.modules.microphone.icon_background": "#a6e3a1",
  "theme.bar.buttons.notifications.hover": "#504945",
  "theme.bar.buttons.clock.hover": "#504945",
  "theme.bar.buttons.battery.hover": "#504945",
  "theme.bar.buttons.systray.hover": "#504945",
  "theme.bar.buttons.bluetooth.hover": "#504945",
  "theme.bar.buttons.network.hover": "#504945",
  "theme.bar.buttons.volume.hover": "#504945",
  "theme.bar.buttons.media.hover": "#504945",
  "theme.bar.buttons.windowtitle.hover": "#504945",
  "theme.bar.buttons.workspaces.numbered_active_text_color": "#24283b",
  "theme.bar.buttons.dashboard.hover": "#504945",
  "theme.bar.menus.menu.power.card.color": "#2a283e",
  "theme.bar.buttons.modules.cpu.hover": "#45475a",
  "theme.bar.buttons.volume.output_icon": "#11111b",
  "theme.bar.buttons.volume.output_text": "#eba0ac",
  "theme.bar.buttons.volume.input_icon": "#11111b",
  "theme.bar.buttons.volume.input_text": "#eba0ac",
  "theme.bar.buttons.volume.separator": "#45475a",
  "theme.bar.buttons.modules.cpuTemp.icon_background": "#fab387",
  "theme.bar.buttons.modules.cpuTemp.icon": "#fab387",
  "theme.bar.buttons.modules.cpuTemp.text": "#fab387",
  "theme.bar.buttons.modules.cpuTemp.border": "#fab387",
  "theme.osd.border.color": "#8ff0a4",
  "wallpaper.image": "/home/osiris/Documents/DOOM_Wallpapers/TDA-WP (20).png",
  "bar.network.showWifiInfo": true,
  "bar.layouts": {
    "0": {
      "left": [
        "dashboard",
        "workspaces",
        "windowtitle"
      ],
      "middle": [
        "media"
      ],
      "right": [
        "custom/netspeed",
        "hypridle",
        "hyprsunset",
        "bluetooth",
        "volume",
        "battery",
        "systray",
        "clock",
        "notifications"
      ]
    },
    "1": {
      "left": [
        "dashboard",
        "workspaces",
        "windowtitle"
      ],
      "middle": [
        "media"
      ],
      "right": [
        "volume",
        "clock",
        "notifications"
      ]
    },
    "2": {
      "left": [
        "dashboard",
        "workspaces",
        "windowtitle"
      ],
      "middle": [
        "media"
      ],
      "right": [
        "volume",
        "clock",
        "notifications"
      ]
    }
  },
  "theme.bar.buttons.network.enableBorder": false,
  "theme.bar.floating": false,
  "theme.bar.location": "top",
  "bar.autoHide": "never",
  "theme.bar.buttons.enableBorders": true,
  "bar.launcher.autoDetectIcon": true,
  "theme.bar.buttons.dashboard.enableBorder": false,
  "bar.workspaces.show_icons": false,
  "bar.workspaces.show_numbered": false,
  "bar.workspaces.workspaceMask": false,
  "bar.workspaces.showWsIcons": false,
  "bar.workspaces.showApplicationIcons": false,
  "theme.bar.buttons.windowtitle.enableBorder": false,
  "bar.windowtitle.icon": true,
  "bar.windowtitle.class_name": true,
  "theme.bar.buttons.modules.netstat.enableBorder": false,
  "bar.customModules.netstat.label": true,
  "bar.customModules.netstat.labelType": "full",
  "bar.customModules.netstat.networkInLabel": "↓",
  "bar.customModules.netstat.networkOutLabel": "↑",
  "bar.customModules.netstat.rateUnit": "auto",
  "bar.customModules.netstat.round": true,
  "bar.customModules.netstat.pollingInterval": 1000,
  "bar.customModules.netstat.leftClick": "menu:network",
  "bar.customModules.netstat.dynamicIcon": true,
  "bar.customModules.netstat.networkInterface": "",
  "bar.customModules.hypridle.label": false,
  "bar.customModules.hypridle.onLabel": "On",
  "bar.customModules.hypridle.offLabel": "Off",
  "bar.customModules.hyprsunset.label": false,
  "bar.customModules.hyprsunset.onLabel": "On",
  "bar.customModules.hyprsunset.offLabel": "Off",
  "bar.customModules.hyprsunset.temperature": "5700k",
  "menus.dashboard.stats.enable_gpu": true,
  "menus.dashboard.shortcuts.left.shortcut1.command": "firefox",
  "menus.dashboard.directories.left.directory3.label": "󰣞  Workspace",
  "menus.dashboard.directories.left.directory3.command": "bash -c \"xdg-open $HOME/Workspace/\"",
  "theme.font.name": "Segoe UI Variable",
  "theme.font.label": "Segoe UI Variable",
  "menus.clock.time.hideSeconds": true,
  "menus.clock.weather.location": "Chopan",
  "menus.clock.weather.unit": "metric",
  "menus.clock.time.military": false,
  "bar.clock.format": "%a %b %d  %I:%M %p",
  "theme.bar.buttons.modules.hyprsunset.enableBorder": true,
  "theme.bar.buttons.modules.submap.enableBorder": false,
  "theme.bar.buttons.modules.storage.enableBorder": false,
  "theme.bar.buttons.modules.cpuTemp.enableBorder": false,
  "bar.customModules.cpu.label": true,
  "theme.bar.buttons.modules.hypridle.enableBorder": true,
  "theme.bar.buttons.volume.enableBorder": false,
  "bar.volume.label": true,
  "theme.bar.buttons.volume.spacing": "0.5em",
  "bar.volume.scrollDown": "hyprpanel vol -1",
  "bar.volume.scrollUp": "hyprpanel vol +1",
  "theme.bar.buttons.bluetooth.enableBorder": true,
  "bar.bluetooth.label": false,
  "theme.bar.buttons.battery.enableBorder": false,
  "bar.battery.label": true,
  "bar.battery.hideLabelWhenFull": true,
  "theme.bar.buttons.clock.enableBorder": false,
  "bar.clock.showIcon": false,
  "bar.clock.showTime": true,
  "bar.media.show_label": true,
  "bar.media.truncation": true,
  "theme.bar.buttons.media.enableBorder": false,
  "theme.bar.buttons.notifications.enableBorder": true,
  "bar.notifications.show_total": false,
  "bar.notifications.hideCountWhenZero": false,
  "bar.workspaces.numbered_active_indicator": "underline",
  "theme.bar.buttons.workspaces.smartHighlight": true,
  "theme.bar.buttons.workspaces.enableBorder": false,
  "bar.windowtitle.custom_title": true,
  "theme.bar.buttons.windowtitle.spacing": "0.7em",
  "theme.osd.orientation": "vertical",
  "bar.network.label": true,
  "theme.bar.buttons.bluetooth.spacing": "0.7em",
  "theme.bar.buttons.systray.enableBorder": false,
  "theme.bar.buttons.clock.spacing": "0.7em",
  "theme.bar.buttons.media.spacing": "0.7em",
  "theme.bar.buttons.notifications.spacing": "0.7em",
  "theme.bar.buttons.modules.microphone.spacing": "0.7em",
  "theme.bar.buttons.modules.microphone.enableBorder": false,
  "theme.bar.buttons.modules.hyprsunset.spacing": "0.5em",
  "theme.bar.buttons.modules.hypridle.spacing": "0.7em",
  "menus.dashboard.powermenu.avatar.image": "~/.face.icon",
  "menus.dashboard.shortcuts.left.shortcut1.tooltip": "Firefox",
  "menus.dashboard.shortcuts.left.shortcut3.command": "code",
  "menus.dashboard.shortcuts.left.shortcut3.icon": "",
  "menus.dashboard.shortcuts.left.shortcut3.tooltip": "VS Code",
  "menus.dashboard.shortcuts.left.shortcut1.icon": "󰈹",
  "menus.transitionTime": 75,
  "theme.font.size": "1.05rem",
  "menus.dashboard.shortcuts.left.shortcut4.command": "hyprlauncher",
  "notifications.showActionsOnHover": false,
  "notifications.position": "bottom left",
  "theme.bar.menus.menu.notifications.height": "58em",
  "menus.dashboard.directories.left.directory1.label": "󰉍  Downloads",
  "menus.dashboard.directories.left.directory2.label": "󰉏  Videos",
  "menus.dashboard.directories.right.directory1.label": "󱧶  Documents",
  "menus.dashboard.directories.right.directory2.label": "󰉏  Pictures",
  "menus.dashboard.directories.right.directory3.label": "󱂵  Home"
}
EOF

echo "---> [3/4] Injecting modules.json and modules.scss..."
cat << 'EOF' > "$HP_DIR/modules.json"
{
  "custom/netspeed": {
    "icon": "⇵",
    "label": "{}",
    "tooltip": "Network throughput",
    "execute": "/home/osiris/.config/hyprpanel/scripts/net_speed.sh",
    "interval": 1000,
    "actions": {
      "onLeftClick": "menu:network"
    }
  }
}
EOF

cat << 'EOF' > "$HP_DIR/modules.scss"
$custom-netspeed-bg-opacity-ratio: $bar-buttons-background_opacity * 0.01;
$custom-netspeed-transparency: 1 - $custom-netspeed-bg-opacity-ratio;

.bar_item_box_visible.cmodule-netspeed {
    background-color: transparentize(
        if($bar-buttons-monochrome, $bar-buttons-background, $bar-buttons-modules-netstat-background),
        $custom-netspeed-transparency
    );
    border: if(
        $bar-buttons-modules-netstat-enableBorder or $bar-buttons-enableBorders,
        $bar-buttons-borderSize solid
            if($bar-buttons-monochrome, $bar-buttons-borderColor, $bar-buttons-modules-netstat-border),
        0em
    );
    padding-right: $bar-buttons-padding_x * 0.45;
}

.module-label.cmodule-netspeed {
    color: if($bar-buttons-monochrome, $bar-buttons-text, $bar-buttons-modules-netstat-text);
    margin-left: $bar-buttons-modules-netstat-spacing;
    border-radius: $bar-buttons-radius;
}

.module-icon.cmodule-netspeed {
    color: if($bar-buttons-monochrome, $bar-buttons-icon, $bar-buttons-modules-netstat-icon);
    font-size: 1.2em;
}

.style2 .module-icon.cmodule-netspeed {
    background: if($bar-buttons-monochrome, $bar-buttons-icon_background, $bar-buttons-modules-netstat-icon_background);
    color: if($bar-buttons-monochrome, $bar-buttons-icon, $bar-buttons-modules-netstat-icon);
    padding-right: $bar-buttons-modules-netstat-spacing;
}

.style2 .module-label.cmodule-netspeed {
    background: transparentize(
        if($bar-buttons-monochrome, $bar-buttons-background, $bar-buttons-modules-netstat-background),
        $custom-netspeed-transparency
    );
    padding-left: $bar-buttons-modules-netstat-spacing * 1.5;
    padding-right: $bar-buttons-padding_x * 0.35;
    margin-left: 0;
}
EOF

echo "---> [4/4] Deploying and securing net_speed.sh..."
cat << 'EOF' > "$SCRIPTS_DIR/net_speed.sh"
#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-full}"
STATE_FILE="/tmp/hyprpanel-netspeed-${USER}-${MODE}.state"

pick_interface() {
  awk '
    BEGIN { best=""; best_total=-1 }
    NR <= 2 { next }
    {
      iface=$1
      sub(/:$/, "", iface)
      rx=$2
      tx=$10
      total=rx+tx
      if (iface != "lo" && total > best_total) {
        best_total=total
        best=iface
      }
    }
    END { print best }
  ' /proc/net/dev
}

read_counters() {
  local iface="$1"
  awk -v iface="${iface}" '
    NR <= 2 { next }
    {
      name=$1
      sub(/:$/, "", name)
      if (name == iface) {
        print $2, $10
        exit
      }
    }
  ' /proc/net/dev
}

format_rate() {
  local bytes_per_sec="${1}"
  awk -v bps="${bytes_per_sec}" '
    BEGIN {
      split("B KB MB GB TB PB", u, " ")
      i=1
      v=bps+0
      while (v >= 1000 && i < 6) {
        v = v / 1000
        i++
      }
      printf "%.0f %s/s", v, u[i]
    }
  '
}

iface="$(pick_interface)"
if [[ -z "${iface}" ]]; then
  echo "↓ 0 B/s ↑ 0 B/s"
  exit 0
fi

read -r rx tx < <(read_counters "${iface}")
now_ms="$(date +%s%3N)"

if [[ -f "${STATE_FILE}" ]]; then
  read -r prev_iface prev_rx prev_tx prev_ts < "${STATE_FILE}" || true
else
  prev_iface=""
  prev_rx="${rx}"
  prev_tx="${tx}"
  prev_ts="${now_ms}"
fi

if [[ "${prev_iface}" != "${iface}" ]]; then
  prev_rx="${rx}"
  prev_tx="${tx}"
  prev_ts="${now_ms}"
fi

dt_ms=$(( now_ms - prev_ts ))
if (( dt_ms <= 0 )); then
  dt_ms=1000
fi

drx=$(( rx - prev_rx ))
dtx=$(( tx - prev_tx ))
if (( drx < 0 )); then drx=0; fi
if (( dtx < 0 )); then dtx=0; fi

in_bps=$(( drx * 1000 / dt_ms ))
out_bps=$(( dtx * 1000 / dt_ms ))

printf '%s %s %s %s\n' "${iface}" "${rx}" "${tx}" "${now_ms}" > "${STATE_FILE}"

in_fmt="$(format_rate "${in_bps}")"
out_fmt="$(format_rate "${out_bps}")"

case "${MODE}" in
  down)
    echo "${in_fmt}"
    ;;
  up)
    echo "${out_fmt}"
    ;;
  full|*)
    echo "↓ ${in_fmt} ↑ ${out_fmt}"
    ;;
esac
EOF

# Make the network monitor script executable
chmod +x "$SCRIPTS_DIR/net_speed.sh"

echo "======================================================="
echo "             INJECTION COMPLETE!                       "
echo "======================================================="
echo "To apply these changes, you must restart HyprPanel."
echo "Since you are managing it through UWSM, run this command:"
echo "  pkill hyprpanel && uwsm app -- hyprpanel &"