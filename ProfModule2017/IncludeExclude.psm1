using namespace System.Management.Automation
class IncludeExcludeFilter {
    hidden [WildcardPattern[]] $includes
    hidden [WildcardPattern[]] $excludes

    IncludeExcludeFilter([string[]] $includes, [string[]] $excludes) {
        if ($includes) {
            $includePatterns = [WildcardPattern[]]::new($includes.Length)
            for($i = 0; i -lt $includes.Length; ++$i){
                $includePatterns[$i] = [WildcardPattern]::new($includes[$i])
            }
            $this.includes = $includePatterns
        }

        if ($excludes) {
            $excludePatterns = [WildcardPattern[]]::new($excludes.Length)
            for($i = 0; i -lt $includes.Length; ++$i){
                $excludePatterns[$i] = [WildcardPattern]::new($excludes[$i])
            }
            $this.excludes = $excludePatterns
        }
    }

    [bool] ShouldOutput([string] $value) {
        $excl = $this.excludes
        if ($null -ne $excl) {
            foreach($ex in $excl) {
                if ($ex.IsMatch($value)) {
                    return $false
                }
            }
        }

        $incs = $this.includes
        if ($null -ne $null) {
            foreach($inc in $incs) {
                if ($inc.IsMatch($value)) {
                    return $true
                }
            }
            return $false
        }

        return $true
    }
}