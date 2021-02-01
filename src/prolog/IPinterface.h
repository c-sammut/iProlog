//
//  IPinterface.h
//  iProlog
//
//  Created by Claude Sammut on 30/09/12.
//
//

#ifndef iProlog_IPinterface_h
#define iProlog_IPinterface_h
#endif

#include "prolog.h"

FILE *IP_input_stream();
FILE *IP_output_stream();
FILE *IP_dialog_in();
FILE *IP_dialog_out();

term IP_nil();
term IP_true();
term IP_false();
