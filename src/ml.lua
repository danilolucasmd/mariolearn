local ml = {}

function log(x)
	if x == 0 then
		return 0
	end
	return math.log(x)/math.log(2)
end

function concat(a, b)
	if b ~= nil then
		for i=1, #b do
			a[i][#a[i]+1] = b[i]
		end
	end
	return a
end

function getLabels(rows)
	local set = {}
	for k, row in pairs(rows) do
		if set[row[#row]] == nil then
			set[row[#row]] = 0
		end
		set[row[#row]] = set[row[#row]] + 1
	end
	return set
end

function quantify(rows)
	local labels = getLabels(rows)
	local set = {}
	for k, v in pairs(labels) do
		set[#set+1] = v
	end
	return set
end

function entropy(set)
	local entr = 0
	for key, value in pairs(set) do
		entr = entr + ((-value)*log(value))
	end
	return entr
end

function info(set)
	if type(set[1]) == "table" then
		local _set = {}
		local size = 0
		for ki, vi in pairs(set) do
			_set[#_set+1] = {
				entr = info(vi),
				size = 0
			}
			for kj, vj in pairs(vi) do
				_set[#_set].size = _set[#_set].size + vj
			end
			size = size + _set[#_set].size
		end

		local entr = 0
		for k, v in pairs(_set) do
			entr = entr + ((v.size/size)*v.entr)
		end

		return entr
	else
		local size = 0
		for key, value in pairs(set) do
			size = size + value
		end

		local _set = {}
		for key, value in pairs(set) do
			_set[#_set+1] = value/size
		end
		return entropy(_set)
	end
end

function divide(node, branch, cond)
	local split
	if type(cond) == "number" then
		split = function(set)
			return set[branch] >= cond
		end
	elseif type(cond) == "string" then
		split = function(set)
			return set[branch] == cond
		end
	end

	local sett = {}
	local setf = {}
	for key, value in pairs(node) do
		if split(value) then
			sett[#sett+1] = value
		else
			setf[#setf+1] = value
		end
	end

	return sett, setf
end

function build(table)
	if #table == 0 then
		return {}
	end

	local original_gain = info(quantify(table))

	local max_gain = 0
  	local max_feature = {}
  	local max_sets = {}

	for col=1, #table[1]-1 do

		local keys = {}
		for k, row in pairs(table) do
			keys[row[col]] = 1
		end

		for key, value in pairs(keys) do
			local set_true, set_false = divide(table, col, key)

			local p = #set_true/#table
			local gain = original_gain-p*info(quantify(set_true))-(1-p)*info(quantify(set_false))

			if gain > max_gain and #set_true > 0 and #set_false > 0 then
				max_gain = gain
				max_feature = {col, key}
				max_sets = {set_true, set_false}
			end
		end
	end

	if max_gain > 0 then
		return {
			col = max_feature[1],
			cond = max_feature[2],
			true_b = build(max_sets[1]),
			false_b = build(max_sets[2])
		}
	else
		return {
			result = getLabels(table)
		}
	end
end

function run(tree, features)
	if tree.result ~= nil then
		return tree.result
	else
		local value = features[tree.col]
		local branch = {}
		if type(value) == "number" then
			if value >= tree.cond then
				branch = tree.true_b
			else
				branch = tree.false_b
			end
		else
			if value == tree.cond then
				branch = tree.true_b
			else
				branch = tree.false_b
			end
		end
		return run(branch, features)
	end
end


function ml.tree(features, labels)
	local tree = build(concat(features, labels))

	obj = {
		tree = tree,
		run = function(features)
			return run(tree, features)
		end
	}

	return obj
end

return ml
