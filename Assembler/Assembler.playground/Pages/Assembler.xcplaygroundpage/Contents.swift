//: [Previous](@previous)

import Foundation

// .asm file with that name must be in 'Resources' folder of playground
let path = "FibonacciNumber" // FibonacciNumber, testArithmetic, testCMPandJMP, testLogic


enum Section {
    case None
    case Data
    case Text
}

// Instruction list; instructionName + arguments (m: memory Addr, c: constant)
let instructions = [
    "passm": 0,
    "notm": 1,
    "ormm": 2,
    "ormc": 3,
    "andmm": 4,
    "andmc": 5,
    "addmm": 6,
    "addmc": 7,
    "submm": 8,
    "submc": 9,
    "cmpmm": 10,
    "cmpmc": 11,
    "movmm": 12,
    "movmc": 13,
    "jmpl": 14,
    "jel": 15,
    "jnel": 16,
    "jgl": 17,
    "jgel": 18,
    "jll": 19,
    "jlel": 20,
    "jzl": 21,
    "jnzl": 22,
    "incm": 23,
    "decm": 24,
    "xormm": 25,
    "xormc": 26,
    "outm": 27
]

func assemble(path: String) -> String? {
    
    guard let fileURL = Bundle.main.url(forResource: path, withExtension: "asm") else {
        print("Error: No such file")
        return nil
    }
    
    var code: String
    var binaryCode: String = "v2.0 raw\n"
    
    var instructionPointer = 0
    
    func appendToBinaryCode(append: Int) {
        binaryCode.append(String(append, radix: 16, uppercase: false) + " ")
        instructionPointer += 1
    }
    func appendLabelToBinaryCode(append: String) {
        binaryCode.append(append + " ")
        instructionPointer += 1
    }
    
    var section = Section.None
    var varTable = [String: Int]()        // varName: addrss in memory RAM
    var varAddrCounter = 0;
    var labelTable = [String: Int]()      // labelName: address in ROM
    
    do {
        code = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    } catch {
        print("Error: \(error.localizedDescription)")
        return nil
    }
    
    var codeWithoutComments = ""
    
    // Remove all comments
    code.enumerateLines { ( fullLine, stop) -> () in
        
        var codeWithoutCommentsLine: String = ""
        if let match = Regex(";(.*)$").firstMatch(input: fullLine) {      // Lines with comments
            let index: String.Index = fullLine.index(fullLine.startIndex, offsetBy: match.range(at: 1).location)
            let line = String(fullLine[..<index])
            codeWithoutCommentsLine = line
        }
//        else if let match = Regex("^\\s*$").firstMatch(fullLine)  {  // Empty lines (we want the right line numbers so don't trim them)
//        }
        else {
            codeWithoutCommentsLine = fullLine
        }
        
        codeWithoutCommentsLine = codeWithoutCommentsLine.trimmingCharacters(in: .whitespaces)
        codeWithoutCommentsLine += "\n"
        codeWithoutComments.append(codeWithoutCommentsLine)
        
        // Look for labels
        if (codeWithoutCommentsLine.hasSuffix(":\n")) {
            let index: String.Index = codeWithoutCommentsLine.index(codeWithoutCommentsLine.endIndex, offsetBy: -2)
            let labelName = String(codeWithoutCommentsLine[..<index])
            labelTable[labelName] = -1;
        }
    }
    
    var lineNumber = 0      // For error messages
    
    // Iterate through lines of code
    codeWithoutComments.enumerateLines { ( line, stop) -> () in
        lineNumber += 1
        
        var addNewLine = false
        
        if (line.lowercased().hasPrefix("section .")) {
            let index: String.Index = line.index(line.startIndex, offsetBy: 9)
            let sectionString = String(line[index...])
            switch sectionString {
            case "data":
                section = .Data
            case "text":
                section = .Text
            default:
                section = .None
            }
        }
        else if (section == .Data) {
            if let match = Regex("^\\s*(\\S+)\\s(\\S+)").firstMatch(input: line) {
                let varName = String((line as NSString).substring(with: match.range(at: 1)))
                let varContent = String((line as NSString).substring(with: match.range(at: 2)))
                
                varTable[varName] = varAddrCounter
                varAddrCounter += 1

                if let instructionNumber = instructions["movmc"], let constant = decodeConstant(const: varContent) {
                    appendToBinaryCode(append: instructionNumber)
                    appendToBinaryCode(append: varTable[varName]!)
                    appendToBinaryCode(append: constant)
                }
                addNewLine = true
            }
        }
        else if (section == .Text) {
            if let match = Regex("^\\s*(\\S+)\\s(\\S+),?\\s?(\\S+)?").firstMatch(input: line) {
                let instructionName = String((line as NSString).substring(with: match.range(at: 1)))
                var argument1 = String((line as NSString).substring(with: match.range(at: 2)))
                if (argument1.hasSuffix(",")) {
                    let index: String.Index = argument1.index(argument1.endIndex, offsetBy: -1)
                    argument1 = String(argument1[..<index])
                }
                var argument2Opt: String? = nil
                if (match.range(at: 3).location != NSNotFound) {
                    argument2Opt = String((line as NSString).substring(with: match.range(at: 3)))
                }
                
                var instructionString = instructionName
                
                // Argument 1
                enum ArgumentType {
                    case Memory
                    case Constant
                    case Label
                    case None
                }
                var argument1Type = ArgumentType.None
                var argument1outputOpt: Int? = nil;
                
                if let argument1VarAddr = varTable[argument1] {
                    argument1outputOpt = argument1VarAddr
                    argument1Type = ArgumentType.Memory
                    instructionString.append("m")
                }
                else if labelTable[argument1] != nil {
                    argument1Type = ArgumentType.Label
                    instructionString.append("l")
                }
                else if let argument1Constant = decodeConstant(const: argument1) {
                    argument1outputOpt = argument1Constant
                    argument1Type = ArgumentType.Constant
                    instructionString.append("c")
                }
                
                // Argument 2
                var argument2VarAddrOpt: Int? = nil
                var argument2outputOpt: Int? = nil
                if let argument2 = argument2Opt {
                    argument2VarAddrOpt = varTable[argument2]
                    instructionString.append(argument2VarAddrOpt != nil ? "m" : "c")
                    argument2outputOpt = argument2VarAddrOpt ?? decodeConstant(const: argument2)
                }
                
                
                // Write to binary code
                if let instructionNumber = instructions[instructionString] {
                    if argument1outputOpt != nil || argument1Type == .Label {
                        if (argument2Opt != nil && argument2outputOpt == nil) {
                            print("Error: with second argument in line \(lineNumber)")
                        }
                        else {
                            appendToBinaryCode(append: instructionNumber)       // Write the instruction
                            if (argument1Type == .Label) {
                                appendLabelToBinaryCode(append: argument1)      // Write the name of the label and later replace it with the address
                            }
                            else {
                                appendToBinaryCode(append: argument1outputOpt!) // Write argument1
                            }
                            if let argument2output = argument2outputOpt {
                                appendToBinaryCode(append: argument2output)     // Write argumen2 if existing
                            }
                            addNewLine = true
                        }
                    }
                    else {
                        print("Error: with first argument in line \(lineNumber)")
                    }
                }
                else {
                    print("Error: with instruction in line \(lineNumber)")
                }
            }
            else if (line.hasSuffix(":")) {
                let index: String.Index = line.index(line.endIndex, offsetBy: -1)
                let labelName = String(line[..<index])
                labelTable[labelName] = instructionPointer;
            }
            
        }
        
        if addNewLine { binaryCode.append("\n") }
    }
    
    // Replace the label placeholders with the actual address
    for label in labelTable {
        while let range: Range<String.Index> = binaryCode.range(of: label.0) {
            binaryCode.replaceSubrange(range, with: String(NSString(format:"%2X", label.1)))
        }
    }
    
    return binaryCode
}

func decodeConstant(const: String) -> Int? {
    if (const.lowercased().hasPrefix("0x")) {
        let index: String.Index = const.index(const.startIndex, offsetBy: 2)
        let hexString = String(const[index...])
        return Int(strtoul(hexString, nil, 16))
    }
    else if (const.lowercased().hasPrefix("0b")) {
        let index: String.Index = const.index(const.startIndex, offsetBy: 2)
        let binaryString = String(const[index...])
        return Int(strtoul(binaryString, nil, 2))
    }
    else {
        return Int(const)
    }
}


if let binaryCode = assemble(path: path) {
    print(binaryCode)
}

//: [Next](@next)
