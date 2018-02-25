while read -ra words; do if [[ ${words[0]} == source ]]; then cat "${words[1]}"; else printf '%s\n' "${words[*]}"; fi; done < manifest > aggregated_script
