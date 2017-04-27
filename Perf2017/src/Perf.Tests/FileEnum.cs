using System;
using System.IO;
using System.Linq;
using Xunit;

namespace Perf.Tests
{
    public class Perf
    {
        [Fact]
        public void TestDirectoryEnumeratorRecursive()
        {
            var files = DirectoryEnumerator.GetDirectoryFiles(@"c:\windows", "*.exe", SearchOption.AllDirectories);
            Assert.Equal(2343, files.Count());
        }

        [Fact]
        public void TestFastDirectoryEnumeratorRecursive()
        {
            var files = PowerCode.FastDirectoryEnumerator.EnumerateFiles(@"c:\windows", "*.exe", SearchOption.AllDirectories, true);
            Assert.Equal(2343, files.Count());
        }
    }
}
