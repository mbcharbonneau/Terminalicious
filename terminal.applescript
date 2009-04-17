tell application "Finder"
	if not (process "Terminal" exists) then
		tell application "Terminal"
			activate
			tell window 1
				close
			end tell
		end tell
	end if
end tell
tell application "Terminal"
	activate
	do script with command "COMMAND"
end tell