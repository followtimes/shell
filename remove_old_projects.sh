#!/bin/bash


rm_and_save_list_log_file="/home/work/log/colliexe_save_file_list.$(date +%Y-%m-%d)"

cd /home/work/log/colliexe/projects

project_id_array=($(ls | grep ^[0-9] | awk -F '.' '{print $1}' | sort -u))

echo ${project_id_array}

for project_id in "${project_id_array[@]}"
do 
	echo "starting find "$project_id
	project_version_array=($(ls | grep "^$project_id." | awk -F '.' '{print $2}' ))
	max_project_version=$(
	for el in "${project_version_array[@]}"
	do
		echo "$el"
	done | sort -nr| head -n1)
	echo "max_project_verion: "$max_project_version
        echo "$project_id save dir:" >> $rm_and_save_list_log_file
        echo $project_id.$max_project_version >> $rm_and_save_list_log_file
	echo "others are:"
        echo "$project_id remove dir:" >> $rm_and_save_list_log_file
	for project_version in "${project_version_array[@]}"
	do 
		if [ $project_version -ne $max_project_version ];
		then 
			echo $project_id"."$project_version
			if [[ -z "${project_id// }" ]] || [[ -z "${project_version// }" ]];then
				echo "skip "$project_id"."$project_version
			else
				if [ -d "$project_id.$project_version" ];then
					echo "remove "$project_id"."$project_version
                                        echo $project_id.$project_version >> $rm_and_save_list_log_file
                                        rm -rf $project_id.$project_version
				else
					echo  $project_id"."$project_version" not exists"
				fi
			fi
		fi
	done
done
	
