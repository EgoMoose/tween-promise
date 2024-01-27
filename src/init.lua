--!native
--!strict

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Lerp = require(script:WaitForChild("Lerp"))
local Promise = require(script.Parent:WaitForChild("Promise"))

export type TweenFriendly = number | boolean | CFrame | Rect | Color3 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3

export type TweenInfoOptions = {
	time: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,
}

export type TweenCallbackOptions = {
	from: number,
	to: number,
	initial: number?,
	yieldStep: (() -> ())?,
}

local DEFAULT_TWEEN_INFO_OPTIONS: { [string]: any } = {
	time = 1,
	easingStyle = Enum.EasingStyle.Quad,
	easingDirection = Enum.EasingDirection.Out,
	repeatCount = 0,
	reverses = false,
	delayTime = 0,
}

local module = {}
local detailed = {}

-- Private

local function defaultYieldStep()
	RunService.Stepped:Wait()
end

local function tweenCallbackInternal(options: TweenCallbackOptions, tweenInfo: TweenInfo, callback: (alpha: number) -> ())
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

function detailed.callback(options: TweenCallbackOptions, tweenInfo: TweenInfo, callback: (alpha: number) -> ())
	return tweenCallbackInternal(options, tweenInfo, callback)
end

function detailed.new(options: TweenCallbackOptions, instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenFriendly })
	local intialValues = {}
	for key, _ in properties do
		intialValues[key] = (instance :: any)[key] :: TweenFriendly
	end

	return tweenCallbackInternal(options, tweenInfo, function(alpha: number)
		for key, targetValue in properties do
			(instance :: any)[key] = Lerp.tween(intialValues[key], targetValue, alpha)
		end
	end)
end

-- Public

function module.info(options: TweenInfoOptions): TweenInfo
	local merged: TweenInfoOptions = {}
	for key, value in DEFAULT_TWEEN_INFO_OPTIONS do
		merged[key] = options[key] or value
	end

	return TweenInfo.new(merged.time, merged.easingStyle, merged.easingDirection, merged.repeatCount, merged.reverses, merged.delayTime)
end

function module.callback(from: number, to: number, tweenInfo: TweenInfo, callback: (alpha: number) -> ())
	return detailed.callback({
		from = from,
		to = to,
	}, tweenInfo, callback)
end

function module.new(instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenFriendly })
	return detailed.new({
		from = 0,
		to = 1,
	}, instance, tweenInfo, properties)
end

--

module.detailed = detailed

return module
