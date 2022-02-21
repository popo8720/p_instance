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

function JoinInstance(_src, instance_id)
    if instances[instance_id] == nil then
        local bucket = GetFreeBucket()

        instances[instance_id] = { 
            id = instance_id,
            bucket = bucket,
            players = {[_src] = true}
        }

        SetRoutingBucketPopulationEnabled(bucket, false)
    else
        instances[instance_id].players[_src] = true
    end

    SetPlayerRoutingBucket(_src, instances[instance_id].bucket)
end

AddStateBagChangeHandler("instance", nil, function(bag, _, value)
    local id = bag:gsub("player:","")
    local _src = tonumber(id)
    local player = Player(_src)

    if player.state.instance then
        SetPlayerRoutingBucket(_src, 0)
        LeaveInstance(_src, player.state.instance)
    end

    if value then
        JoinInstance(_src, value)
    end
end)

AddEventHandler('playerDropped', function()
    local player = Player(_src)
    if player.state.instance ~= nil then 
        LeaveInstance(_src, player.state.instance)
    end
end)

RegisterCommand("instance_debug",function(_src)
    print(json.encode(instances))
end, true)