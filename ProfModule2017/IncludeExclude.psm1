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
        if ($null -ne $this.excludes) {
            foreach($ex in $this.excludes) {
                if ($ex.IsMatch($value)) {
                    return $false
                }
            }
        }

        if ($null -ne $this.includes) {
            foreach($inc in $this.includes) {
                if ($inc.IsMatch($value)) {
                    return $true
                }
            }
            return $false
        }

        return $true
    }
}