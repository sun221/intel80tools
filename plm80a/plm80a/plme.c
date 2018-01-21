#include "plm.h"
byte ioBuffer[2048];
byte builtins[] = {
	"\x5" "CARRY\0\0\x2"
	"\x3" "DEC\x1\x1\x2"
	"\x6" "DOUBLE\x2\x1\x3"
	"\x4HIGH\x3\x1\x2"
	"\x5INPUT\x4\x1\x2"
	"\x4LAST\x5\x1\x3"
	"\x6LENGTH\x6\x1\x3"
	"\x3LOW\x7\x1\x2"
	"\x4MOVE\x8\x3\0"
	"\x6OUTPUT\x9\x1\0"
	"\x6PARITY\xA\0\x2"
	"\x3ROL\xB\x2\x2"
	"\x3ROR\xC\x2\x2"
	"\x3SCL\xD\x2\x2"
	"\x3SCR\xE\x2\x2"
	"\x3SHL\xF\x2\x2"
	"\x3SHR\x10\x2\x2"
	"\x4SIGN\x11\0\x2"
	"\x4SIZE\x12\x1\x2"
	"\x8STACKPTR\x13\0\x3"
	"\x4TIME\x14\x1\0"
	"\x4ZERO\x15\0\x2"};

byte keywords[] = {
	"\x7" "ADDRESS\x28"
	"\x3" "AND\xA"
	"\x2" "AT\x29"
	"\x5" "BASED\x2A"
	"\x2" "BY\x35"
	"\x4" "BYTE\x2B"
	"\x4" "CALL\x1C"
	"\x4" "CASE\x36"
	"\x4" "DATA\x2C"
	"\x7" "DECLARE\x1D"
	"\x7" "DISABLE\x1E"
	"\x2" "DO\x1F"
	"\x4" "ELSE\x37"
	"\x6" "ENABLE\x20"
	"\x3" "END\x21"
	"\x3" "EOF\x38"
	"\x8" "EXTERNAL\x2D"
	"\x2GO\x22"
	"\x4GOTO\x23"
	"\x4HALT\x24"
	"\x2IF\x25"
	"\x7INITIAL\x2E"
	"\x9INTERRUPT\x2F"
	"\x5LABEL\x30"
	"\x9LITERALLY\x31"
	"\x5MINUS\x9" 
	"\x3MOD\x7" 
	"\x3NOT\xD"
	"\x2OR\xB"
	"\x4PLUS\x8" 
	"\x9PROCEDURE\x26"
	"\x6PUBLIC\x32"
	"\x9REENTRANT\x33"
	"\x6RETURN\x27"
	"\x9STRUCTURE\x34"
	"\x4THEN\x39"
	"\x2TO\x3A"
	"\x5WHILE\x3B"
	"\x3XOR\xC"};
