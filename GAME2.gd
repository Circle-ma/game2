extends Node2D


var battery = 0
var mouseSpeed = 0
var stop = true
var goal = 30000
var mouseRequiredSpeed = 500
var email = ""
var token = ""


func _input(event):
	Input.set_use_accumulated_input(false)
	if event is InputEventMouseMotion:
		mouseSpeed = event.speed.length()

func _process(delta):
	email = JavaScript.eval("new URLSearchParams(window.location.search).get('email')")
	token = JavaScript.eval("new URLSearchParams(window.location.search).get('token')")
	$email.text = str(email)
	$CanvasLayer/Sprite/TextureProgress.max_value=goal
	$CanvasLayer/score.text = "battery: " + str(battery)
	$CanvasLayer/timeleft.text = "剩餘時間: " + str(stepify($Timer.time_left, 0.1))+"秒"
	if mouseSpeed > mouseRequiredSpeed and stop == false:
		$background/robot.playing = true
		battery +=  delta * mouseSpeed
		$CanvasLayer/Sprite/TextureProgress.value = battery
	else:
		$background/robot.playing = false
		
	mouseSpeed = 0
		
	if stop == true:
		$background/kelefei.playing = false
	else:
		$background/kelefei.playing = true

func _on_Timer_timeout():
	if battery < goal:
		$CanvasLayer/Failed.show()
		$background/robot.animation = "lose"
		$background/kelefei.animation = "lose"
	else:
		var data = '[{"email":"%s","token":"%s","apps_id":"app08","score":1}]'%[email,token]
		var url = 'https://cuhk.iontec.com.hk/api.php'
		var wwwdata = "message="+data
		var headers = ["Content-Type: application/x-www-form-urlencoded","Content-Length: "+str(wwwdata.length())]
		$CanvasLayer/HTTPRequest.request(url,headers,true,HTTPClient.METHOD_POST,wwwdata)
		$CanvasLayer/Passed.show()
		$background/robot.animation = "win"
		$background/kelefei.animation = "win"
	$CanvasLayer/timeleft.visible = false
	stop = true

func _on_restart_pressed():
	var _reload = get_tree().reload_current_scene()
	
func _on_Start_pressed():
	stop = false
	$Timer.start()
	$CanvasLayer/timeleft.visible = true
	$CanvasLayer/welcome.visible = false 


func _on_HTTPRequest_request_completed(_result, _response_code, _headers,body):
	print(body.get_string_from_utf8())
