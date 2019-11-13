# driverctl completion

_driverctl()
{
	local cur prev words cword
	_init_completion || return

	case $prev in
		[0-9][0-9]\.[0-9])
		# may or may not be <driver>
		return 0
		;;
		[0-9:.]*)
		_get_comp_words_by_ref -n : cur
		COMPREPLY=($(compgen -W "$(driverctl list-devices | cut -d' ' -f1)" -- "$cur"))
		__ltrim_colon_completions "$cur"
		return 0
		;;
		--noprobe)
		COMPREPLY=($(compgen -W "--bus --nosave --verbose list-devices list-overrides load-override set-override unset-override" -- "$cur"))
		return 0
		;;
		--nosave)
		COMPREPLY=($(compgen -W "--bus --noprobe --verbose list-devices list-overrides load-override set-override unset-override" -- "$cur"))
		return 0
		;;
		--verbose)
		COMPREPLY=($(compgen -W "--bus --noprobe --nosave list-devices list-overrides load-override set-override unset-override" -- "$cur"))
		return 0
		;;
		load-override|set-override|unset-override)
		COMPREPLY=($(compgen -W '$(${1:-driverctl} list-devices | cut -d" " -f1)' -- "$cur"))
		return 0
		;;
		list-overrides|list-devices)
		COMPREPLY=($(compgen -W "all storage network display multimedia memory bridge communication system input docking processor serial" -- "$cur" ))
		return 0
		;;
		driverctl)
		COMPREPLY=($(compgen -W "--bus --noprobe --nosave --verbose list-devices list-overrides load-override set-override unset-override" -- "$cur" ))
		return 0
		;;
	esac
}
complete -F _driverctl driverctl
