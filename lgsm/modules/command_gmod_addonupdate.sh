#!/bin/bash
# LinuxGSM command_gmod_addonupdate.sh module
# Description: Updates Garry's Mod addons installed via git by running git pull on each.

commandname="GMOD-ADDONUPDATE"
commandaction="Updating GMod Addons"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
core_logs.sh

fn_gmod_addonupdate() {
	local addonsdir="${executabledir}/garrysmod/addons"

	if [ ! -d "${addonsdir}" ]; then
		fn_print_error_nl "Addons directory not found: ${addonsdir}"
		fn_script_log_error "Addons directory not found: ${addonsdir}"
		exitcode=1
		core_exit.sh
	fi

	fn_print_dots "Updating GMod addons"
	fn_script_log_info "Updating GMod git-based addons in ${addonsdir}"

	local git_dirs
	git_dirs=$(find "${addonsdir}" -type d -name .git)

	if [ -z "${git_dirs}" ]; then
		fn_print_info_nl "No git-based addons found in ${addonsdir}"
		fn_script_log_info "No git-based addons found in ${addonsdir}"
		core_exit.sh
	fi

	local update_count=0
	local fail_count=0

	while IFS= read -r gitdir; do
		local repo_dir
		repo_dir=$(dirname "${gitdir}")
		local addon_name
		addon_name=$(basename "${repo_dir}")

		fn_print_dots "Updating ${addon_name}"
		fn_script_log_info "Pulling changes for addon: ${addon_name}"

		if git -C "${repo_dir}" pull --no-edit > /dev/null 2>&1; then
			fn_print_ok_eol_nl
			fn_script_log_pass "${addon_name} updated successfully"
			((update_count++))
		else
			fn_print_fail_eol_nl
			fn_script_log_error "${addon_name} failed to update"
			((fail_count++))
		fi
	done <<< "${git_dirs}"

	fn_print_info_nl "Addon update complete: ${update_count} updated, ${fail_count} failed"
	fn_script_log_info "Addon update complete: ${update_count} updated, ${fail_count} failed"
}

fn_gmod_addonupdate
core_exit.sh
