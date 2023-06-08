M = {}

local file_to_language = {
	["Cargo.toml"] =  "rust",
	["tsconfig.json"] = "typescript",
	["build.zig"] = "zig"
}

local run_commands = {
	c = function()
		local path = vim.cmd("echo @%%")
		local base_name = path:gsub("%.c")
		return "gcc -o " .. base_name .. path .. " && ./" .. base_name
	end,
	rust = function() return "cargo run" end,
	zig = function() return "zig build run" end
}
local extension_to_language = {
	bash = "bash",
	c = "c",
	cpp = "c++",
	java = "java",
	js = "javascript",
	kt = "kotlin",
	lua = "lua",
	py = "python",
	v = "v",
	ts = "typescript",
	rs = "rust",
	zig = "zig"
}

local function auto_detect_language()
	local src_file_names = vim.fn.system("ls -A")
	if string.match(src_file_names, "\\s+") then
		src_file_names = vim.fn.system("ls -A src")
	end

	local src_files = {}
	for file_name in src_file_names:gmatch("[\r\n]+") do
		table.insert(src_files, file_name)
	end

	local file_types = {}
	for _, file in ipairs(src_files) do
		local count = file_types[file:match("[^%.]+$")]
		if not count then count = 0 end
		file_types[file:match("[^%.]+$")] = count + 1
	end

	local max = 0
	local ext = nil
	for extension, count in pairs(file_types) do
		if count > max then
			max = count
			ext = extension
		end
	end

	return extension_to_language[ext]
end

local function contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

local function get_language_from_files(files)
	for filename, language in pairs(file_to_language) do
		if contains(files, filename) then
			return language
		end
	end
	return nil
end

local function get_project_language()
	local file_names = vim.fn.system("ls -A")
	local files = {}
	for file_name in file_names:gmatch("[^\r\n]+") do
		table.insert(files, file_name)
	end

	local language = get_language_from_files(files)

	if not language then language = auto_detect_language() end

	return language
end

M.run = function()
	local language = get_project_language()
	local command = run_commands[language]()
	vim.cmd("!" .. command)
end

M.setup = function()
	vim.api.nvim_create_user_command("NvimRun", M.run, {})
end

return M
