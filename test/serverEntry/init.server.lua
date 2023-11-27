--!strict

local TweenPromise = require(game.ReplicatedStorage.Packages.TweenPromise)

local info = TweenPromise.info({
	time = 1,
	repeatCount = -1,
	delayTime = 1,
})

TweenPromise.callback(0, 1, info, function(alpha: number)
	print(alpha)
end)
