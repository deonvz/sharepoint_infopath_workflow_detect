# Find InfoPath Forms and workflow in the SharePoint Farm. This will report all subsites that use these
# Written by Deon van Zyl
Write-Host "Get InfoPath Forms and Workflows"

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition 
#Set parent/top site to run from
$webApp = Get-SPWebApplication -Identity http://sharepointsitenamehere.com
$outputObj = @() 

foreach ($site in $webApp.Sites) {
        foreach($web in $site.AllWebs) {
                for($i = 0; $i -ne $web.lists.count; $i++) {
                        $list = $web.Lists[$i]
                        if ($list.BaseTemplate -eq "XMLForm" -and $list.BaseType -eq "DocumentLibrary") {
                                $FORM = New-Object PSObject
                                $FORM | Add-Member NoteProperty Type "Form" 
                                $FORM | Add-Member NoteProperty Site $($List.ParentWeb.Title)
                                $FORM | Add-Member NoteProperty URL $($List.ParentWeb.URL)
                                $FORM | Add-Member NoteProperty Title $($List.Title)
                                $outputObj += $FORM
                        }
                        #Workflow can be detected via ShareGate, else you can use the following
<#                        foreach ($wf in $list.WorkflowAssociations)
                       {
                              if ($wf.Enabled) {
                                  $WORKFLOW = New-Object PSObject 
                                  $WORKFLOW | Add-Member NoteProperty Type "Workflow" 
                                  $WORKFLOW | Add-Member NoteProperty Site $($List.ParentWeb.Title)
                                  $WORKFLOW | Add-Member NoteProperty URL $($List.ParentWeb.URL)
                                  $WORKFLOW | Add-Member NoteProperty Title $($List.Title)
                                  $WORKFLOW | Add-Member NoteProperty WorkflowName $($wf.Name)
                                  $WORKFLOW | Add-Member NoteProperty BaseTemplate $($wf.BaseTemplate)
                                  $WORKFLOW | Add-Member NoteProperty AssociationData $($wf.AssociationData)
                                  $outputObj += $WORKFLOW
                          }
                    } #>
            }
    }
    #DISPOSE Vars SITES AND WORKFLOW Loops / Should not be required as end of script closes it.
}
#Write the Results to File
$outputObj | Export-CSV -Path $scriptPath\InfoPathForms.csv -NoTypeInformation