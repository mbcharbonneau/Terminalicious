tell application "Finder"
	if not (process "iTerm" exists) then
		tell application "iTerm"
			activate
			-- iTerm should load a new terminal session
			set myterm to the first terminal
			tell myterm
				set mysession to the last session
			end tell
		end tell
	else
		tell application "iTerm"
			activate
			set myterm to (make new terminal)
			tell myterm
				set mysession to (make new session at the end of sessions)
			end tell
		end tell
	end if
end tell
tell application "iTerm"
	activate
	tell myterm
		tell mysession
			exec command "/bin/tcsh"
			write text "COMMAND"
		end tell
	end tell
end tell