[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)


Write-Output "--- Enable Ruby 3.1"

Write-Output "Register Installed Ruby Version 3.1 With Uru"
Start-Process "uru_rt.exe" -ArgumentList 'admin add C:\ruby31\bin' -Wait
uru 312
if (-not $?) { throw "Can't Activate Ruby. Did Uru Registration Succeed?" }
ruby -v
if (-not $?) { throw "Can't run Ruby. Is it installed?" }

Write-Output "--- configure winrm"
winrm quickconfig -q

Write-Output "--- bundle install"
bundle config set --local without 'omnibus_package'
bundle install --jobs=3 --retry=3
$env:PATH = "C:\Program Files (x86)\Uru;" + $env:PATH

Write-Output "--- pwsh"
bundle exec ruby .\.expeditor\scripts\more_basic_powershell.rb pwsh

Write-Output "--- default"
bundle exec ruby .\.expeditor\scripts\more_basic_powershell.rb default

Write-Output "--- object"
bundle exec ruby .\.expeditor\scripts\more_basic_powershell.rb object
