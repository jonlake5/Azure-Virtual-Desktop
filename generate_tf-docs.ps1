foreach ($directory in (get-childitem -path "./modules" -Directory)) {
    terraform-docs.exe markdown table --output-file README.md --output-mode inject $directory
}
terraform-docs.exe markdown table --output-file README.md --output-mode inject "./"
