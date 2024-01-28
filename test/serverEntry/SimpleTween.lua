--!strict

local TweenPromise = require(game.ReplicatedStorage.Packages.TweenPromise)

local info = TweenPromise.info({
	time = 5,
	easingStyle = Enum.EasingStyle.Linear,
	easingDirection = Enum.EasingDirection.Out,
	reverses = true,
	repeatCount = -1,
	delayTime = 1,
})

local options = {
	from = 0,
	to = 1,
	initial = 0.5,
}

TweenPromise.detailed.callback(options, info, function(alpha: number)
	print(alpha)
end)

return {}
