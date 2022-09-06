extends Node2D


var battery = 0
var mouseSpeed = 0
var stop = true
var goal = 25
var mouseRequiredSpeed = 800
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
		battery -= -1 * delta
		$CanvasLayer/Sprite/TextureProgress.value = battery
	else:
		$background/robot.playing = false
		
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
	stop = true

func _on_restart_pressed():
	var _reload = get_tree().reload_current_scene()
	
func _on_Start_pressed():
	stop = false
	$Timer.start()
	$CanvasLayer/timeleft.visible = true
	$CanvasLayer/welcome.visible = false 


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(body.get_string_from_utf8())
