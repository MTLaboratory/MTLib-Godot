extends Node
## Modern Tool Library for Godot 4.3.x

const VERSION: StringName = &"0.4.5"; # MAJ.MIN.REV

func _ready() -> void:
	print("MTLib v%s" % VERSION)

## Loops through and array of Nodes, and calls [code]free[/code] on them.
func nodes_free(
	array: Array[Node]
) -> void:
	if array.is_empty(): return ;
	for node: Node in array:
		if not is_instance_valid(node): continue ;
		node.free();
	return ;

## Calls [code]queue_free[/code] on each of the [Node]'s children.
## @deprecated
func node_free_children(
	node: Node
) -> void:
	if var_null_or_invalid(node): return ;
	for child: Node in node.get_children():
		if var_null_or_invalid(child): continue ;
		child.queue_free();
	return ;

## Calls [code]queue_free[/code] on each of the [Node]'s children.
func node_queue_free_children(
	node: Node
) -> void:
	if is_null_or_invalid(node): return ;
	for child: Node in node.get_children():
		if is_null_or_invalid(child): continue ;
		child.queue_free();
	return ;

## Loops through and array of Nodes, and calls [code]queue_free[/code] on them.
func nodes_queue_free(
	array: Array[Node],
) -> void:
	if array.is_empty():
		return ;
	for node: Node in array:
		if is_null_or_invalid(node):
			continue ;
		node.queue_free();
	return ;

## Determines if the provided [InputEventKey] was an actual Keypress,
## and not an echo, and that it matches the expected key code.
func is_key_event_valid(
	kEvent: InputEventKey,
	expectingKey: int = -1,
) -> bool:
	if is_null_or_invalid(kEvent):
		return false;
	if (kEvent.echo or not (kEvent.pressed)):
		return false;
	if not (expectingKey == -1):
		if (kEvent.keycode != expectingKey):
			return false;
	return true;

## Encodes and returns the provided [Object] as an [EncodedObjectAsID].
## @experimental
func obj_encode(
	obj: Object
) -> EncodedObjectAsID:
	var encoding: EncodedObjectAsID = EncodedObjectAsID.new();
	encoding.object_id = obj.get_instance_id();
	return encoding;

## Returns an [Object] instance from an [EncodedObjectAsID].
## @experimental
func obj_decode(
	id: EncodedObjectAsID
) -> Object:
	return instance_from_id(id.object_id);

## Prints the provided [Error]s to the console (if any).
func log_errors(
	connections: Array[int]
) -> void:
	var err_indices: Array[int] = [];
	var err_strings: Array[String] = [];
	var err_index: int = 0;
	for connection_err: int in connections:
		if connection_err:
			err_indices.append(err_index);
			var err_idx: String = ("\t[error %s]:\t" % err_index);
			err_strings.append(
				err_idx + error_string(connection_err) + "\n"
			);
		err_index += 1;
	var err_count: int = err_indices.size();
	var caller_inf: Dictionary = (get_stack()[1]); # unsafe
	if not (caller_inf):
		return ;
	var caller_func: String = str(caller_inf.get("function", "?"));
	var caller_line: int = int(str(caller_inf.get("line", -1)));
	var caller_file: String = str(caller_inf.get("source", "?"));
	var plural: String = ("s" if (err_count != 1) else "");
	if err_indices.is_empty():
		printraw("%s condition%s passed at: %s:%s:%s()\n" % [
			connections.size(), plural, caller_file, caller_line, caller_func,
		]);
		return ;
	printraw("\n%s condition%s FAILED at: %s:%s:%s\n" % [
		err_count, plural, caller_file, caller_line, caller_func,
	]);
	for msg: String in err_strings:
		printraw(msg);
	printraw("\n");
	return ;

## Returns false, if there has been an Error in a connection.
## otherwise, returns true if there is no Error.
## @deprecated
func log_connections(
	connections: Array[int]
) -> bool:
	var error_indices: Array[int] = [];
	var error_index: int = 0;
	for connection_err: int in connections:
		if connection_err:
			error_indices.append(error_index);
		error_index += 1;
	var caller_inf: Dictionary = (get_stack()[1] as Dictionary);
	var caller_file: String = str(caller_inf.get('source', '?'));
	var caller_func: String = str(caller_inf.get('function', '?'));
	var caller_line: int = int(str(caller_inf.get('line', -1)));
	if error_indices.is_empty():
		printraw("%s connection(s) connected at: %s:%s:%s()\n" % \
			[connections.size(), caller_file, caller_line, caller_func])
		return true;
	printraw("connections (#%s) failed at: %s:%s:%s\n" % \
		[str(error_indices), caller_file, caller_line, caller_func])
	return false;

## Returns [param true], if the provided value is [null] or [invalid].
func is_null_or_invalid(
	value: Variant
) -> bool:
	return ((value == null) or (is_instance_valid(value) == false));

## Returns [param true], if the provided [param value]
## is not null, and is a [valid] instance.
func is_valid(
	value: Variant
) -> bool:
	return not (is_null_or_invalid(value));

## Returns [param true], if the provided
## [Node] is ready, and is valid.
func is_node_valid_and_ready(
	node: Node
) -> bool:
	return (is_valid(node) and node.is_node_ready());

## @deprecated
func var_null_or_invalid(
	val: Variant
) -> bool:
	if (val == null): return true;
	if not is_instance_valid(val): return true;
	return false;

## @deprecated
func var_valid(
	val: Variant
) -> bool:
	return not var_null_or_invalid(val);

## @deprecated
func node_valid_and_ready(
	node: Node
) -> bool:
	return var_valid(node) and node.is_node_ready();

## Returns a [PackedVector2Array] of coordinates built from the provided size.
func outline_get_from_size(
	size: Vector2,
	centered: bool = false,
) -> PackedVector2Array:
	if centered:
		var h_x: float = (size.x * .5); # (/2) is *usually* slower.
		var h_y: float = (size.y * .5);
		return ([Vector2(-h_x, -h_y), Vector2(h_x, -h_y), \
			Vector2(h_x, h_y), Vector2(-h_x, h_y)]);
	return ([Vector2.ZERO, Vector2(size.x, 0), \
		Vector2(size.x, size.y), Vector2(0, size.y)]);

## Returns a [SHA256] representation of the stringified version of the provided value.
## @experimental
func var_get_sha256(
	value: Variant
) -> String:
	return str(value).sha256_text();

## Returns a constant identifier for a given Node,
## based upon the Node's path in the SceneTree.
## @experimental
func node_get_id(
	node: Node
) -> StringName:
	#return StringName(str(obj_encode(node).object_id));
	if is_null_or_invalid(node):
		return &"";
	return StringName(str(node.get_path()).sha256_text());

## Instantiates and adds a new [Timer] to the provided [Node].
func node_attach_timer(
	node: Node,
	funct: Callable,
	one_shot: bool,
	wait_time: float,
	auto_start: bool = true,
) -> Timer:
	if MTLib.var_null_or_invalid(node): return null;
	var timer_obj: Timer = Timer.new();
	var _connected: bool = MTLib.log_connections([
		timer_obj.timeout.connect(funct),
	])
	timer_obj.autostart = auto_start;
	timer_obj.wait_time = wait_time;
	timer_obj.one_shot = one_shot;
	node.add_child(timer_obj);
	return timer_obj;

## Conditionally builds a string based upon the arguments which
## are possibly already contained within one another.
## Example: cond_string_build(["Hello", "World", "HelloWorld"])
## 	Would return "HelloWorld".
## @experimental
func cond_string_build(
	strings: Array[String]
) -> String:
	var final_str: String = "";
	for string: String in strings:
		if (
			not (final_str.contains(string))
			and not (string.contains(final_str))
		):
			final_str += string;
	return final_str;

## Returns the nearest element to 'key', within the provided [Array].
## Beware, this does not work with dictionaries where the keys are not [int]s.
## @deprecated
## @experimental
func dict_get_nearest_to_key(
	dict: Dictionary,
	key: int
) -> Variant:
	if dict.is_empty():
		return null;
	var last_key: int = -1;
	var nearest_key: int = -1;
	for dict_key: Variant in dict.keys():
		var dict_key_int: int = int(str(dict_key));
		if (last_key >= dict_key_int):
			continue ;
		if (
			(nearest_key == -1)
			or (absi(key - dict_key_int) < absi(key - nearest_key))
		):
			nearest_key = dict_key_int;
		last_key = dict_key_int;
	return dict.get(nearest_key);

## Makes a [Color] fully opaque. (Alpha 1)
func color_make_opaque(
	color: Color
) -> Color:
	return Color(color.r, color.g, color.b, 1.0);

## Returns a [Vector2] that is useful for aiming from one moving
## [RigidBody2D], at another.
## *NOT TESTED*
## @deprecated
## @experimental
func vec2_foretell(
	from: RigidBody2D,
	to: RigidBody2D,
) -> Vector2:
	var target_pos: Vector2 = to.global_position;
	var origin_pos: Vector2 = from.global_position;
	var dist: float = origin_pos.distance_to(target_pos);
	var sB: float = from.linear_velocity.length();
	var target_vel: Vector2 = to.linear_velocity;
	var sT: float = target_vel.length();
	var cos_theta: float = (
		target_pos.direction_to(origin_pos).dot(target_vel.normalized())
	);
	var q_root: float = sqrt(
		(2 * dist * sT * cos_theta + 4 * (sB * sB - sT * sT) * dist * dist)
	);
	var q_sub: float = (2 * (sB * sB - sT * sT));
	var q_left: float = (-2 * dist * sT * cos_theta);
	var t1: float = ((q_left + q_root) / q_sub);
	var t2: float = ((q_left - q_root) / q_sub);
	var t: float = minf(t1, t2);
	if (t < 0):
		t = maxf(t1, t2);
	if (t < 0):
		return Vector2.INF;
	return (target_vel * t * target_pos);

## Determines if a body is moving towards another, given a tolerance.
## *NOT TESTED*
## @deprecated
## @experimental
func moving_towards(
	source_body: RigidBody2D,
	target_body: RigidBody2D,
	angle_tolerance_degrees: float = 1.0,
) -> bool:
	var direction_to_target: Vector2 = (
		(target_body.global_position - source_body.global_position)
	).normalized();
	var relative_velocity: Vector2 = source_body.linear_velocity;
	var dot_product: float = relative_velocity.dot(direction_to_target);
	var tolerance: float = cos(deg_to_rad(angle_tolerance_degrees));
	return (dot_product > tolerance);

## Ensures a given directory exists, creating it if needed. Returns any Error.
func dir_assert(
	dir_path: StringName
) -> void:
	var exists: bool = DirAccess.dir_exists_absolute(dir_path);
	if exists: return ;
	var make_err: Error = DirAccess.make_dir_recursive_absolute(dir_path);
	if not make_err: return ;
	print_debug("Failed to assert directory '%s'! (Error #%s)" % [dir_path, make_err])
	return ;

## Returns an Array of Resources from the specified path.
## @experimental
func dir_get_resources(dir_path: StringName) -> Array[Resource]:
	var dirResources: Array[Resource] = [];
	if not (dir_path.ends_with("/")):
		dir_path += "/";
	for file: String in DirAccess.get_files_at(dir_path):
		if not (file.ends_with(".tres") or file.ends_with(".remap")):
			continue ;
		var f_path: String = ("" + dir_path + file);
		## (godot/issues/76823 & (issues/66014 initial)) SRSLY?!
		if f_path.ends_with(".remap"):
			f_path = f_path.trim_suffix(".remap");
		var res: Resource = load(f_path);
		if MTLib.is_valid(res):
			dirResources.append(res);
		else:
			print_debug("Failed to load Resource `%s`!" % f_path)
	if dirResources.is_empty():
		print_debug("Folder `%s` (apparently) has no Resources" % dir_path)
	else:
		print_debug("Got (%s) Resources in `%s`." % [dirResources.size(), dir_path])
	return dirResources;

## @deprecated
class Random:
	static func _static_init() -> void:
		NG = RandomNumberGenerator.new();
		NG.randomize();
		return ;
	static var NG: RandomNumberGenerator;
	static func rand_bool() -> bool:
		return (NG.randf_range(0., 1.) > .5);
	static func rand_int(minimum: int = 0, maximum: int = 1) -> int:
		return NG.randi_range(minimum, maximum);
	static func rand_float(minimum: float = 0., maximum: float = 1.) -> float:
		return NG.randf_range(minimum, maximum);
	static func rand_probability(probability: float = 50.) -> float:
		return (rand_float(0., 100.) <= probability);
	static func rand_color(
		minimum: Color = Color.BLACK,
		maximum: Color = Color.WHITE,
	) -> Color:
		var r: float = rand_float(minimum.r, maximum.r);
		var g: float = rand_float(minimum.g, maximum.g);
		var b: float = rand_float(minimum.b, maximum.b);
		var a: float = rand_float(minimum.a, maximum.a);
		return Color(r, g, b, a);
	static func rand_vector2(
		minimum: Vector2 = Vector2.ZERO,
		maximum: Vector2 = Vector2.ONE,
	) -> Vector2:
		return Vector2(rand_float(minimum.x, maximum.x),
			rand_float(minimum.y, maximum.y));
	static func rand_dict_key(dict: Dictionary) -> Variant:
		if dict.is_empty(): return null;
		return (dict.keys()[rand_int(0, dict.size())]);
	static func rand_dict_value(dict: Dictionary) -> Variant:
		if dict.is_empty(): return null;
		return (dict.values()[rand_int(0, dict.size())]);
