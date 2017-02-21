function Get-ObjectSource
{    
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,
        [string[]] $Exclude
    )
    begin{
        $culture = [System.Globalization.CultureInfo]::new($PSCulture)
    }
    process{        
        $cn = $InputObject.pstypenames[0]
        $p = $InputObject.psobject.properties.Where{$_.Name -notin $Exclude}.foreach{
            $n = $_.Name
            $tn = $_.TypeNameOfValue
            $v = $_.Value
            switch($tn) {
                'System.String' {
                    $v = "@`"$v`"";break
                }
                'System.UInt16' {$tn = 'short'; break}
                'System.UInt32' {$tn = 'int';  $v = "unchecked((int)$v)"; break}
                'System.UInt64' {$tn = 'long'; $v = "unchecked((long)$v)";break}
                'System.DateTime' {$tn = 'DateTime';$v = "DateTime.Parse(`"{0}`")" -f $v.ToString($culture);break}
                'System.Guid' {$tn = 'Guid'; $v = "Guid.Parse(`"$v`")";break}
                'System.Boolean' {$v = if ($v) {'true'} else {'false'}}
                default {
                    switch($n)
                    {
                        'SymType' {
                            $v = [int]$v
                        }
                        'VersionInfo'{
                            $v = '""'
                        }
                        'MachineType'{
                            $v = [int]$v
                        }
                    }
                }
            }
            [pscustomobject] @{                
                Name = $n
                TypeName = $tn
                Value = $v
            }
        }
        [PSCustomObject] @{
            Class = $cn
            Properties = $p
        }
    }        
}

function Format-Source {
    param(
        [Parameter(Mandatory)]
        [string] $ClassName
        ,
        [Parameter(ValueFromPipeline, Mandatory)]
        $InputObject                 
        )
    begin{
        "var ${ClassName}s = new List<$ClassName>{"
    }
    process{        
        "`tnew $ClassName {"
        $InputObject.Properties.Foreach{
            $n = $_.Name
            $v = $_.Value
        "`t`t$n = $v,"
        }
        "`t},"
    }
    end{
    "};"
    }
}

function Get-DumpInfo{
    function Get-PEBValue($peb, [string]$name){                
        $m = $peb | Select-String "$Name(?:=|:\s*)(.*)"
        $m.Matches[0].Groups[1].Value.Trim("' ")
    }
    $peb = Invoke-DbgCommand '!peb'        
    $o = [PSCustomobject] @{
        ProcessId = [int] (Invoke-DbgCommand '?? @$tpid').SubString(13)
		ComputerName =  Get-PEBValue $peb 'ComputerName'
		CurrentDirectory = Get-PEBValue $peb 'CurrentDirectory'
		ImageFile = Get-PEBValue $peb 'ImageFile'
		CommandLine = Get-PEBValue $peb 'CommandLine'
		CpuCount = [int] (Get-PEBValue $peb 'NUMBER_OF_PROCESSORS')
    }
    
    $o.PSTypeNames.Insert(0, 'DumpInfo')
    $o
}

lm | Get-ObjectSource | Format-Source -ClassName 'ModuleInfo'
k | Get-ObjectSource -Exclude Thread,Name | Format-Source -ClassName 'StackFrame'
t | Get-ObjectSource -exclude Frames | Format-Source -ClassName 'ThreadInfo'
Get-DumpInfo | Get-ObjectSource | Format-Source -ClassName 'DumpInfo'