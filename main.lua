local used_buckets = {}
local instances = {}

function GetFreeBucket()
    local bucket_id = 1
    while used_buckets[bucket_id] do
        bucket_id = bucket_id + 1
    end

    return bucket_id
end

AddEventHandler('playerDropped', function()
	LeaveInstance(source)
end)

RegisterServerEvent('p_instance:s:leave')
AddEventHandler('p_instance:s:leave', function()
    local _src = source
    SetPlayerRoutingBucket(_src, 0)
    LeaveInstance(_src)
end)

function LeaveInstance(_src, dropped)
    for instance_id, this in pairs(instances) do
        local empty_check
        for k, _id in pairs(v.players) do
            if _id == _src then
                empty_check = true
                table.remove(this.players, k)
            end
        end

        if empty_check then
            if #this.players == 0 then
                dispchannel[this.bucket] = true
                instances[instance_id] = nil
            end
        end
    end
end

RegisterServerEvent('p_instance:join')
AddEventHandler('p_instance:join', function(id)
    local _src = source
    if instances[id] == nil then
        instances[id] = { 
            id = id,
            bucket = GetFreeBucket(),
            players = {_src}
        }
    else -- si existe te mete en esa
        table.insert(instances[id].players, _src) 
    end

    SetRoutingBucketPopulationEnabled(instances[id].bucket, false)
    SetPlayerRoutingBucket(_src, instances[id].bucket)
end)

RegisterCommand("instance_debug",function()
    print(json.encode(instances))
end, true)