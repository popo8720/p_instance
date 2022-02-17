local used_buckets = {}
local instances = {}

function GetFreeBucket()
    local bucket_id = 1
    while used_buckets[bucket_id] do
        bucket_id = bucket_id + 1
    end

    return bucket_id
end

function LeaveInstance(_src, instance_id)
    local instance = instances[instance_id]

    instance.players[_src] = nil

    if not next(instance.players) then
        dispchannel[instance.bucket] = true
        instances[instance_id] = nil        
    end
end

RegisterNetEvent('p_instance:join', function(id)
    local _src = source
    local player = Player(_src)

    if player.state.instance ~= nil then
        LeaveInstance(_src, player.state.instance)
    end

    if instances[id] == nil then
        instances[id] = { 
            id = id,
            bucket = GetFreeBucket(),
            players = {[_src] = true}
        }
    else
        instances[id].players[_src] = true
    end

    player.state.instance = id

    SetRoutingBucketPopulationEnabled(instances[id].bucket, false)
    SetPlayerRoutingBucket(_src, instances[id].bucket)
end)

RegisterNetEvent('p_instance:s:leave', function()
    local _src = source
    local player = Player(_src)

    if player.state.instance ~= nil then 
        player.state.instance = nil
        SetPlayerRoutingBucket(_src, 0)
        LeaveInstance(_src)
    end
end)

AddEventHandler('playerDropped', function()
	LeaveInstance(source)
end)

RegisterCommand("instance_debug",function()
    print(json.encode(instances))
end, true)