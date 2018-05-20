Set-Location /labs
sudo -u student git reset --hard origin/master
sudo -u student git pull
Set-Location /var/www/sec555-wiki
git reset --hard origin/master
git pull
Set-Location /var/www/sec555-wiki/sec555-labs
git reset --hard origin/master
git pull
$navigation_file = Get-Content -Path /var/www/sec555-wiki/navigation.md | Select -Skip 2
$labnav = Get-Content -Path /var/www/sec555-wiki/sec555-labs/Labs/labnav.md
$quicknav = Get-Content -Path /var/www/sec555-wiki/sec555-labs/Labs/quicknav.md

$new_navigation_file = $labnav
$new_navigation_file += $navigation_file
$new_navigation_file += $quicknav

$new_navigation_file | Out-File -Encoding ascii /var/www/sec555-wiki/navigation.md -Force
