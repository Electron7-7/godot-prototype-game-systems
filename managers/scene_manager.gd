class_name SceneManager
extends IManager

enum MainSceneType {
      NONE,
      TYPE_3D,
      TYPE_2D,
}

var level: Node = null
var main_scene: Node = null
var main_scene_type: MainSceneType = MainSceneType.NONE


func initialize() -> bool:
      print("SceneManager::initialize")
      return true


func shutdown() -> void:
      print("SceneManager::shutdown")


func exit_scene() -> void:
      if main_scene != null:
            main_scene.destroy_player()
            main_scene.queue_free()
            main_scene = null


func start_3d() -> bool:
      match main_scene_type:
            MainSceneType.NONE:
                  main_scene_type = MainSceneType.TYPE_3D
                  main_scene = Main3D.new()
                  add_child(main_scene)
                  return true
            MainSceneType.TYPE_2D:
                  main_scene.destroy()
                  main_scene_type = MainSceneType.NONE
                  return start_3d()
      return false # main_scene_type == MainSceneType.TYPE_3D


# TODO: make this less shit
func load_level_3d(new_level: Level3D) -> bool:
      if (main_scene as Main3D).has_player:
            main_scene.despawn_player()
      main_scene.load_level(new_level)
      main_scene.spawn_player()
      return true
