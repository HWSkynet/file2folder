local lfs = require("lfs")

dir_list = {}

if arg[1] then
	upath = arg[1]
else
	print("Usage: lua app.lua dir_path")
	return
end

function is_in_dir_list(file)
	for i, v in pairs(dir_list) do
		if file == v then
			return i
		end
	end
	return 0
end

function get_file_name(file)
	return file:match("(.+)%..+$")
end

function init_dirlist(path)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)
			assert(type(attr) == "table")
			if string.sub(file, 1, 1) ~= "." and attr.mode == "directory" then
				table.insert(dir_list, file)
			end
		end
	end
	print("Found " .. #dir_list .. " folders\n")
end

function pack_file_to_dir(path)
	local mv_files = 0
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)
			assert(type(attr) == "table")
			if string.sub(file, 1, 1) ~= "." and attr.mode == "file" then
				local dest_dir = path .. "/" .. get_file_name(file)
				if is_in_dir_list(get_file_name(file)) == 0 then
					lfs.mkdir(dest_dir)
					table.insert(dir_list, get_file_name(file))
					print("\nmkdir " .. dest_dir .. "\n")
				end
				os.execute('mv "' .. f .. '" "' .. dest_dir .. '"')
				print("move [" .. file .. "] ==>> [" .. dest_dir .. "]")
				mv_files = mv_files + 1
			end
		end
	end
	print("Moved " .. mv_files .. " files\n")
end

init_dirlist(upath)
pack_file_to_dir(upath)
