do
    game:GetService("Players").LocalPlayer:Kick();

	local getmetamethod = function(target: any, method: string): any?
		local metatable: {  } | { [any]: any } = getrawmetatable(target) or {};
		local method: any? = rawget(metatable, method);
		return method;
	end;
	
    local debounce: boolean = false;
	local output = function(mode: string, ...): ()
        while (debounce) do
            task.wait();
        end;
		local args: {any} = {...};
        local time_of_call: number = tick();
		for i: number, v: any in (args) do
			args[i] = (getmetamethod(v, "__tostring") and getmetamethod(v, "__tostring") ~= getrawmetatable(game).__tostring and typeof(v) or v);
		end;
        debounce = true;
		if (mode == "index") then
			print(`Anti Cheat made a metamethod call to __index {args[1]} {args[2]}, at {time_of_call}`);
		elseif (mode == "namecall") then
			print(`Anti Cheat made a metamethod call to __namecall {args[1]}, {args[2]}, {args[3]}, at {time_of_call}`);
		end;
        task.wait(2);
        debounce = false;
		return;
	end;
	
	local namecall: (...any) -> (...any); namecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		if (getthreadidentity() ~= 2 or getcallingscript() ~= ac) then
			return namecall(...);
		end;
		local result: any = namecall(...);
		local method: string = getnamecallmethod();
		local arugments: {[number]: any} = {...};
		coroutine.wrap(output)("namecall", method, arugments[1], arugments[2], arugments[3]);
		return result;
	end));
	local index: (...any) -> (...any); index = hookmetamethod(game, "__index", newcclosure(function(...)
		if (getthreadidentity() ~= 2 or getcallingscript() ~= ac) then
			return index(...);
		end;
		local result: any = index(...);
		local self: Instance, operand: string = ...;
		coroutine.wrap(output)("index", self, index);
		return result;
	end));
end;
