# Optional: don't execute the script in the weekend, since Azure schedule doesn't contain weekdays
$day = (Get-Date).DayOfWeek
if ($day -eq 'Saturday' -or $day -eq 'Sunday'){
    Write-Output "--- It's weekend, goodbye...."
    exit
}

# Connect via identity
Write-Output "--- Connecting to Azure using MSI..."
Connect-AzAccount -Identity

# Reading out the Azure Automation Account variables
Write-Output "--- Reading variables...."
$rg = Get-AutomationVariable -Name 'rg-name'
$servicePlan = Get-AutomationVariable -Name 'service-plan-name' 
$tier = Get-AutomationVariable -Name 'service-plan-tier' # For example Standard

$Date = Get-Date
switch($Date.ToString('tt')){
    'AM'{
        $sk = Get-AutomationVariable -Name 'scale-up-sku' # WorkerSize options are small, medium, large, extralarge
    }
    'PM'{
        $sk = Get-AutomationVariable -Name 'scale-down-sku' # WorkerSize options are small, medium, large, extralarge
    }
}

# Upscale the plan
Write-Output "--- Converting '$servicePlan' to '$sk'..."
Set-AzAppServicePlan -ResourceGroupName $rg -Name $servicePlan -Tier $tier -NumberofWorkers 1 -WorkerSize $sk

Write-Output "--- Done!'"
