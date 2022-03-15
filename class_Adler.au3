#cs

Example:

Global $SIGN = NewAdler()
AdlerKeycoord($SIGN, 5,5)
AdlerKeypixel($SIGN,"rot",  128,256,    0,64,  0,64) ;mind. 128 rot UND maximal 256 rot
AdlerKeypixel($SIGN,"grün",   0,64,  128,256,  0,64)
AdlerKeypixel($SIGN,"nicht-grau", 192,64, 192,64, 192,64) ;mind. 192 rot ODER maximal 64 rot

#ce
#cs ----------------------------------------------------------------------------

12.03.2022 - Drya - Mache daraus doch eine Art Klasse
15.03.2022 - Drya - Sowohl Adler Pixel als auch Adler Image mit jeweils Key Version hinzugefügt

$adler	ist ein Array aus beliebig viele $element
$element ist ein Array zum aufrufen einer Func 0 = rückgabewert, 1 = function, 2 = parameters
$color   ist ein Array aus RGB: 0 = rot, 1 = grün, 2 = blau
$range	ist ein Array bestehend aus 0 = minimum wert und 1 = maximum wert
$colorRange ist ein Array bestehend aus 3x $range welche die 3 Farbwerte widerspiegeln

Funktionen, die von $element aufgerufen werden:
AdlerPixel $parameters		besteht aus $x, $y, $colorRange
AdlerKeycoord $paramters	besteht aus $x, $y
AdlerKeypixel $paramters	besteht aus $colorRange
AdlerImage $parameters		besteht aus $l, $t, $r, $b, $image
AdlerKeyarea $paramters		besteht aus $l, $t, $r, $b
AdlerKeyimage $paramters	besteht aus $image

#ce ----------------------------------------------------------------------------
#include-once
#include <Array.au3> ;_ArrayAdd
#include <Color.au3> ;_ColorGetRGB
#include "func_ArrayToStringRecursive.au3"

Global $__Adler_KeyResult = 0



Func NewAdler()
	Dim $element = [False, __AdlerBlank, Null]
	Dim $adler[1] = [$element]
	Return $adler
EndFunc

Func __AdlerBlank(Const ByRef $param, $hWindow = Default)
	Return False
EndFunc

Func Adler(ByRef $return, Const ByRef $adler, $hWindow = Default)
	For $element In $adler
		If($element[1]($element[2], $hWindow)) Then
			$return = $element[0]
			Return True
		EndIf
	Next
	Return False
EndFunc

Func AdlerDebug($index, Const ByRef $adler, $hWindow = Default)
	$element = $adler[$index] ;$return, $func, $param
	$param = $element[2]
	Switch FuncName($element[1])
		Case "__ADLERPIXEL"
			$result = _ColorGetRGB(PixelGetColor($param[0], $param[1], $hWindow))
			_ArrayAdd($element, $result, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
		Case "__ADLERKEYCOORD"
			$result = _ColorGetRGB(PixelGetColor($param[0], $param[1], $hWindow))
			_ArrayAdd($element, $result, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
		Case "__ADLERIMAGE"
			Dim $result[1]
			$result[0] = PixelChecksum($param[0], $param[1], $param[2], $param[3], 1, $hWindow)
			_ArrayAdd($element, $result, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
		Case "__ADLERKEYAREA"
			Dim $result[1]
			$result[0] = PixelChecksum($param[0], $param[1], $param[2], $param[3], 1, $hWindow)
			_ArrayAdd($element, $result, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
	EndSwitch
	Return $element
EndFunc

Func AdlerDebugAsString($index, Const ByRef $adler, $hWindow = Default)
	$element = AdlerDebug($index, $adler, $hWindow); $return, $func, $param, [$result]
	$param = $element[2]
	$funcname = FuncName($element[1])
	$string = "["&$element[0]&"]"&$funcname&"("
	$string &= ArrayToStringRecursive($element[2], ",")
	$string &= ")"
	If(UBound($element) >= 4) Then
		$string &= " = ("&ArrayToStringRecursive($element[3], ",")&")"
	EndIf
	Return $string
EndFunc



;Überpüfen ob an Pixel Coordinate $x und $y die $color in der $rgbRange befindet
Func AdlerPixel(ByRef $adler, $return, $x, $y, $r1, $r2, $g1, $g2, $b1, $b2)
	Dim $param[3] = [$x, $y, __ObjAdler_RgbRange($r1, $r2, $g1, $g2, $b1, $b2)]
	Dim $element[3] = [$return, __AdlerPixel, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerPixel(Const ByRef $param, $hWindow = Default)
	$color = _ColorGetRGB(PixelGetColor($param[0], $param[1], $hWindow))
	Return __ExeAdler_RgbRange($color, $param[2])
EndFunc

Func AdlerKeycoord(ByRef $adler, $x, $y)
	Dim $param[2] = [$x, $y]
	Dim $element[3] = [False, __AdlerKeycoord, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerKeycoord(Const ByRef $param, $hWindow = Default)
	$__Adler_KeyResult = _ColorGetRGB(PixelGetColor($param[0], $param[1], $hWindow))
EndFunc

Func AdlerKeypixel(ByRef $adler, $return, $r1, $r2, $g1, $g2, $b1, $b2)
	Dim $param[1] = [__ObjAdler_RgbRange($r1, $r2, $g1, $g2, $b1, $b2)]
	Dim $element[3] = [$return, __AdlerKeypixel, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerKeypixel(Const ByRef $param, $hWindow = Default)
	Return __ExeAdler_RgbRange($__Adler_KeyResult, $param[0])
EndFunc

Func AdlerImage(ByRef $adler, $return, $l, $t, $r, $b, $image)
	Dim $param[5] = [$l, $t, $r, $b, $image]
	Dim $element[3] = [$return, __AdlerImage, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerImage(Const ByRef $param, $hWindow = Default)
	Return $param[4] = PixelChecksum($param[0], $param[1], $param[2], $param[3], 1, $hWindow)
EndFunc

Func AdlerKeyarea(ByRef $adler, $l, $t, $r, $b)
	Dim $param[4] = [$l, $t, $r, $b]
	Dim $element[3] = [False, __AdlerKeyarea, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerKeyarea(Const ByRef $param, $hWindow = Default)
	$__Adler_KeyResult = PixelChecksum($param[0], $param[1], $param[2], $param[3], 1, $hWindow)
EndFunc

Func AdlerKeyimage(ByRef $adler, $return, $image)
	Dim $param[1] = [$image]
	Dim $element[3] = [$return, __AdlerKeyimage, $param]
	_ArrayAdd($adler, $element, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
EndFunc

Func __AdlerKeyimage(Const ByRef $param, $hWindow = Default)
	Return $param[0] = $__Adler_KeyResult
EndFunc

;Zum Überprüfen ob die $color im $rgbRange Spektrum liegt
Func __ObjAdler_RgbRange($r1, $r2, $g1, $g2, $b1, $b2)
	Dim $colorRange[3] = [__ObjAdler_Range($r1, $r2), __ObjAdler_Range($g1, $g2), __ObjAdler_Range($b1, $b2)]
	Return $colorRange
EndFunc

Func __ExeAdler_RgbRange(Const ByRef $color, Const ByRef $colorRange)
	$i = 0
	For $range In $colorRange
		If(Not $range[0]($color[$i],$range[1],$range[2])) Then
			Return False
		EndIf
		$i += 1
	Next
	Return True
EndFunc

;Zum Überprüfen ob $val innerhalb bzw außerhalb von $min und $max liegt
Func __ObjAdler_Range($min, $max)
	Dim $range[3] = [($min<=$max)?__ExeAdler_InnerRange:__ExeAdler_OuterRange, $min, $max]
	Return $range
EndFunc

Func __ExeAdler_InnerRange($val, $min, $max)
	Return $min <= $val AND $val <= $max
EndFunc

Func __ExeAdler_OuterRange($val, $max, $min)
	Return $val <= $min OR $max <= $val
EndFunc
