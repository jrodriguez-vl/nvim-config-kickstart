local M = {}

local function get_last_path_part(path)
	local part = nil
	for current_match in string.gmatch(path, "[^/\\]+") do
		part = current_match
	end
	return part
end

local function dir_lookup(directory)
  local runString = 'dir "'..directory..'" /b'
  local items = {}

  for file in io.popen(runString):lines() do
    table.insert(items, file)
  end

  return items
end

local function traverse_for_namespace(directory, parents)
  local result = {}
  local buildingNamespace = ''
  local curr_directory = directory
  for i = #parents, 1, -1 do
    if result.project ~= nil or result.sln ~= nil or result.slnx ~= nil then
      break
    end
    local directory_to_remove = parents[i]
    curr_directory = string.gsub(curr_directory, directory_to_remove, "")
    buildingNamespace =  directory_to_remove .. '.' .. buildingNamespace
    local foundFiles = dir_lookup(curr_directory)
    for _, file in pairs(foundFiles) do
      if result.project == nil and string.match(file, "%.[fc]sproj") then
        buildingNamespace = file:gsub("%.csproj", "") .. '.' .. buildingNamespace
        result.project = { file = file, directory = curr_directory }
      end
      if result.sln == nil and result.slnx == nil then
        if string.match(file, ".sln") then
          result.sln = { file = file, directory = curr_directory }
        end
        if string.match(file, ".slnx") then
          result.slnx = { file = file, directory = curr_directory }
        end
      end
    end
  end

  buildingNamespace = string.gsub(buildingNamespace, '/', '')
  buildingNamespace = string.gsub(buildingNamespace, '[.][.]', '')
  result.buildingNamespace = buildingNamespace
  return result
end

local function get_file_and_namespace(path)
    path = path or vim.fn.expand('%:p')
    path = string.gsub(path, "\\", "/")

    local directory = string.match(path, "(.+/)[^/\\]+%..+$")
    local file_name = string.match(path, "[^/\\]+%..+$")
    local file_base_name = get_last_path_part(file_name)
    file_base_name = string.match(file_base_name, "[^%.]+")
  local parents = {} for dir in string.gmatch(directory, "[^/\\]+") do
        table.insert(parents, dir .. '/')
    end
    table.insert(parents, "")

    local results = traverse_for_namespace(directory, parents)

    local namespace = results.buildingNamespace

    return {
        namespace = namespace,
        file_name = file_base_name,
    }
end

function M.bootstrap_csharp_file(opts)
	opts = opts or {}
	local names = get_file_and_namespace(opts.path)
	local buffer = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(buffer)

	local line_end = line_count
	-- local line_start = line_count - 1
	local line_start = 0

	if opts.append == false then
		line_start = 0
	end

	if not names or not names.namespace then
		return
	end

	local lines = {
		'namespace ' .. names.namespace ,
		'{',
		'public class ' .. names.file_name,
		'{',
		'',
		'}',
		'}'
	}
	vim.api.nvim_buf_set_lines(buffer, line_start, line_end, false, lines)
	vim.api.nvim_feedkeys('ggVG=', 'n', false)
end



return M
