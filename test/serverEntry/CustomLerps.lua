--!strict

local TweenPromise = require(game.ReplicatedStorage.Packages.TweenPromise)

local lerpOverrides = {}

function lerpOverrides.Color3(from: Color3, to: Color3, alpha: number): Color3
	-- just doing the standard lerp here, but an example of how you *could*
	-- overwrite this if you wanted to
	return from:Lerp(to, alpha)
end

local function lerp<T>(from: T, to: T, alpha: number): T
	local rbxTypeFrom = typeof(from)
	local rbxTypeTo = typeof(to)

	assert(rbxTypeFrom == rbxTypeTo, `{rbxTypeFrom} and {rbxTypeTo} are not of the same type and thus cannot be lerped.`)

	local lerpCallback = lerpOverrides[rbxTypeFrom]

	if lerpCallback then
		return lerpCallback(from, to, alpha) :: T
	else
		return TweenPromise.lerp(from, to, alpha) :: T
	end
end

local function detailedTweenNew(options: TweenPromise.TweenCallbackOptions, instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenPromise.TweenFriendly })
	local intialValues = {}
	for key, _ in properties do
		intialValues[key] = (instance :: any)[key] :: TweenPromise.TweenFriendly
	end

	return TweenPromise.detailed.callback(options, tweenInfo, function(alpha: number)
		for key, targetValue in properties do
			(instance :: any)[key] = lerp(intialValues[key], targetValue, alpha)
		end
	end)
end

local function tweenNew(instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenPromise.TweenFriendly })
	return detailedTweenNew({
		from = 0,
		to = 1,
	}, instance, tweenInfo, properties)
end

local part = Instance.new("Part")
part.Anchored = true
part.Color = Color3.new(0, 0, 0)
part.CFrame = CFrame.new(0, 10, 0)
part.Parent = workspace

local info = TweenPromise.info({
	time = 2,
	easingStyle = Enum.EasingStyle.Sine,
	easingDirection = Enum.EasingDirection.Out,
	reverses = true,
	repeatCount = -1,
})

tweenNew(part, info, {
	Color = Color3.new(1, 1, 1),
	Transparency = 0.7,
})

return {}
