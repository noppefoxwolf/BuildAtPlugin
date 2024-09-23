import Foundation
import PackagePlugin

@main
struct BuildAtPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let tmpOutputFilePathString = try tmpOutputFilePath().path()
        var outputFilePath = try outputFilePath(workDirectory: context.pluginWorkDirectoryURL)
        
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
        outputFilePath.deleteLastPathComponent()
        
        return [
            .prebuildCommand(
                displayName: "BuildAtPlugin",
                executable: URL(filePath: "/bin/cp"),
                arguments: [
                    tmpOutputFilePathString,
                    outputFilePath.path()
                ],
                outputFilesDirectory: outputFilePath
            )
        ]
    }
    
    private let generatedFileName = "BuildAtPlugin+Generated.swift"
    
    private func tmpOutputFilePath() throws -> URL {
        let tmpDirectory = URL(filePath: NSTemporaryDirectory())
        try FileManager.default.createDirectoryIfNotExists(atPath: tmpDirectory.path())
        return tmpDirectory.appending(path: generatedFileName)
    }
    
    private func outputFilePath(workDirectory: URL) throws -> URL {
        let outputDirectory = workDirectory.appending(path: "Output")
        try FileManager.default.createDirectoryIfNotExists(atPath: outputDirectory.path())
        return outputDirectory.appending(path: generatedFileName)
    }
}

extension FileManager {
    func createDirectoryIfNotExists(atPath path: String) throws {
        guard !fileExists(atPath: path) else { return }
        try createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}
