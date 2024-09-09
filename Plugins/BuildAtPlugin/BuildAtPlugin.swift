import Foundation
import PackagePlugin

@main
struct BuildAtPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let tmpOutputFilePathString = try tmpOutputFilePath().string
        let outputFilePath = try outputFilePath(workDirectory: context.pluginWorkDirectory)
        
        // AccessLevelOnImport
        let importCode = """
        public import Foundation
        """
        
//        let importCode = """
//        import Foundation
//        """
        
        let bodyCode = """
        public extension Date {
            static let buildAt: Date = Date(timeIntervalSinceReferenceDate: \(Date.now.timeIntervalSinceReferenceDate))
        }
        """
        
        let generatedFileContent = [
            importCode,
            bodyCode
        ].joined(separator: "\n")
        
        try generatedFileContent.write(to: URL(fileURLWithPath: tmpOutputFilePathString), atomically: true, encoding: .utf8)
        
        return [
            .prebuildCommand(
                displayName: "BuildAtPlugin",
                executable: Path("/bin/cp"),
                arguments: [
                    tmpOutputFilePathString,
                    outputFilePath.string
                ],
                outputFilesDirectory: outputFilePath.removingLastComponent()
            )
        ]
    }
    
    private let generatedFileName = "BuildAtPlugin+Generated.swift"
    
    private func tmpOutputFilePath() throws -> Path {
        let tmpDirectory = Path(NSTemporaryDirectory())
        try FileManager.default.createDirectoryIfNotExists(atPath: tmpDirectory.string)
        return tmpDirectory.appending(generatedFileName)
    }
    
    private func outputFilePath(workDirectory: Path) throws -> Path {
        let outputDirectory = workDirectory.appending("Output")
        try FileManager.default.createDirectoryIfNotExists(atPath: outputDirectory.string)
        return outputDirectory.appending(generatedFileName)
    }
}

extension FileManager {
    func createDirectoryIfNotExists(atPath path: String) throws {
        guard !fileExists(atPath: path) else { return }
        try createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}
