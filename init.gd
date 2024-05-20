extends Control
class_name Init

## Initialises Adastral, plays a loading animation

# Animation Variables

var spin_tween: Tween ## The tween used for spinning in the boot animation
var s: binding

# Nodes

@onready var white_logo: TextureRect = $WhiteLogo ## White logo, used for the animation
@onready var orange_logo: TextureRect = $OrangeLogo ## Orange logo for the animation
@onready var red_logo: TextureRect = $RedLogo ## Red logo for the animation
@onready var yellow_logo: TextureRect = $YellowLogo ## Yellow logo for the animation
@onready var green_logo: TextureRect = $GreenLogo ## Green logo for the animation
@onready var blue_logo: TextureRect = $BlueLogo ## Blue logo for the animation
@onready var main_logo_parent: Node2D = $MainLogoParent ## The parent of the main logo. Used as the target to tween to in the boot animation
@onready var main_logo: TextureRect = $MainLogoParent/MainLogo ## The main logo
@onready var title_text: Label = $TitleText ## The text that reads 'Adastral' for when the boot animation completes
@onready var initialising: Label = $Initialising ## Initisalisation text that is displayed before the full boot animation


# Functions

## Called when the node enters the scene tree for the first time.
func _ready():
	s = binding.new()
	s.connect("palace_started",launch)
	s.init_palace()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Initialise the script, checking that Sutton has launched.
func initialise():
	var main = load("res://main.tscn").instantiate()
	add_child(main)
	move_child($Control,0)
	$Control/Main.s = s
	$Control/Main.ready_after_sutton()
	$Control.position = Vector2(0,349)
	boot_animation()

## Launch Adastral, checking the sourcemod path 
func launch():
	if(s.find_sourcemod_path() == ""):
		get_tree().change_scene_to_file("res://oops.tscn")
	s.init_games()
	call_deferred("initialise")

## Play the bootup animation
func boot_animation():
	# Hide initialisation text
	initialising.hide()
	# Set up initial tween conditions
	spin_tween = create_tween().set_loops().set_parallel()
	var tween = create_tween().set_parallel()
	var t = 1.5
	var trans = Tween.TRANS_EXPO
	var ease = Tween.EASE_OUT
	spin_tween.tween_property(title_text,"rotation_degrees",360,t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_text,"visible_characters",8,t).set_trans(Tween.TRANS_SINE).set_ease(ease)
	# Iterate through all texture rects in order 
	for x in [white_logo,orange_logo,red_logo,yellow_logo,green_logo,blue_logo]:
		tween.tween_property(x,"position",main_logo_parent.position,t).set_trans(trans).set_ease(ease)
		tween.tween_property(x,"size",Vector2(200,200),t).set_trans(trans).set_ease(ease)
		tween.tween_property(x,"pivot_offset",Vector2(100,100),t).set_trans(trans).set_ease(ease)
		spin_tween.tween_property(x,"rotation_degrees",360.0+180,t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(x,"modulate",Color.WHITE,t).set_trans(trans).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(t+0.2).timeout
	# Hide the texture rects, except for the white logo
	for y in [orange_logo,red_logo,yellow_logo,green_logo,blue_logo,main_logo]:
		y.hide()
	# Reparent label and finish animation
	title_text.reparent($Control/Main)
	tween = create_tween().set_parallel()
	tween.tween_property($Control,"position",Vector2(0,0),0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.5).timeout
	white_logo.reparent($Control/Main,false) # Reparent the white instance of the logo so that main.gd can manage it.
