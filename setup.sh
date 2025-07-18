SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for dir in "$SCRIPTPATH"/.config/*; do
  dir_basename=$(basename "$dir")
  user_config_dir="${XDG_CONFIG_HOME}/${dir_basename}"

  ln -sF "$dir" "$user_config_dir"
  echo "${user_config_dir} linked to ${dir}"

  # if [ ! -d "$user_config_dir" ]; then
  #   ln -s "$dir" "$user_config_dir"
  #
  #   echo "${user_config_dir} linked to ${dir}"
  # fi
done

for bin in "$SCRIPTPATH"/.local/bin/*; do
  bin_basename=$(basename "$bin")
  user_bin_dir="${HOME}/.local/bin"

  if [ ! -d "$user_bin_dir" ]; then
    echo "${HOME}/.local/bin doesn't exist. Creating it via mkdir."
    mkdir "$user_bin_dir"
  fi

  ln -sf "$bin" "${user_bin_dir}/${bin_basename}"
  echo "${user_bin_dir}/${bin_basename} linked to ${bin}"
done

declare -a home_dir_files=(
  ".bashrc"
  ".inputrc"
  ".zshenv"
)

for f in "${home_dir_files[@]}"; do
  if [ -f ${SCRIPTPATH}/${f} ]; then
    ln -sf "${SCRIPTPATH}/${f}" "${HOME}/${f}"
    echo "${HOME}/${f} linked to ${SCRIPTPATH}/${f}"
  fi
done
