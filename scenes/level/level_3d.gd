class_name Level3D
extends Node3D

var player_spawns: Array[Vector3] = [Vector3(0.0, 3.0, 0.0)]


func get_player_spawn(index: int = 0) -> Vector3:
      if index >= player_spawns.size():
            push_error("index out of bounds. player_spawns.size() == %d" % player_spawns.size())
            return player_spawns[0]
      return player_spawns[index]
