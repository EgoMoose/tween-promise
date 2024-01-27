--!native
--!optimize 2
--!strict

local Oklab = {}

-- Converts a Color3 to the Oklab color space.
-- The reason we use a Vector3 is that it's native, has the right amount of values, and also has the `Lerp` method.
function Oklab.to(color3: Color3): Vector3
	local red = color3.R
	local green = color3.G
	local blue = color3.B

	local long = 0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue
	local medium = 0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue
	local short = 0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue

	local longRoot = long ^ (1 / 3)
	local mediumRoot = medium ^ (1 / 3)
	local shortRoot = short ^ (1 / 3)

	return Vector3.new(
		0.2104542553 * longRoot + 0.7936177850 * mediumRoot - 0.0040720468 * shortRoot,
		1.9779984951 * longRoot - 2.4285922050 * mediumRoot + 0.4505937099 * shortRoot,
		0.0259040371 * longRoot + 0.7827717662 * mediumRoot - 0.8086757660 * shortRoot
	)
end

-- Converts from the Oklab color space to a Color3.
function Oklab.from(vector3: Vector3): Color3
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z

	local longRoot = x + 0.3963377774 * y + 0.2158037573 * z
	local mediumRoot = x - 0.1055613458 * y - 0.0638541728 * z
	local shortRoot = x - 0.0894841775 * y - 1.2914855480 * z

	local long = longRoot * longRoot * longRoot
	local medium = mediumRoot * mediumRoot * mediumRoot
	local short = shortRoot * shortRoot * shortRoot

	return Color3.new(
		math.clamp(4.0767416621 * long - 3.3077115913 * medium + 0.2309699292 * short, 0, 1),
		math.clamp(-1.2684380046 * long + 2.6097574011 * medium - 0.3413193965 * short, 0, 1),
		math.clamp(-0.0041960863 * long - 0.7034186147 * medium + 1.7076147010 * short, 0, 1)
	)
end

-- A slow lerp function. Calls `Oklab.to` twice and `Oklab.from` every call. ☹️
function Oklab.lerp(startColor3: Color3, finishColor3: Color3, alpha: number)
	return Oklab.from(Oklab.to(startColor3):Lerp(Oklab.to(finishColor3), alpha))
end

-- Used to create a faster lerp function. Calls `Oklab.to` twice initially, then `Oklab.from` every lerp call. 😊
function Oklab.createLerp(startColor3: Color3, finishColor3: Color3)
	local startVector3 = Oklab.to(startColor3)
	local finishVector3 = Oklab.to(finishColor3)

	return function(alpha: number)
		return Oklab.from(startVector3:Lerp(finishVector3, alpha))
	end
end

return table.freeze(Oklab)
