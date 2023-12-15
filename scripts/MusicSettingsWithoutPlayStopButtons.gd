extends VBoxContainer


@export var label: String
@export var bus_name: String
#export var audio_stream_player_path: NodePath


var audio_stream_player: AudioStreamPlayer

func _ready():
	$Label.text = label
#	audio_stream_player = get_node(audio_stream_player_path)


func _on_HSlider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if value > $HSlider.min_value:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, value)
	else:
		AudioServer.set_bus_mute(bus_idx, true)

