-- 0.1
-- Created with the help of the Figura Discord community (FiguraMC)!
-- Brought to life by @chmonyasik (ElenaNya in Minecraft) and slunce.slantse

--!!!THIS SCRIPT IS NOT SIMPLY PLUG-AND-PLAY, YOU WILL NEED TO PERFORM SOME STEPS YOURSELF! INSTRUCTIONS BELOW!!!---

--[[

To set up this armor fix, you need the main folders in your Blockbench model - specifically Head, Body, LeftArm, RightArm, LeftLeg, and RightLeg - to not use the default names anymore. !!!(mode 3 - EXCEPTION, at least for now, while 3.1 is currently assigned to mode 3)!!!
In other words, you need to detach them from the parent type system
(https://figura-wiki.pages.dev/enums/ModelPartParentTypes).

You should rename them to something marked with a cross on the wiki.
For example, instead of Head, use something like 67Head.

If you have armor pivots (https://figura-wiki.pages.dev/enums/ModelPartParentTypes#armor-pivot-types) - you will also need to remove them.
(NO EXCEPTIONS)

!Under "local mode" (just scroll down) you will find locals for parts, where you must specify the paths to your model parts yourself!
So instead of something like "Torso.FA_Head", you would use "Torso.67Head", depending on the name you chose in Blockbench.

To add parents, you need to define them manually. In this example you can see:

"
local root = models.model.root
local Torso = root.Torso
"

Next you will need to add them to the "parents" columns in the table
You can observe how to do this by scrolling down to "local parts" and checking how parents are assigned.
For example, for the head part, the parents are:

"{ root, Torso }"

because in my example - Head (Torso.FA_Head (models.model.root.Torso.Head)) is inside Torso, and Torso is inside root.

>
 
Below you will find "local mode". You need to manually set what you want to use there.

1 mode:
For those who use modifications to model, like Gaze / SquAPI / animations, and they are applied to a parent folder.  
For example if your Head and Body are inside a Torso folder, and you apply SmoothHead (from SquAPI) or animation keyframes to Torso (parent folder) - then this mode is for you.

    This mode is also used when both parent and child are affected at the same time.  
    For example if both Torso and Head receive transformations - this mode is also for you.

2 mode:
Exactly the same as the first one, but choose this one only if you are not using vanilla animations at all.

3 mode:
For cases where something is applied directly to your model parts, for example Gaze (? questionable) or custom animations, BUT! not to a parent folder.
Usually can be slightly modified and still used, for example by taking the position not from the Head, but from the root, if you are only moving the root position and that works for you.

]]--The end of the wrapped text

local mode = 3 --As mentioned before in discord, there is only one mode here. If all modes are ever completed, everything will be merged into a single file. The other modes that may exist here could be outdated or not match the description.

local root = models.model.root
local Torso = root.Torso

local Head = Torso.Head
local Body = Torso.Body
local LeftArm = Torso.LeftArm
local RightArm = Torso.RightArm
local LeftLeg = root.LeftLeg
local RightLeg = root.RightLeg

---

local V_HAT = vanilla_model.HAT
local V_HEAD = vanilla_model.HEAD
local V_BODY = vanilla_model.BODY
local V_L_ARM = vanilla_model.LEFT_ARM
local V_R_ARM = vanilla_model.RIGHT_ARM
local V_L_LEG = vanilla_model.LEFT_LEG
local V_R_LEG = vanilla_model.RIGHT_LEG

--[[if mode == 1 or mode == 2 then

    local parts = {
        {
            vanilla = { V_HAT, V_HEAD },
            vanillaPivot = vec(0, 24, 0),
            parents = { },
            custom = Head
        },
        {
            vanilla = { V_BODY },
            vanillaPivot = vec(0, 24, 0),
            parents = { },
            custom = Body
        },
        {
            vanilla = { V_L_ARM },
            vanillaPivot = vec(-5, 22, 0),
            parents = { },
            custom = LeftArm
        },
        {
            vanilla = { V_R_ARM },
            vanillaPivot = vec(5, 22, 0),
            parents = { },
            custom = RightArm
        },
        {
            vanilla = { V_L_LEG },
            vanillaPivot = vec(-2, 12, 0),
            parents = { },
            custom = LeftLeg
        },
        {
            vanilla = { V_R_LEG },
            vanillaPivot = vec(2, 12, 0),
            parents = { },
            custom = RightLeg
        },
    }
    
    for _, part in pairs(parts) do
        local pivots = {}
    
        for i, parent in pairs(part.parents) do
            pivots[i] = part.vanillaPivot - parent:getTruePivot()
        end
    
        part.pivotsDelta = pivots
    end
    
    local atan2, asin = math.atan2, math.asin
    local function matrixToRotZYX(m)
        return vec(
            atan2(m.v32, m.v33),
            asin(-m.v31),
            atan2(m.v21, m.v11)
        ):toDeg()
    end
    
    if mode == 1 then
    
        function events.render()
        
            local tempMatLocal = matrices.mat4()
            local rotMatLocal = matrices.mat4()
            local partMatLocal = matrices.mat4()
            
            -- HEAD + HAT
            do
                local part = parts[1]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                local rot = matrixToRotZYX(rotMatLocal)
                
                V_HAT
                    :pos(point + V_HEAD:getOriginPos())
                    :offsetRot(rot - V_HEAD:getOriginRot())
                V_HEAD
                    :pos(point + V_HEAD:getOriginPos())
                    :offsetRot(rot - V_HEAD:getOriginRot())
                    
                Head
                    :pos(-V_HEAD:getOriginPos())
                    :offsetRot(V_HEAD:getOriginRot())
            end
        
            -- BODY
            do
                local part = parts[2]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
                
                V_BODY:pos(point + V_BODY:getOriginPos()):offsetRot(matrixToRotZYX(rotMatLocal) - V_BODY:getOriginRot())
    
                Body:pos(-V_BODY:getOriginPos()):offsetRot(V_BODY:getOriginRot())
            end
        
            -- LEFT ARM
            do
                local part = parts[3]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
                
                V_L_ARM:pos(point + V_L_ARM:getOriginPos()):offsetRot(matrixToRotZYX(rotMatLocal) - V_L_ARM:getOriginRot())
                
                LeftArm:pos(-V_L_ARM:getOriginPos()):offsetRot(V_L_ARM:getOriginRot())
            end
        
            -- RIGHT ARM
            do
                local part = parts[4]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
                
                V_R_ARM:pos(point + V_R_ARM:getOriginPos()):offsetRot(matrixToRotZYX(rotMatLocal) - V_R_ARM:getOriginRot())
                
                RightArm:pos(-V_R_ARM:getOriginPos()):offsetRot(V_R_ARM:getOriginRot())
            end
        
            -- LEFT LEG
            do
                local part = parts[5]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
                
                V_L_LEG:pos(point - V_L_LEG:getOriginPos()):offsetRot(matrixToRotZYX(rotMatLocal) - V_L_LEG:getOriginRot())
                
                LeftLeg:pos(V_L_LEG:getOriginPos()):offsetRot(V_L_LEG:getOriginRot())
            end
        
            -- RIGHT LEG
            do
                local part = parts[6]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
                
                V_R_LEG:pos(point - V_R_LEG:getOriginPos()):offsetRot(matrixToRotZYX(rotMatLocal) - V_R_LEG:getOriginRot())
                
                RightLeg:pos(V_R_LEG:getOriginPos()):offsetRot(V_R_LEG:getOriginRot())
            end
            
        end
        
    elseif mode == 2 then
    
        function events.render()
    
            local tempMatLocal = matrices.mat4()
            local rotMatLocal = matrices.mat4()
            local partMatLocal = matrices.mat4()
        
            -- HEAD + HAT
            do
                local part = parts[1]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                local rot = matrixToRotZYX(rotMatLocal)
        
                V_HAT:pos(point):rot(rot)
                V_HEAD:pos(point):rot(rot)
            end
        
            -- BODY
            do
                local part = parts[2]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                V_BODY:pos(point):rot(matrixToRotZYX(rotMatLocal))
            end
        
            -- LEFT ARM
            do
                local part = parts[3]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                V_L_ARM:pos(point):rot(matrixToRotZYX(rotMatLocal))
            end
        
            -- RIGHT ARM
            do
                local part = parts[4]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                V_R_ARM:pos(point):rot(matrixToRotZYX(rotMatLocal))
            end
        
            -- LEFT LEG
            do
                local part = parts[5]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                V_L_LEG:pos(point):rot(matrixToRotZYX(rotMatLocal))
            end
        
            -- RIGHT LEG
            do
                local part = parts[6]
                local custom = part.custom
                local parents = part.parents
                local deltas = part.pivotsDelta
        
                local point = custom:getTruePos()
        
                for i = #parents, 1, -1 do
                    local parent = parents[i]
                    local delta = deltas[i]
        
                    tempMatLocal:reset():rotate(parent:getTrueRot())
                    point = tempMatLocal:applyDir(delta + point) + parent:getTruePos() - delta
                end
        
                rotMatLocal:reset()
        
                for _, parent in pairs(parents) do
                    partMatLocal:reset():rotate(parent:getTrueRot())
                    rotMatLocal:rightMultiply(partMatLocal)
                end
        
                partMatLocal:reset():rotate(custom:getTrueRot())
                rotMatLocal:rightMultiply(partMatLocal)
        
                V_R_LEG:pos(point):rot(matrixToRotZYX(rotMatLocal))
            end
            
        end
    end
end]]

if mode == 3 then

    function events.render()
    
        do
            local vRot = V_HEAD:getOriginRot()
            local vPos = V_HEAD:getOriginPos()
        
            Head:offsetRot(0)
            V_HEAD
                :offsetRot(Head:getAnimRot() + Head:getOffsetRot())
                :pos(Head:getAnimPos())
        
            Head
                :offsetRot(-Head:getAnimRot())
                :pos(-Head:getAnimPos())
        
            V_HAT
                :offsetRot(Head:getAnimRot() + Head:getOffsetRot())
                :pos(Head:getAnimPos())
        end
        
        do
            local vRot = V_BODY:getOriginRot()
            local vPos = V_BODY:getOriginPos()
        
            Body:offsetRot(0)
            V_BODY
                :offsetRot(Body:getAnimRot() + Body:getOffsetRot())
                :pos(Body:getAnimPos())
        
            Body
                :offsetRot(-Body:getAnimRot())
                :pos(-Body:getAnimPos())
        end
        
        do
            local vRot = V_L_ARM:getOriginRot()
            local vPos = V_L_ARM:getOriginPos()
        
            LeftArm:offsetRot(0)
            V_L_ARM
                :offsetRot(LeftArm:getAnimRot() + LeftArm:getOffsetRot())
                :pos(LeftArm:getAnimPos())
        
            LeftArm
                :offsetRot(-LeftArm:getAnimRot())
                :pos(-LeftArm:getAnimPos())
        end
        
        do
            local vRot = V_R_ARM:getOriginRot()
            local vPos = V_R_ARM:getOriginPos()
        
            RightArm:offsetRot(0)
            V_R_ARM
                :offsetRot(RightArm:getAnimRot() + RightArm:getOffsetRot())
                :pos(RightArm:getAnimPos())
        
            RightArm
                :offsetRot(-RightArm:getAnimRot())
                :pos(-RightArm:getAnimPos())
        end
        
        do
            local vRot = V_L_LEG:getOriginRot()
            local vPos = V_L_LEG:getOriginPos()
        
            LeftLeg:offsetRot(0)
            V_L_LEG
                :offsetRot(LeftLeg:getAnimRot() + LeftLeg:getOffsetRot())
                :pos(LeftLeg:getAnimPos())
        
            LeftLeg
                :offsetRot(-LeftLeg:getAnimRot())
                :pos(-LeftLeg:getAnimPos())
        end
        
        do
            local vRot = V_R_LEG:getOriginRot()
            local vPos = V_R_LEG:getOriginPos()
        
            RightLeg:offsetRot(0)
            V_R_LEG
                :offsetRot(RightLeg:getAnimRot() + RightLeg:getOffsetRot())
                :pos(RightLeg:getAnimPos())
        
            RightLeg
                :offsetRot(-RightLeg:getAnimRot())
                :pos(-RightLeg:getAnimPos())
        end
        
    end
end
