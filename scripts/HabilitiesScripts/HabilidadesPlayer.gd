extends Node
class_name HabilidadesPlayer

#Preloads
var Cena = preload("res://scenes/EntityScenes/bolinha.tscn")

#Boleanos
var colidiu : bool = false
var energia : bool = false
var iniciado : bool = false


func DASH(Player : EntityPlayer):#HABILIADE TERMINADA E TESTADA
	
	if Input.is_action_pressed("down"):
		
		var tween = Player.create_tween()
		var destino = clamp(Player.position.y + 160, 96, 505)
		tween.tween_property(Player, "position:y", destino, 0.15)
		
		Player.HabilidadeAtiva = false
	
	if Input.is_action_pressed("up"):
		
		var tween = Player.create_tween()
		var destino = clamp(Player.position.y - 160, 96, 505)
		tween.tween_property(Player, "position:y", destino, 0.15)
		
		Player.HabilidadeAtiva = false

func CLARAO(POINTLIGHT : PointLight2D, PLAYER : EntityPlayer) -> void:#Em testes
	var tween = PLAYER.create_tween()
	tween.tween_property(POINTLIGHT, "energy", 30.0, 0.4)
	await PLAYER.get_tree().create_timer(2.5).timeout
	var tween2 = PLAYER.create_tween()
	tween2.tween_property(POINTLIGHT, "energy", 0, 0.3)
	PLAYER.habilidadeAtiva = false
	
func CONGELAR(CPU: EntityCPU, Sound : Sounds) -> void:#Terminado e testado
	Sound.PlayFreezeSound()
	
	var CongeladoTween = CPU.create_tween()
	CongeladoTween.tween_property(CPU.SpriteCongelado, "modulate", Color.WHITE, 0.6)
	
	CPU.congelado = true
	await CPU.get_tree().create_timer(3.0).timeout
	
	var DescongeladoTween = CPU.create_tween()
	DescongeladoTween.tween_property(CPU.SpriteCongelado, "modulate", Color.TRANSPARENT, 0.6)
	CPU.congelado = false

func CLONE(Ball : EntityBall) -> void:#Dificuldades em fazer
	
	Ball.visible = false
	
	var falseBall : EntityBall = Cena.instantiate()
	falseBall.visible = false
	falseBall.global_position = Ball.global_position
	falseBall.ballVelocity = Ball.ballVelocity
	var newDirection := Vector2()
	falseBall.real = false
	newDirection.x = Ball.ballDirection.x
	newDirection.y = Ball.ballDirection.y * -1.0
	falseBall.ballDirection = newDirection.normalized()
	
	falseBall.visible = true
	Ball.visible = true
	Ball.get_parent().add_child(falseBall)

func SALTO(Ball : EntityBall) -> void:#Terminado e testado
	
	var newDirection := Vector2()
	newDirection.x = Ball.ballDirection.x
	
	if Ball.ballDirection.y < 0:
		newDirection.y = randf_range(0.7, 0.6)
	else:
		newDirection.y = randf_range(-0.7, -0.6)
	Ball.ballDirection = newDirection.normalized()

func IMPULSO(Ball : EntityBall, Player : EntityPlayer, CPU : EntityCPU) -> void: #TERMINADO E TESTADO
	
	if Ball.ballCollision:
		var collider = Ball.ballCollision.get_collider()

		if collider == Player and not colidiu:
			colidiu = true
			Ball.ballVelocity += 150
			var newDirection := Vector2()
	
			newDirection.x = Ball.ballDirection.x 
			newDirection.y = [2.0, -2.0].pick_random()
	
			Ball.ballDirection = newDirection.normalized()

		if collider == CPU and colidiu == true:
			Player.habilidadeAtiva = false
			Ball.ballVelocity -= 150
			colidiu = false

func BOLA_ENERGIA(Ball: EntityBall, CPU : EntityCPU, PLAYER : EntityPlayer) -> void:#Precisa de animação e melhoria
	if not energia:
		Ball.ballVelocity += 150
		energia = true
		
	if Ball.ballCollision:
		var collider = Ball.ballCollision.get_collider()
		if collider == CPU:
			
			Ball.ballVelocity -= 150
			CPU.velocidade = 0
			
			await CPU.get_tree().create_timer(0.5).timeout
			CPU.velocidade = 150
			
			await CPU.get_tree().create_timer(2.5).timeout
			CPU.velocidade = 300
			PLAYER.habilidadeAtiva = false

func PATHMAKER(LINE : Line2D, PLAYER : EntityPlayer):
	Engine.time_scale = 0.22
	if Input.is_action_pressed("MOUSEPRESSED"):
		var pos = PLAYER.get_global_mouse_position()
		LINE.add_point(pos)
	
	

func ROTA(Ball : EntityBall, pathFollow : PathFollow2D, delta, PATH : Path2D, PLAYER : EntityPlayer):#TERMINADO E TESTADO
	#Randomiza apenas uma vez, booleano para não executar mais de uma vez
	if not iniciado:
		PATH.RandomPath()
		iniciado = true
	
	
	if pathFollow.progress_ratio < 1.0:
		pathFollow.progress += (Ball.ballVelocity - 200) * delta
		Ball.global_position = pathFollow.global_position#Vai seguir a posição do PathFollow

		#Caso o caminho termine, ele normaliza para que a bola siga a trajetoria do final do PATH
	if pathFollow.progress_ratio == 1.0:
		Ball.ballDirection = pathFollow.position.normalized()
		pathFollow.progress_ratio = 0.0
		iniciado = false
		PLAYER.habilidadeAtiva = false
	
func GRAVIDADE(IMA : Sprite2D, BALL : EntityBall, PLAYER : EntityPlayer):#TERMINADA E TESTADA
	var NewDir : Vector2 
	var direction = BALL.global_position.distance_to(IMA.global_position)
	
	if BALL.global_position.y > 356.0:
		IMA.global_position  = Vector2(1230, 618)
		IMA.rotation = -1.0472
		NewDir = (IMA.global_position - BALL.global_position).normalized()
		IMA.visible = true
		BALL.ballDirection = NewDir
		if direction < 150:
			PLAYER.habilidadeAtiva = false
			
	if BALL.global_position.y < 356.0:
		IMA.global_position = Vector2(1230, 68)
		IMA.rotation = -2.0944
		NewDir = (IMA.global_position - BALL.global_position).normalized()
		IMA.visible = true
		BALL.ballDirection = NewDir
		if direction < 150:
			PLAYER.habilidadeAtiva = false
