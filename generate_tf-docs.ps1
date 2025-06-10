foreach ($directory in (get-childitem -path "./modules" -Directory)) {
    # set-location -Path $directory.FullName
    terraform-docs.exe markdown table --output-file README.md --output-mode inject $directory
    # write-output $directory.FullName
}
terraform-docs.exe markdown table --output-file README.md --output-mode inject "./"
