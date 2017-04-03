using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using module .\Model.psm1

class FishTankCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $command,
        [string] $parameter,
        [string] $wordToComplete,
        [CommandAst] $ast,
        [IDictionary] $fakeBoundParameter
    ) {
        $result = [List[CompletionResult]]::new(10)
        switch ($parameter) {
            'ModelName' {
                $this.CompleteModel($result, $wordToComplete)
            }
        }
        return $result
    }

    [void] CompleteModel([List[CompletionResult]] $result, [string] $wordToComplete) {
        foreach ($ftm in [FishTankModel]::GetAll()) {
            $result.Add([CompletionResult]::new($ftm.ModelName, $ftm.ModelName, [CompletionResultType]::ParameterValue, $ftm.ToString()))
        }
    }
}

