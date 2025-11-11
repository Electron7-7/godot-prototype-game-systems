class_name Main3D
extends Node3D

static var has_player: bool = false
static var player : Player3D

var _player_scene := preload("res://objects/scenes/player_3d.tscn")
var _current_level: Level3D = null


func destroy() -> void:
      exit_level()
      destroy_player()


func load_level(new_level: Level3D) -> Error:
      exit_level()
      _current_level = new_level
      add_child(_current_level)
      return OK


func exit_level() -> void:
      despawn_player()
      if _current_level != null:
            _current_level.queue_free()
            _current_level = null


func destroy_player() -> void:
      if player != null:
            despawn_player()
            player.queue_free()
            player = null


## Removes [member player] from the scene, but does not delete it, and sets
## [member has_player] to [code]false[/code]. Returns [code]true[/code] if
## [member has_player] was true and [code]false[/code] if it was false.
func despawn_player() -> void:
      if not has_player:
            return
      remove_child(player)
      has_player = false


## Attempts to add [member player] to the scene. If successful, the returned [SafeReturn]
## object will contain the [member player] and an [constant OK] status.[br]
## If the player is already in the scene, or the given [param spawn_position] is
## invalid (according to [method check_if_valid_spawn_position]
func spawn_player(spawn_rotation: Quaternion = Quaternion.IDENTITY) -> SafeReturn:
      if _current_level == null:
            return SafeReturn.new(null, ERR_INVALID_DATA)
      var spawn_position = _current_level.get_player_spawn()
      if has_player:
            push_error("Player already spawned. Please use `move_player` or `respawn_player` instead.")
            return SafeReturn.new(null, Error.ERR_ALREADY_EXISTS)
      elif not check_if_valid_spawn_position(spawn_position, gPlayerData.spawn_scale):
            push_error("Invalid spawn location: %v" % spawn_position)
            return SafeReturn.new(null, Error.ERR_CANT_CREATE)
      player = _player_scene.instantiate()
      add_child(player, true)
      has_player = true
      player.global_position = spawn_position
      player.quaternion = spawn_rotation
      return SafeReturn.new(player)


func check_if_valid_spawn_position(spawn_position: Vector3, spawn_radius: Vector3) -> bool:
      var l_Status: bool = true
      var l_TestShape := CollisionShape3D.new()
      var l_TestArea := Area3D.new()
      add_child(l_TestShape)
      l_TestShape.add_child(l_TestArea)
      l_TestShape.shape = BoxShape3D.new()
      l_TestShape.global_position = spawn_position
      l_TestShape.scale = spawn_radius
      if l_TestArea.get_overlapping_bodies().size() > 0:
            l_Status = false
      l_TestArea.queue_free()
      l_TestShape.queue_free()
      return l_Status
