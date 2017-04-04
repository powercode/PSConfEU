using namespace System.Management.Automation

class Error {
    static [ErrorRecord] UnsupportedFileFormat([string] $path) {
        $x = [System.ArgumentException]::new("The path '$path' does not have the required extension '.ftk'")
        return [ErrorRecord]::new($x, "InvalidFileFormat", [ErrorCategory]::InvalidArgument, $path)
    }
}
