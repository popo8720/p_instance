##  p_instance
Standalone instance system for FiveM.
### Usage
The player's instance is set using the statebag instance. when setting the instance to a player it is created, a routing bucket is assigned and the player is put in it. if you want to leave the current instance the statebag must be setear to nil
### Examples
##### server-side
```lua
RegisterCommand("join_instance", function(source, args)
	local instance_name = args[1]

	Player(source).state.instance = instance_name
end)

RegisterCommand("leave_instance", function(source, args)
	Player(source).state.instance = nil
end)
```
##### client-side
```lua
RegisterCommand("join_instance", function(source, args)
	local instance_name = args[1]

	LocalPlayer.state:set("instance", instance_name, true) 
end)

RegisterCommand("leave_instance", function(source, args)
	LocalPlayer.state:set("instance", nil, true) 
end)
```