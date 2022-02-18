local used_buckets = {}
local instances = {}

function GetFreeBucket()
    local bucket_id = 1
    while used_buckets[bucket_id] do
        bucket_id = bucket_id + 1
    end

    used_buckets[bucket_id] = true

    return bucket_id
end

function LeaveInstance(_src, instance_id)
    local instance = instances[instance_id]

    instance.players[_src] = nil

    if not next(instance.players) then
        used_buckets[instance.bucket] = nil
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

RegisterNetEvent('p_instance:leave', function()
    local _src = source
    local player = Player(_src)

    if player.state.instance ~= nil then 
        SetPlayerRoutingBucket(_src, 0)
        
        player.state.instance = nil
    end
end)

AddEventHandler('playerDropped', function()
    local player = Player(_src)
    if player.state.instance ~= nil then 
        LeaveInstance(_src, player.state.instance)
    end
end)

RegisterCommand("instance_debug",function()
    print(json.encode(instances))
end, true)