#cs ----------------------------------------------------------------------------

12.03.2022 - Drya - Nur 1D

#ce ----------------------------------------------------------------------------
#include-once

Func ArrayToStringRecursive($array, $delimiter = "|")
	$string = ""
	For $e In $array
		Switch VarGetType($e)
		Case "Array"
			$string &= "(" & ArrayToStringRecursive($e, $delimiter) & ")"
			Case "Bool"
				$string &= $e?"TRUE":"FALSE"
;~ 			Case "Ptr" ;ptr or hWnd
			Case "Int32"
				$string &= $e
			Case "Double" ;float
				$string &= $e
			Case "String"
				$string &= $e
;~ 			Case "Keyword"
			Case "Function" ;build in funcs
				$string &= FuncName($e)
			Case "UserFunction" ;all declared funcs
				$string &= FuncName($e)
			Case Else
				$string &= StringUpper(VarGetType($e))
		EndSwitch
		$string &= $delimiter
	Next
	Return StringTrimRight($string, StringLen($delimiter))
EndFunc