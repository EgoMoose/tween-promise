--!strict

local module = {}
local lerp = {}

-- Private

function lerp.number(from: number, to: number, alpha: number): number
	return (1 - alpha) * from + alpha * to
end

function lerp.boolean(from: boolean, to: boolean, alpha: number): boolean
	return if alpha < 0.5 then from else to
end

function lerp.CFrame(from: CFrame, to: CFrame, alpha: number): CFrame
	return from:Lerp(to, alpha)
end

function lerp.Rect(from: Rect, to: Rect, alpha: number): Rect
	-- stylua: ignore
	return Rect.new(
		lerp.Vector2(from.Min, to.Min, alpha),
		lerp.Vector2(from.Max, to.Max, alpha)
	)
end

function lerp.Color3(from: Color3, to: Color3, alpha: number): Color3
	return from:Lerp(to, alpha)
end

function lerp.UDim(from: UDim, to: UDim, alpha: number): UDim
	-- stylua: ignore
	return UDim.new(
		lerp.number(from.Scale, to.Scale, alpha),
		lerp.number(from.Offset, to.Offset, alpha)
	)
end

function lerp.UDim2(from: UDim2, to: UDim2, alpha: number): UDim2
	return from:Lerp(to, alpha)
end

function lerp.Vector2(from: Vector2, to: Vector2, alpha: number): Vector2
	return from:Lerp(to, alpha)
end

function lerp.Vector2int16(from: Vector2int16, to: Vector2int16, alpha: number): Vector2int16
	-- stylua: ignore
	return Vector2int16.new(
		lerp.number(from.X, to.X, alpha), 
		lerp.number(from.Y, to.Y, alpha)
	)
end

function lerp.Vector3(from: Vector3, to: Vector3, alpha: number): Vector3
	return from:Lerp(to, alpha)
end

-- Public

function module.number(from: number, to: number, alpha: number): number
	return lerp.number(from, to, alpha)
end

function module.tween<T>(from: T, to: T, alpha: number): T
	local rbxTypeFrom = typeof(from)
	local rbxTypeTo = typeof(to)
	
	-- stylua: ignore
	assert(rbxTypeFrom == rbxTypeTo, `{rbxTypeFrom} and {rbxTypeTo} are not of the same type and thus cannot be lerped.`)

	local lerpCallback = lerp[rbxTypeFrom]
	assert(lerpCallback, `{rbxTypeFrom} is not supported by TweenService.`)

	return lerpCallback(from, to, alpha) :: T
end

return module
