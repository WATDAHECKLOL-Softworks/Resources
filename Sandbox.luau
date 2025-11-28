do
    game:GetService("Players").LocalPlayer:Kick();

	local getmetamethod = function(target: any, method: string): any?
		local metatable: {  } | { [any]: any } = getrawmetatable(target) or {};
		local result: any? = rawget(metatable, method);
		return result;
	end;
	
    local debounce: boolean = false;
    local enable_index_func_hooking: boolean = true;

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
		elseif (mode == "call") then
            print(`Anti Cheat made a direct function call to {args[1]}, {args[2]}, {args[3]}`)
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
        if (enable_index_func_hooking and type(result) == "function" and iscclosure(result) and not isfunctionhooked(result)) then
            local func_name: string = debug.info(result, "n");
            local hook: (...any) -> (...any); hook = hookfunction(result, newcclosure(function(...)
                if (getthreadidentity() ~= 2 or getcallingscript() ~= ac) then
                    return hook(...);
                end;
                local result: any = hook(...);
                local arugments: {[number]: any} = {...};
                table.remove(arugments, 1);
                coroutine.wrap(output)("call", func_name, arugments[1], arugments[2], arugments[3])
                return result;
            end));
        end;
		coroutine.wrap(output)("index", self, operand);
		return result;
	end));
end;
