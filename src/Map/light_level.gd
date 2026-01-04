class_name LightLevel

const SUPERNATURAL_DARKNESS: int = 0
const DARKNESS: int = 1
const DIM: int = 2
const NORMAL: int = 3
const BRIGHT: int = 4

static func clamp_level(level: int) -> int:
	return clampi(level, SUPERNATURAL_DARKNESS, BRIGHT)
