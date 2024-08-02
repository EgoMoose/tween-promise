--!strict

export type LerpFriendly = number | boolean | CFrame | Rect | Color3 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3

local Lerp = {}

function Lerp.number(from: number, to: number, alpha: number): number
	return (1 - alpha) * from + alpha * to
end

function Lerp.boolean(from: boolean, to: boolean, alpha: number): boolean
	return if alpha < 0.5 then from else to
end

function Lerp.CFrame(from: CFrame, to: CFrame, alpha: number): CFrame
	return from:Lerp(to, alpha)
end

function Lerp.Rect(from: Rect, to: Rect, alpha: number): Rect
	-- stylua: ignore
	return Rect.new(
		Lerp.Vector2(from.Min, to.Min, alpha),
		Lerp.Vector2(from.Max, to.Max, alpha)
	)
end

function Lerp.Color3(from: Color3, to: Color3, alpha: number): Color3
	return from:Lerp(to, alpha)
end

function Lerp.UDim(from: UDim, to: UDim, alpha: number): UDim
	-- stylua: ignore
	return UDim.new(
		Lerp.number(from.Scale, to.Scale, alpha),
		Lerp.number(from.Offset, to.Offset, alpha)
	)
end

function Lerp.UDim2(from: UDim2, to: UDim2, alpha: number): UDim2
	return from:Lerp(to, alpha)
end

function Lerp.Vector2(from: Vector2, to: Vector2, alpha: number): Vector2
	return from:Lerp(to, alpha)
end

function Lerp.Vector2int16(from: Vector2int16, to: Vector2int16, alpha: number): Vector2int16
	-- stylua: ignore
	return Vector2int16.new(
		Lerp.number(from.X, to.X, alpha), 
		Lerp.number(from.Y, to.Y, alpha)
	)
end

function Lerp.Vector3(from: Vector3, to: Vector3, alpha: number): Vector3
	return from:Lerp(to, alpha)
end

-- this is a lerp function for all tween friendly data types
-- it should match 1:1 with how roblox lerps tween friendly data types
function Lerp.tween<T>(from: T & LerpFriendly, to: T & LerpFriendly, alpha: number): T
	local rbxTypeFrom = typeof(from)
	local rbxTypeTo = typeof(to)

	assert(
		rbxTypeFrom == rbxTypeTo,
		`{rbxTypeFrom} and {rbxTypeTo} are not of the same type and thus cannot be lerped.`
	)

	local lerpCallback = Lerp[rbxTypeFrom]
	assert(lerpCallback, `{rbxTypeFrom} is not supported by TweenService.`)

	return lerpCallback(from, to, alpha) :: T
end

return Lerp
