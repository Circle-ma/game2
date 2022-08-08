extends Node2D


var battery = 0
var mouseSpeed
var stop = false


func _input(event):
	Input.set_use_accumulated_input(false)
	if event is InputEventMouseMotion:
		mouseSpeed = event.speed.length()
		
	if mouseSpeed > 1000 and stop == false:
		battery -= -1

# warning-ignore:unused_argument
func _process(delta):
	$score.text = "battery: " + str(battery)
	$timeleft.text = "Time left: " + str(stepify($Timer.time_left, 0.1))


func _on_Timer_timeout():
	if battery < 700:
		$Failed.show()
	else:
		$Passed.show()
	stop = true
	$restart.visible = true


func _on_restart_pressed():
	get_tree().reload_current_scene()
	
