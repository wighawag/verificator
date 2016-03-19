package verificator;


import sys.io.Process;
import haxe.macro.Context;
import haxe.macro.Expr;

class VerificatorMacro{

	static function run(){

		Context.onAfterGenerate(function(){
			var newArgs = [];			
			var args = Sys.args();
			var i = 0;
			while(i < args.length){
				var arg = args[i];
				//TODO if(arg ends with .hxml) -> parse the file and merge ?
				if(arg=="-main"){
					newArgs.push(arg);
					newArgs.push("verificator.Verificator");
					i++;//skip next
				}else if(arg == "-js" || arg == "-cpp"){ //TODO other targets
					newArgs.push(arg);
					var followingArg = args[i+1];
					var indexOfLastDot = followingArg.lastIndexOf(".");
					var newArg = followingArg;
					if(indexOfLastDot >= 0){
						newArg = followingArg.substr(0,indexOfLastDot) + "_verificator" + followingArg.substr(indexOfLastDot);
					}else{
						newArg += "_verificator";
					}
					newArgs.push(newArg);
					i++;//skip next
				}else if(arg == "--macro" && args[i+1] == "verificator.VerificatorMacro.run()"){
					i++;//skip next
				}else{
					newArgs.push(arg);
				}
				i++;
			}
		
			newArgs.push("--macro");newArgs.push("verificator.VerificatorMacro.mapInput()");
		
			var haxePath = Sys.executablePath();
			trace(haxePath, newArgs);
			var haxeProcess = new Process(haxePath,newArgs);
			// trace("exitcode: " + haxeProcess.exitCode());
			// trace("process id: " + haxeProcess.getPid());
							
			// read everything from stderr
			var error = haxeProcess.stderr.readAll().toString();
			
			if(error != ""){
				trace("stderr:\n" + error);
			}
			
			// // read everything from stdout
			// var stdout = haxeProcess.stdout.readAll().toString();
							
			// trace("stdout:\n" + stdout);

			haxeProcess.close(); // close the process I/O
		});
		
	}
	
	public static function mapInput(){
		var inputPath = "verificator.Input";
		if(Context.defined("input")){
			inputPath = Context.definedValue("input");
		}
		var lastDotIndex = inputPath.lastIndexOf(".");
		var pack = inputPath.substr(0,lastDotIndex).split(".");
		var name = inputPath.substr(lastDotIndex+1);
		
		//override system.Input
		var typeDefinition = {
			pos : Context.currentPos(),
			pack : ["system"], 
			name : "Input",
			kind : TDAlias(TPath({
				pack:pack,
				name:name
			})),
			fields : []
			}
		Context.defineType(typeDefinition);
	}
	
}