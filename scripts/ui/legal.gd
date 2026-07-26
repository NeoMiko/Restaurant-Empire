extends BaseScreen

const GODOT_NOTICE := """Godot Engine
Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."""

const PRIVACY_SUMMARY := """Current prototype privacy summary — 26 July 2026

Restaurant Empire works offline. This build does not create accounts, display advertisements, use analytics or transmit gameplay data to a server.

The game stores progress, settings, inventory and timestamps only in a local save file on the device. The timestamp is used to calculate capped offline progress. You can erase this data by clearing the app data or uninstalling the app.

No personal data is intentionally collected, shared or sold by this build.

Publisher contact: [TO COMPLETE BEFORE PUBLICATION: contact e-mail]
Public privacy-policy URL: [TO COMPLETE BEFORE PUBLICATION]

The complete publication draft is included in docs/PRIVACY_POLICY_DRAFT.md. This summary must be updated if advertising, analytics, cloud saves, accounts, purchases or other SDKs are added."""

const PROJECT_LICENSE := """Game project

The repository currently contains an MIT License:
Copyright (c) 2026 Kamil_Tchoryk.

Before publishing, the owner should consciously confirm whether the game itself remains MIT-licensed or uses a proprietary end-user license. This publisher decision has not been guessed automatically.

No third-party art, music or audio assets are included in the current placeholder build.

Third-party technology

This game uses Godot Engine under the MIT License. The full required notice follows below.

"""

func _ready() -> void:
	build_shell("Legal, Privacy & Credits")
	SceneManager.current_scene_id = "legal"
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 22)
	body.add_child(tabs)
	_add_text_tab(tabs, "Privacy", PRIVACY_SUMMARY)
	_add_text_tab(tabs, "Licenses", PROJECT_LICENSE + GODOT_NOTICE)

func _add_text_tab(parent: TabContainer, tab_name: String, text: String) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 21)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(label)
