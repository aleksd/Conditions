properties { 
	$projectName = "Conditions"
	$buildNumber = "1.2.0.1"
	$rootDir  = Resolve-Path .\
	$buildOutputDir = "$rootDir\build"
	$srcDir = "$rootDir\src\Conditions"
	$solutionFilePath = "$srcDir\$projectName.sln"
}

task default -depends Clean, Compile, TransposeSource, CreateNuGetPackage

task Clean {
	Remove-Item $buildOutputDir -Force -Recurse -ErrorAction SilentlyContinue
	exec { msbuild /nologo /verbosity:quiet $solutionFilePath /t:Clean }
}

task Compile { 
	exec { msbuild /nologo /verbosity:quiet $solutionFilePath /p:Configuration=Release }
}

task TransposeSource {
	mkdir $buildOutputDir\SampleConsumer
	robocopy $rootDir\SampleConsumer $buildOutputDir\SampleConsumer *.* /S
	robocopy $srcDir\CuttingEdge.Conditions $buildOutputDir\SampleConsumer\SampleConsumer\content *.cs *.resx
	[xml]$xml = gc $buildOutputDir\SampleConsumer\SampleConsumer\SampleConsumer.csproj
	$itemGroup = $xml.Project.ItemGroup[1]
	gci $buildOutputDir\SampleConsumer\SampleConsumer\content -filter *.cs |% { 
		"Processing $_"
		Replace-Text $_ "namespace CuttingEdge.Conditions" "namespace Conditions"
		Replace-Text $_ "public static partial class" "internal static partial class"
        Replace-Text $_ "public static class" "internal static class"
        Replace-Text $_ "public abstract class" "internal abstract class"
        Replace-Text $_ "public class" "internal class"
        Replace-Text $_ "public enum" "internal enum"
        Replace-Text $_ "public interface" "internal interface"
		$compile = $xml.CreateElement("Compile", "http://schemas.microsoft.com/developer/msbuild/2003")
		$compile.SetAttribute("Include" , "content\$_")
		$itemGroup.AppendChild($compile)
	}
	gci $buildOutputDir\SampleConsumer\SampleConsumer\content -filter *.resx |% {
		$embeddedResource = $xml.CreateElement("EmbeddedResource", "http://schemas.microsoft.com/developer/msbuild/2003")
		$embeddedResource.SetAttribute("Include", "content\$_")
		$itemGroup.AppendChild($embeddedResource)
	}
	$xml.Save("$buildOutputDir\SampleConsumer\SampleConsumer\SampleConsumer.csproj")
	exec { msbuild /nologo /verbosity:quiet "$buildOutputDir\SampleConsumer\SampleConsumer.sln" /p:Configuration=Release }
}

task CreateNuGetPackage -depends TransposeSource {
	copy-item $rootDir\Conditions.Sources.nuspec $buildOutputDir
	exec { .$rootDir\tools\nuget.exe pack $buildOutputDir\Conditions.Sources.nuspec -BasePath .\ -o $buildOutputDir -version $buildNumber }
}