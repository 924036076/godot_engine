extends "res://StateMachine.gd"

enum {IDLE,JUMP,FALL,RUN,DOWN,ATTACK}
var m_ant
var old = null

func _move():
	if Input.is_action_pressed("move_right"):
		parent.dir = "right"
		return true
	if Input.is_action_pressed("move_left"):
		parent.dir = "left"
		return true
	return false

func _ready():
	call_deferred("set_state", IDLE)

func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		IDLE:
			m_ant = parent.dir
			var m = _move()
			if Input.is_action_pressed("jump"):
				return JUMP
			elif m:
				if m_ant != parent.dir:
					parent.vira()
				return RUN
			elif Input.is_action_pressed("down"):
				return DOWN
			elif Input.is_action_pressed("attack"):
				return ATTACK
		RUN:
			m_ant = parent.dir
			var m = _move()
			if parent.velocity.y > 0 :
				return FALL
			elif Input.is_action_pressed("jump"):
				return JUMP
			elif Input.is_action_pressed("down"):
				return DOWN
			elif Input.is_action_pressed("attack"):
				return ATTACK
			elif !m:
				return IDLE
			elif m_ant != parent.dir:
				parent.vira()
				return RUN
		JUMP:
			m_ant = parent.dir
			var m = _move()
			if parent.velocity.y >= 0:
				return FALL
			elif Input.is_action_pressed("attack"):
				return ATTACK
			elif m:
				if m_ant != parent.dir:
					parent.vira()
				return RUN
		FALL:
			m_ant = parent.dir
			var m = _move()
			if parent.is_on_floor():
				return IDLE
			elif Input.is_action_pressed("attack"):
				return ATTACK
			elif m:
				if m_ant != parent.dir:
					parent.vira()
				return RUN
		DOWN:
			m_ant = parent.dir
			_move()
			if !Input.is_action_pressed("down"):
				return IDLE
			elif Input.is_action_pressed("attack"):
				return ATTACK
			elif m_ant != parent.dir:
				parent.vira()
				return DOWN
	return null

func _enter_state(new_state, old_state):
	match new_state:
		IDLE:
			print("idl")
			parent._idle()
			parent._assign_animation("idle")
		RUN:
			parent._run()
			if old_state == JUMP || old_state == FALL:
				call_deferred("st",old_state)
			else:
				parent._assign_animation("run")
		JUMP:
			parent._jump()
			parent._assign_animation("jump")
		FALL:
			parent._assign_animation("fall")
		DOWN:
			if parent.dir == "right":
				parent.lado(false)
			else:
				parent.lado(true)
			parent._idle()
			parent._assign_animation("duck")
		ATTACK:
			print(old_state)
			match old_state:
				IDLE:
					old = old_state
					parent._anim("ata_idle")
				RUN:
					parent._idle()
					old = IDLE
					parent._anim("ata_idle")
				DOWN:
					old = old_state
					parent._anim("ata_duck")
				JUMP:
					call_deferred("st",old_state)
				FALL:
					call_deferred("st",old_state)

func _exit_state(old_state,new_state):
	pass

func _on_anim_animation_finished(anim_name):
	parent.dis_ata()
	if anim_name == "ata_duck":
		print("n",old)
		if old !=null:
			call_deferred("st",old)
	else:
		print("m",old)
		if old !=null:
			call_deferred("set_state",old)
