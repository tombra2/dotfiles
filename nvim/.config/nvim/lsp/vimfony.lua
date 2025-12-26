local git_root = vim.fs.root(0, ".git")

if git_root ~= nil then
	vim.lsp.config("vimfony", {
		cmd = { "vimfony" },
		filetypes = { "php", "twig", "yaml", "xml" },
		root_markers = { ".git" },
		single_file_support = true,
		init_options = {
			roots = { "templates" },
			container_xml_path = (git_root .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
			-- OR:
			-- container_xml_path = {
			--   (git_root .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
			--   (git_root .. "/var/cache/website/dev/App_KernelDevDebugContainer.xml"),
			--   (git_root .. "/var/cache/admin/dev/App_KernelDevDebugContainer.xml"),
			-- },
			vendor_dir = git_root .. "/vendor",
			-- Optional:
			-- php_path = "/usr/bin/php",
		},
	})
end
