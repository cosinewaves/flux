--!strict
-- errors.lua

local errors = {}

local function format(sender: string, message: string)
	return `[beta.{sender:lower()}] {message}.`
end

function errors.new(sender: string, message: string, level: number): ()
	if level == 1 then
		print(format(sender, message))
	elseif level == 2 then
		warn(format(sender, message))
	elseif level == 3 then
		error(format(sender, message), 1)
	elseif level == 4 then
		error(format(sender, message), 2)
	else
		errors.new("errors", "invalid error level", 2)
	end
end

return table.freeze(errors)
