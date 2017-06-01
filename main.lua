local MoreItems = RegisterMod("MoreItems", 1)
local game = Game()
local MIN_FIRE_DELAY = 5

local MoreItemsId = {
	GREEN_CANDLE = Isaac.GetItemIdByName("Green Candle"),
	FRESH_WATER = Isaac.GetItemIdByName("Fresh Water"),
	MOMS_APPLE_JUICE = Isaac.GetItemIdByName("Mom's \"Apple\" Juice"),
	GLUCOSE = Isaac.GetItemIdByName("Glucose"),
	LIQUID_CLOVER = Isaac.GetItemIdByName("Liquid Clover"),
	FIZZY_BUBBLY = Isaac.GetItemIdByName("Fizzy Bubbly"),
	ITS_MOVING = Isaac.GetItemIdByName("It's Moving?")
}

local MoreBloodBagsId = {
	Isaac.GetItemIdByName("IV Bag"),
	Isaac.GetItemIdByName("Blood Bag"),
	Isaac.GetItemIdByName("Fresh Water"),
	Isaac.GetItemIdByName("Mom's \"Apple\" Juice"),
	Isaac.GetItemIdByName("Glucose"),
	Isaac.GetItemIdByName("Liquid Clover"),
	Isaac.GetItemIdByName("Fizzy Bubbly"),
	Isaac.GetItemIdByName("It's Moving?")
}

local HasMoreItem = {
	greenCandle = false,
	freshWater = false,
	momsAppleJuice = false,
	glucose = false,
	liquidClover = false,
	fizzyBubbly = false,
	itsMoving = false
}

-- item stat values
local MoreItemBonus = {
	FRESH_WATER_DMG	= 1,
	FRESH_WATER_FD = 0.5,
	FRESH_WATER_TH = 1,
	FRESH_WATER_FS = 1,
	FRESH_WATER_SS = 0.5,
	FRESH_WATER_SPEED = 0.5,
	FRESH_WATER_LUCK = 1,
	MOMS_APPLE_JUICE_DMG = 3,
	MOMS_APPLE_JUICE_FD = 1,
	GLUCOSE_SPEED = 2,
	LIQUID_CLOVER = 5,
	ITS_MOVING = 5
}

-- pil: ibuprofen (following tutorial Im always angry)
local Ibuprofen = {
	ID = Isaac.GetPillEffectByName("Ibuprofen")
}
Ibuprofen.Color = Isaac.AddPillEffectToPool(Ibuprofen.ID) -- supposed to return pill color

local Mucus = {
	ID = Isaac.GetPillEffectByName("Mucus!")
}
Mucus.Color = Isaac.AddPillEffectToPool(Mucus.ID) -- supposed to return pill color

-- save if player has items
local function UpdateMoreItems(player)
	HasMoreItem.greenCandle = player:HasCollectible(MoreItemsId.GREEN_CANDLE)
	HasMoreItem.freshWater = player:HasCollectible(MoreItemsId.FRESH_WATER)
	HasMoreItem.momsAppleJuice = player:HasCollectible(MoreItemsId.MOMS_APPLE_JUICE)
	HasMoreItem.glucose = player:HasCollectible(MoreItemsId.GLUCOSE)
	HasMoreItem.liquidClover = player:HasCollectible(MoreItemsId.LIQUID_CLOVER)
	HasMoreItem.fizzyBubbly = player:HasCollectible(MoreItemsId.FIZZY_BUBBLY)
	HasMoreItem.itsMoving = player:HasCollectible(MoreItemsId.ITS_MOVING)
end

-- on new run or continue
function MoreItems:onPlayerInit(player)
	UpdateMoreItems(player)
end
MoreItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MoreItems.onPlayerInit)

-- stats for the green candle active item
local GreenCandle = {
	Active = false,
	ActivationFrame = 1,
	Direction = Direction.NO_DIRECTION,
	DirectionStart = 1,
	EntityVariant = Isaac.GetEntityVariantByName("Green Candle"),
	Flame = nil,
	Sprite = nil,
	Entity = nil,
	HueWidth = 240
}

function MoreItems:ActivateGreenCandle(_Type, RNG)
	-- poison
	for i, entity in pairs(Isaac.GetRoomEntities()) do
		if entity:IsVulnerableEnemy() then
			entity:AddPoison(EntityRef(player), 150, 3.5)
		end
	end
	
	-- return true to hold up the item
	return true
end
MoreItems:AddCallback(ModCallbacks.MC_USE_ITEM, MoreItems.ActivateGreenCandle, MoreItemsId.GREEN_CANDLE)

-- debug text display
local a = "test"
local function ShowText()
	Isaac.RenderText("DEBUG:: " .. tostring(a), 50, 17, 1, 1, 1, 1)
end
MoreItems:AddCallback(ModCallbacks.MC_POST_RENDER, ShowText)
-- end text display

-- when passive effects should update
function MoreItems:onUpdate(player)

	-- Run at Intitalization
	if game:GetFrameCount() == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.GREEN_CANDLE, Vector(320,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.FRESH_WATER, Vector(270,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.MOMS_APPLE_JUICE, Vector(220,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.GLUCOSE, Vector(370,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.LIQUID_CLOVER, Vector(420,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.FIZZY_BUBBLY, Vector(470,300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreItemsId.ITS_MOVING, Vector(170,300), Vector(0,0), nil)
		
		--if player:GetName() == "Isaac" then
			--player:AddCollectible(MoreItemsId.LIQUID_CLOVER, 0, false)
		--end
		
	end
	-- end Initialization
	
	--[[
	-- Green Candle Functionality
	if GreenCandle.Active then
		local CurrentDirection = player:GetMovementDirection()
		local CurrentFrame = game:GetFrameCount()
		if GreenCandle.Direction ~= CurrentDirection or CurrentFrame > GreenCandle.DirectionStart + 20 or CurrentDirection == Direction.NO_DIRECTION then
			player:PlayExtraAnimation("Pickup")
			GreenCandle.DirectionStart = CurrentFrame
			GreenCandle.Direction = CurrentDirection
		end
		
		GreenCandle.Active = false
	end
	if GreenCandle.Entity ~= nil and game:GetFrameCount() - GreenCandle.ActivationFrame > 40 then
		GreenCandle.Entity:Remove()
		GreenCandle.Entity = nil
	elseif GreenCandle.Entity ~= nil then
		GreenCandle.Entity.Position = player.Position + Vector(0,1)
	end
	-- end Green Candle Functionality
	--]]
	
	-- find blood donation machine pedestal
	local Entities = game:GetRoom():GetEntities()
	for i=0, Entities.Size-1, 1 do
		if Entities:Get(i).Type == EntityType.ENTITY_PICKUP and Entities:Get(i).Variant == PickupVariant.PICKUP_COLLECTIBLE then
			-- if we find a blood donation machine item pedestal
			if Entities:Get(i):GetSprite():GetOverlayFrame() == 2 then
				if Entities:Get(i).FrameCount == 1  and Entities:Get(i).SpawnerType ~= EntityType.ENTITY_PLAYER then
					local pos = Entities:Get(i).Position
					local rng = Entities:Get(i):GetDropRNG()
					local roll = rng:RandomInt(8) + 1
					Entities:Get(i):Remove()
					local NewEntitiy = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, MoreBloodBagsId[roll], pos, Vector(0,0), player)
					NewEntitiy:GetSprite():SetOverlayFrame("Alternates", 2)
				end
			end
		end
	end
	
	-- end blood donation machine pedestal search
	
	
	
	
	-- update items
	UpdateMoreItems(player)
	
	-- update Anger
	--if Ibuprofen.Room ~= nill and game:GetLevel():GetCurrentRoomIndex() ~= Ibuprofen.Room then
	--	player:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0),0,0,false,false)
	--	player.SpriteScale = Ibuprofen.FormerScale
	--	Ibuprofen.IsAngry = false
	--	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	--	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	--	player:EvaluateItems()
	--	Ibuprofen.Room = nil
	--end
	
end
MoreItems:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MoreItems.onUpdate)

-- when we update the cache, note: cache is evaluated before the post-update (i.e. before MC_POST_PEFFECT_UPDATE)
function MoreItems:onCache(player, cacheFlag)

	-- update stats for items effecting the damage flag (damage or fire delay)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		
		-- update stats for fresh water
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			player.Damage = player.Damage + MoreItemBonus.FRESH_WATER_DMG
		end
		
		-- update stats for mom's apple juice
		if player:HasCollectible(MoreItemsId.MOMS_APPLE_JUICE) then
			player.Damage = player.Damage + MoreItemBonus.MOMS_APPLE_JUICE_DMG
		end
		
		-- update stats for it's moving
		if player:HasCollectible(MoreItemsId.ITS_MOVING) then
			player.Damage = player.Damage + MoreItemBonus.ITS_MOVING
		end
	
	end
	
	-- update stats for items effecting the firedelay flag
	if cacheFlag == CacheFlag.CACHE_FIREDELAY then
	
		-- update stats for fresh water fire delay
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			if player.MaxFireDelay >= MIN_FIRE_DELAY + MoreItemBonus.FRESH_WATER_FD then
				player.MaxFireDelay = player.MaxFireDelay - MoreItemBonus.FRESH_WATER_FD
			elseif player.MaxFireDelay >= MIN_FIRE_DELAY then
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
		
		-- update stats for mom's apple juice fire delay
		if player:HasCollectible(MoreItemsId.MOMS_APPLE_JUICE) then
			if player.MaxFireDelay >= MIN_FIRE_DELAY + MoreItemBonus.MOMS_APPLE_JUICE_FD then
				player.MaxFireDelay = player.MaxFireDelay - MoreItemBonus.MOMS_APPLE_JUICE_FD
			elseif player.MaxFireDelay >= MIN_FIRE_DELAY then
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
	end
	
	-- update stats for items effecting the shotspeed flag
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		-- update stats for fresh water shot speed
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			player.ShotSpeed = player.ShotSpeed + MoreItemBonus.FRESH_WATER_SS
		end
	end
	
	-- update stats for items effecting the range flag
	if cacheFlag == CacheFlag.CACHE_RANGE then
		-- update stats for fresh water
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			player.TearHeight = player.TearHeight + MoreItemBonus.FRESH_WATER_TH
			player.TearFallingSpeed = player.TearFallingSpeed + MoreItemBonus.FRESH_WATER_FS
		end
		
	end
	
	-- update stats for items effecting the speed flag
	if cacheFlag == CacheFlag.CACHE_SPEED then
		-- update stats for glucose speed
		if player:HasCollectible(MoreItemsId.GLUCOSE) then
			player.MoveSpeed = player.MoveSpeed + MoreItemBonus.GLUCOSE_SPEED
		end
		
		-- update stats for fresh water speed
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			player.MoveSpeed = player.MoveSpeed + MoreItemBonus.FRESH_WATER_SPEED
		end
	end
	
	-- update stats for items effecting the luck flag
	if cacheFlag == CacheFlag.CACHE_LUCK then
		-- update stats for liquid clover
		if player:HasCollectible(MoreItemsId.LIQUID_CLOVER) then
			player.Luck = player.Luck + MoreItemBonus.LIQUID_CLOVER
		end
		
		-- update stats for fresh water luck
		if player:HasCollectible(MoreItemsId.FRESH_WATER) then
			player.Luck = player.Luck + MoreItemBonus.FRESH_WATER_LUCK
		end
	end
	
	-- update flight state for items effecting the flight flag
	if cacheFlag == CacheFlag.CACHE_FLYING then
		-- update stats for fizzy bubbly
		if player:HasCollectible(MoreItemsId.FIZZY_BUBBLY) then
			player.CanFly = true
		end
	end
	
end
MoreItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MoreItems.onCache)

-- Ibuprofen proc code
function Ibuprofen:Proc(_PillEffect)
	local player = game:GetPlayer(0)
	local numSoulHearts = player:GetSoulHearts()
	player:AddSoulHearts(-numSoulHearts)
	player:AddBlackHearts(numSoulHearts)
	-- SetColor(Color(Red, Green, Blue, Alpha, RedOffset, GreenOffset, BlueOffset), duration, priority, bool fadeOut, bool Share)
	--player:SetColor(Color(0.0, 0.7, 0.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
	--Ibuprofen.FormerScale = player.SpriteScale
	--player.SpriteScale = Ibuprofen.FormerScale + Ibuprofen.SCALE
	--Ibuprofen.Room = game:GetLevel():GetCurrentRoomIndex()
	--Ibuprofen.IsAngry = true
	
	-- set cache flags to update stats
	--player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	--player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	
end
MoreItems:AddCallback(ModCallbacks.MC_USE_PILL, Ibuprofen.Proc, Ibuprofen.ID)

-- Mucus! pill proc code
function Mucus:Proc(_PillEffect)
	local player = game:GetPlayer(0)
	local direction = player:GetShootingJoystick():Normalized()
	
	-- spawn creep all along the ground in the direction the player is facing
	
end
MoreItems:AddCallback(ModCallbacks.MC_USE_PILL, Mucus.Proc, Mucus.ID)


-- Isaac.DebugString("MoreItems")