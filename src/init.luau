--!strict

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Lerp = require(script.Lerp)
local Promise = require(script.Parent.Promise)

export type TweenFriendly = Lerp.LerpFriendly

export type TweenCallbackOptions = {
	from: number,
	to: number,
	initial: number?,
	yieldStep: () -> ()?,
}

export type TweenInfoOptions = {
	time: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,
}

local DEFAULT_TWEEN_INFO_OPTIONS: { [string]: any } = {
	time = 1,
	easingStyle = Enum.EasingStyle.Quad,
	easingDirection = Enum.EasingDirection.Out,
	repeatCount = 0,
	reverses = false,
	delayTime = 0,
}

local TweenPromise = {}
local detailed = {}

-- Private

local function defaultYieldStep()
	RunService.Stepped:Wait()
end

local function tweenCallbackInternal(options: TweenCallbackOptions, tweenInfo: TweenInfo, callback: (number) -> ())
	local tweenTime = tweenInfo.Time
	local easingStyle = tweenInfo.EasingStyle
	local easingDirection = tweenInfo.EasingDirection
	local repeatCount = tweenInfo.RepeatCount
	local reverses = tweenInfo.Reverses
	local delayTime = tweenInfo.DelayTime

	local from = options.from
	local to = options.to
	local yieldStep = options.yieldStep or defaultYieldStep

	local initial = options.initial or from
	local initialAlpha = math.clamp((initial - options.from) / (options.to - options.from), 0, 1)

	local playCount = 0
	local playForever = repeatCount < 0

	return Promise.new(function(resolve, _reject, cancel)
		while not cancel() and (playForever or playCount <= repeatCount) do
			local startTime = os.clock() + delayTime

			while not cancel() do
				local dt = os.clock() - startTime

				if dt >= 0 then
					local alpha = dt / tweenTime

					if playCount == 0 then
						alpha = alpha + initialAlpha
					end

					if reverses and alpha > 1 then
						alpha = 2 - alpha
					end

					local beta = TweenService:GetValue(alpha, easingStyle, easingDirection)
					local lerpedValue = Lerp.number(from, to, beta)

					task.spawn(callback, lerpedValue)

					if alpha >= 1 or (reverses and alpha <= 0) then
						break
					end
				end

				yieldStep()
			end

			playCount = playCount + 1
		end

		resolve()
	end)
end

--[=[
	Creates a new tween promise with a numerical callback.

	@param options TweenCallbackOptions -- a list of options that will be used internally by the tween.
	@param tweenInfo TweenInfo -- The tween info that the tween will use.
	@param callback (number) - () -- A function that is called each tween step with the current tween value.
	@return Promise<()>
]=]
function detailed.callback(options: TweenCallbackOptions, tweenInfo: TweenInfo, callback: (number) -> ())
	return tweenCallbackInternal(options, tweenInfo, callback)
end

--[=[
	Creates a new tween promise for an instance.

	@param options TweenCallbackOptions -- a list of options that will be used internally by the tween.
	@param instance Instance -- The instance the tween will run on.
	@param tweenInfo TweenInfo -- The tween info that the tween will use.
	@param properties { [string]: TweenFriendly }) -- A key pair dictionary of where key = propertyName and value = tweenTarget.
	@return Promise<()>
]=]
function detailed.new(
	options: TweenCallbackOptions,
	instance: Instance,
	tweenInfo: TweenInfo,
	properties: { [string]: TweenFriendly }
)
	local initialValues = {}
	for key, _ in properties do
		initialValues[key] = (instance :: any)[key] :: TweenFriendly
	end

	return tweenCallbackInternal(options, tweenInfo, function(alpha: number)
		for key, targetValue in properties do
			(instance :: any)[key] = Lerp.tween(initialValues[key], targetValue, alpha)
		end
	end)
end

-- Public

--[=[
	Provides a generalized linear interpolation function for all tween friendly data types.
	It should match with how Roblox internally interpolates tween friendly data types.

	@param from T & TweenFriendly -- The starting value of the lerp.
	@param to T & TweenFriendly -- The ending value of the lerp.
	@param alpha number -- The percentage between from and to.
	@return T
]=]
function TweenPromise.lerp<T>(from: T & TweenFriendly, to: T & TweenFriendly, alpha: number): T
	return Lerp.tween(from, to, alpha)
end

--[=[
	Shorthand for `Promise.resolve(...)` which is helpful to have in the context of tween promises.

	@param ... T...
	@return Promise<T...>
]=]
function TweenPromise.resolve<T...>(...: T...)
	return Promise.resolve(...)
end

--[=[
	Creates a TweenInfo object

	@param options TweenInfoOptions -- Key value pairs of standard tween info arguments. If value is omitted then default is used.
	@return TweenInfo
]=]
function TweenPromise.info(options: TweenInfoOptions): TweenInfo
	local merged: TweenInfoOptions = {}
	for key, value in DEFAULT_TWEEN_INFO_OPTIONS do
		merged[key] = options[key] or value
	end

	return TweenInfo.new(
		merged.time,
		merged.easingStyle,
		merged.easingDirection,
		merged.repeatCount,
		merged.reverses,
		merged.delayTime
	)
end

--[=[
	Creates a new tween promise with a numerical callback.

	```lua
	callback(0, 1, TweenInfo.new(1), function(alpha)
		for _, part in manyParts do
			part.Transparency = alpha
		end
	end)
	```

	@param from number -- The number the tween will start at.
	@param to number -- The number the tween will transition to.
	@param tweenInfo TweenInfo -- The tween info that the tween will use.
	@param callback (number) - () -- A function that is called each tween step with the current tween value.
	@return Promise<()>
]=]
function TweenPromise.callback(from: number, to: number, tweenInfo: TweenInfo, callback: (number) -> ())
	return detailed.callback({
		from = from,
		to = to,
	}, tweenInfo, callback)
end

--[=[
	Creates a new tween promise for an instance. This would be equivalent to `TweenService:Create`

	```lua
	new(part, TweenInfo.new(1), { CFrame = CFrame.identity })
	```

	@param instance Instance -- The instance the tween will run on.
	@param tweenInfo TweenInfo -- The tween info that the tween will use.
	@param properties { [string]: TweenFriendly }) -- A key pair dictionary of where key = propertyName and value = tweenTarget.
	@return Promise<()>
]=]
function TweenPromise.new(instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenFriendly })
	return detailed.new({
		from = 0,
		to = 1,
	}, instance, tweenInfo, properties)
end

--

TweenPromise.detailed = detailed

return TweenPromise
