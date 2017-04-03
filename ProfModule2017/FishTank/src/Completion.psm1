using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

class FishTankCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $command,
        [string] $parameter,
        [string] $wordToComplete,
        [CommandAst] $ast,
        [IDictionary] $fakeBoundParameter
    ) {
        return $null
    }
}

