//
//  c_interface.c
//  iProlog
//
//  Created by Claude Sammut on 30/09/12.
//
//

#include <stdio.h>
#include "IPinterface.h"

extern FILE *input, *output;
extern FILE *dialog_in, *dialog_out;
extern term _nil, _true, _false;

FILE *IP_input_stream()
{
	return input;
}

FILE *IP_output_stream()
{
	return output;
}

FILE *IP_dialog_in()
{
	return dialog_in;
}

FILE *IP_dialog_out()
{
	return dialog_out;
}

term IP_nil()
{
	return _nil;
}

term IP_true()
{
	return _true;
}

term IP_false()
{
	return _false;
}
