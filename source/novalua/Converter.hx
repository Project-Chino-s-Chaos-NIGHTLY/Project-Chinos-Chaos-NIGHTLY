class Converter {
	public function new() {}
	public function dupeString(what:String, amt:Int) {
		var buffer = "";
		for (i in 0...amt) {
			buffer += what;
		}
		//trace(buffer);
		return buffer;
	}
	public function checkWordAt(word:String, at:Int, inStr:String) {
		var isWord = inStr.indexOf(word, at) == at;
		return isWord;
	}
	public function convertToHaxe(code:String) {
		var codeLines = code.split("\n");
		var lines = [];
		for (line in 0...codeLines.length) {
			if (StringTools.trim(codeLines[line]) != "") {
				lines.push(StringTools.trim(codeLines[line]));
			}
		}
		codeLines = lines;
		var fullCode = codeLines.join("\n");
		var inCode = fullCode;
		fullCode = StringTools.replace(fullCode, "\nend", "\n}");
		fullCode = StringTools.replace(fullCode, "then", "{");
		fullCode = StringTools.replace(fullCode, "print(", "trace(");
		fullCode = StringTools.replace(fullCode, "local", "var");
		var codeComb = fullCode.split("");
		var currentlyFuncMode = false;
		for (i in 0...codeComb.length) {
			var char = codeComb[i];
			if (checkWordAt("function", i, fullCode)) {
				currentlyFuncMode = true;
				//trace("function at: " + i);
			}
			if (currentlyFuncMode) {
				if (char == ",") {
					codeComb[i] = ":Dynamic,";
				}
				if (char == ")") {
					currentlyFuncMode = false;
					if (codeComb[i-1] != "(") {
						codeComb[i] = ":Dynamic) {";
					} else {
						codeComb[i] = ") {";
					}
				}
			}
		}
		var codeFinal = codeComb.join("");
		codeFinal = StringTools.replace(codeFinal, "{ ", "{\n");
		codeFinal = StringTools.replace(codeFinal, " }", "\n}");
		codeFinal = StringTools.replace(codeFinal, "{ ", "{");
		codeFinal = StringTools.replace(codeFinal, "} ", "}");
		codeFinal = StringTools.replace(codeFinal, "--[[", "/*");
		codeFinal = StringTools.replace(codeFinal, "]]--", "*/");
		codeFinal = StringTools.replace(codeFinal, "([[", "(\"");
		codeFinal = StringTools.replace(codeFinal, "]])", "\")");
		codeFinal = StringTools.replace(codeFinal, "--", "//");
		codeFinal = StringTools.replace(codeFinal, "else\n", "} else {");
		codeFinal = StringTools.replace(codeFinal, "elseif", "} else if");
		var codeSplit_I = codeFinal.split("\n");
		for (i in 0...codeSplit_I.length) {
			var l = codeSplit_I[i];
			if (
				!StringTools.endsWith(StringTools.trim(l), "}") &&
				!StringTools.endsWith(StringTools.trim(l), "{") &&
				!StringTools.endsWith(StringTools.trim(l), "\n") &&
				!StringTools.endsWith(StringTools.trim(l), "/") &&
				!StringTools.endsWith(StringTools.trim(l), ";")) {
				codeSplit_I[i] += ";";
			}
		}
		codeFinal = codeSplit_I.join("\n");
		//trace("\n    In:\n" + dupeString("-", 50) + "\n" + inCode + "\n    Out:\n" + dupeString("-", 50) + "\n" + codeFinal);
		return "\n" + codeFinal;
	}
}