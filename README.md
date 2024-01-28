# tween-promise
 
A set of [promise](https://github.com/evaera/roblox-lua-promise) wrappers for the Roblox TweenService.

Get it here:

* [Wally](https://wally.run/package/egomoose/tween-promise)
* [Releases](https://github.com/EgoMoose/tween-promise/releases)

## API

```Lua
type TweenInfoOptions = {
	time: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,
}

--[=[
Creates a TweenInfo object

@param options TweenInfoOptions -- Key value pairs of standard tween info arguments. If value is omitted then default is used.
@return TweenInfo
--]=]
function module.info(options: TweenInfoOptions): TweenInfo
```

```Lua
--[=[
Provides a generalized linear interpolation function for all tween friendly data types.
It should match with how Roblox internally interpolates tween friendly data types.

@param from T & TweenFriendly -- The starting value of the lerp
@param to T & TweenFriendly -- The ending value of the lerp
@param alpha number -- The percentage between from and to
@return T
--]=]
function module.lerp<T>(from: T & TweenFriendly, to: T & TweenFriendly, alpha: number): T
```

```Lua
--[=[
Creates a new tween promise with a numerical callback.

@param from number -- The number the tween will start at
@param to number -- The number the tween will transition to
@param tweenInfo TweenInfo -- The tween info that the tween will use
@param callback (number) - () -- A function that is called each tween step with the current tween value
@return Promise
--]=]
function module.new(from: number, to: number, tweenInfo: TweenInfo, callback: (number) - ()): Promise

--[=[
Creates a new tween promise for an instance.

@param instance Instance -- The instance the tween will run on
@param tweenInfo TweenInfo -- The tween info that the tween will use
@param properties { [string]: TweenFriendly }) -- A key pair dictionary of where key = property_name and value = tween_target
@return Promise
--]=]
function module.new(instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenFriendly }): Promise
```

```Lua
type TweenCallbackOptions = {
	from: number, -- The number the tween will start at
	to: number, -- The number the tween will transition to
	initial: number?, -- where the alpha should start should be between [from, to] (defaults to from if nil)
	yieldStep: (() -> ())?, -- how long the tween should wait between its next step (defaults to RunService.Stepped:Wait())
}

--[=[
Creates a new tween promise with a numerical callback.

@param options TweenCallbackOptions -- a list of options that will be used internally by the tween
@param tweenInfo TweenInfo -- The tween info that the tween will use
@param callback (number) - () -- A function that is called each tween step with the current tween value
@return Promise
--]=]
function module.detailed.new(options: TweenCallbackOptions, tweenInfo: TweenInfo, callback: (number) - ()): Promise

--[=[
Creates a new tween promise for an instance.

@param options TweenCallbackOptions -- a list of options that will be used internally by the tween
@param instance Instance -- The instance the tween will run on
@param tweenInfo TweenInfo -- The tween info that the tween will use
@param properties { [string]: TweenFriendly }) -- A key pair dictionary of where key = property_name and value = tween_target
@return Promise
--]=]
function module.detailed.new(options: TweenCallbackOptions, instance: Instance, tweenInfo: TweenInfo, properties: { [string]: TweenFriendly }): Promise
```