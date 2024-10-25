@tool
extends EditorPlugin

const UpdateNotifyToolScene = preload("updater/update_notify_tool.tscn")

var update_notify_tool_instance: Node
var inspector_plugin
var plugin_custom_type: String = "CharacterGeneratorToolImporter"


func _enter_tree() -> void:
	MyPluginSettings.set_update_notification()
	_setup_updater()
	
	if not DirAccess.dir_exists_absolute(MyPluginSettings.PluginTemporaryReleaseUpdateDirectoryPath):
		DirAccess.make_dir_recursive_absolute(MyPluginSettings.PluginTemporaryReleaseUpdateDirectoryPath)
	
	add_custom_type(plugin_custom_type, "Node", preload("src/importer.gd"), preload("assets/character-generator-importer-tool.svg"))
	
	inspector_plugin = preload("inspector/inspector_button_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)
	

func _exit_tree() -> void:
	MyPluginSettings.remove_settings()
	
	if update_notify_tool_instance:
		update_notify_tool_instance.free()
		update_notify_tool_instance = null
		
	remove_custom_type(plugin_custom_type)
	remove_inspector_plugin(inspector_plugin)


func _get_plugin_name() -> String:
	return "Character Generator Tool Importer"
	
## Update tool referenced from https://github.com/MikeSchulze/gdUnit4/blob/master/addons/gdUnit4
func _setup_updater() -> void:
	if MyPluginSettings.is_update_notification_enabled():
		update_notify_tool_instance = UpdateNotifyToolScene.instantiate()
		Engine.get_main_loop().root.add_child.call_deferred(update_notify_tool_instance)