#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# # Function to compose an arbitrary number of functions
# function compose() {
#     # echo "in compose"
#     # echo "@: $@"
#     shift
#     # echo "@: $@"
    
#     local result="$0"
#     shift
#     local functions=("$@")
#     # echo "@: $@"
#     for func in "${functions[@]}"; do
#         result="$("$func" "$result")"
#     done

#     echo -e "$result"
# }

# # function compose() {
# #     echo -e "$@"
# # }
# function compose() {
#     local result=""
#     for func in "$@"; do
#         result="$($func "$result")"
#     done
#     echo "$result"
#     # echo -e "$(dim $(red_fg "rrrr"))"
# }

# # Example usage with an arbitrary number of functions
# composed_result=$(compose greet capitalize add_exclamation)

# # Use the result
# echo "$composed_result"

end_tag="\e[0m"
bold_tag="\e[1m"
bold_end_tag="\e[21m"
dim_tag="\e[2m"
dim_end_tag="\e[22m"
underline_tag="\e[4m"
underline_end_tag="\e[24m"
blink_tag="\e[5m"
blink_end_tag="\e[25m"
hidden_tag="\e[8m"
hidden_end_tag="\e[28m"
fg_tag="\e[38;5;"
fg_mid_tag="m"
bg_tag="\e[48;5;"
bg_mid_tag="m"

red_num="161"
green_num="121"
yellow_num="191"
blue_num="39"
cyan_num="117"
pink_num="212"
orange_num="215"
purple_num="141" # "147"
grey_num="248"
brown_num="137"


# red_num="88"
# green_num="2"
# yellow_num="191"
# blue_num="27"
# cyan_num="39"
# pink_num="164"
# orange_num="209"
# purple_num="135"
# grey_num="248"
# brown_num="3"

red_fg_tag="${fg_tag}${red_num}${fg_mid_tag}"
green_fg_tag="${fg_tag}${green_num}${fg_mid_tag}"
yellow_fg_tag="${fg_tag}${yellow_num}${fg_mid_tag}"
blue_fg_tag="${fg_tag}${blue_num}${fg_mid_tag}"
cyan_fg_tag="${fg_tag}${cyan_num}${fg_mid_tag}"
pink_fg_tag="${fg_tag}${pink_num}${fg_mid_tag}"
orange_fg_tag="${fg_tag}${orange_num}${fg_mid_tag}"
purple_fg_tag="${fg_tag}${purple_num}${fg_mid_tag}"
grey_fg_tag="${fg_tag}${grey_num}${fg_mid_tag}"
brown_fg_tag="${fg_tag}${brown_num}${fg_mid_tag}"


red_bg_tag="${bg_tag}${red_num}${bg_mid_tag}"
green_bg_tag="${bg_tag}${green_num}${bg_mid_tag}"
yellow_bg_tag="${bg_tag}${yellow_num}${bg_mid_tag}"
blue_bg_tag="${bg_tag}${blue_num}${bg_mid_tag}"
cyan_bg_tag="${bg_tag}${cyan_num}${bg_mid_tag}"
pink_bg_tag="${bg_tag}${pink_num}${bg_mid_tag}"
orange_bg_tag="${bg_tag}${orange_num}${bg_mid_tag}"
purple_bg_tag="${bg_tag}${purple_num}${bg_mid_tag}"
grey_bg_tag="${bg_tag}${grey_num}${bg_mid_tag}"
brown_bg_tag="${bg_tag}${brown_num}${bg_mid_tag}"


function bold() {
    echo "${bold_tag}$1${bold_end_tag}"
}
function dim() {
    echo "${dim_tag}$1${dim_end_tag}"
}
function underline() {
    echo "${underline_tag}$1${underline_end_tag}"
}
function blink() {
    echo "${blink_tag}$1${blink_end_tag}"
}
function hidden() {
    echo "${hidden_tag}$1${hidden_end_tag}"
}


function red_fg() {
    echo "${red_fg_tag}$1${end_tag}"
}
function green_fg() {
    echo "${green_fg_tag}$1${end_tag}"
}
function yellow_fg() {
    echo "${yellow_fg_tag}$1${end_tag}"
}
function blue_fg() {
    echo "${blue_fg_tag}$1${end_tag}"
}
function cyan_fg() {
    echo "${cyan_fg_tag}$1${end_tag}"
}
function pink_fg() {
    echo "${pink_fg_tag}$1${end_tag}"
}
function orange_fg() {
    echo "${orange_fg_tag}$1${end_tag}"
}
function purple_fg() {
    echo "${purple_fg_tag}$1${end_tag}"
}
function grey_fg() {
    echo "${grey_fg_tag}$1${end_tag}"
}
function brown_fg() {
    echo "${brown_fg_tag}$1${end_tag}"
}


function red_bg() {
    echo "${red_bg_tag}$1${end_tag}"
}
function green_bg() {
    echo "${green_bg_tag}$1${end_tag}"
}
function yellow_bg() {
    echo "${yellow_bg_tag}$1${end_tag}"
}
function blue_bg() {
    echo "${blue_bg_tag}$1${end_tag}"
}
function cyan_fg() {
    echo "${cyan_fg_tag}$1${end_tag}"
}
function pink_bg() {
    echo "${pink_bg_tag}$1${end_tag}"
}
function orange_bg() {
    echo "${orange_bg_tag}$1${end_tag}"
}
function purple_fg() {
    echo "${purple_fg_tag}$1${end_tag}"
}
function grey_bg() {
    echo "${grey_bg_tag}$1${end_tag}"
}
function brown_bg() {
    echo "${brown_bg_tag}$1${end_tag}"
}

