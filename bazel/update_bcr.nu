def main [registry_dir: string] {
	let root_dir = ($env.FILE_PWD + '/..') | path expand;
	cd $root_dir;

	let module_name = "libarchive";
	let registry_dir = $registry_dir | path expand;
	let registry_module_dir = $registry_dir | path join $"modules/($module_name)";
	let metadata = open ($registry_module_dir | path join "metadata.json");
	let bazel_module_version = (buildozer 'print version' //MODULE.bazel:%module);

	# for v in $metadata.versions {
	#	if $v == $bazel_module_version {
	#		echo $"ERROR: ($module_name)@($bazel_module_version) already added";
	#		exit 1;
	#	}
	#}

	echo $"INFO: writing ($module_name)@($bazel_module_version) to ($registry_dir) ...";
	let module_version_dir = ($registry_module_dir | path join $bazel_module_version);
	let patches_dir = $module_version_dir | path join 'patches';
	mkdir $module_version_dir;
	mkdir $patches_dir;
	cp ($root_dir | path join 'MODULE.bazel') $module_version_dir;

	git diff v3.7.3..HEAD **/*.bazel **/*.bzl .bazelrc bazel/BUILD.bazel | save ($patches_dir | path join 'build_with_bazel.patch') -f;

	echo "DONE";
}
