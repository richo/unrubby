import re
import logging

import voltron
from voltron.api import *

log = logging.getLogger('api')

RUBY_Qfalse = 0
Qfalse = RUBY_Qfalse
RUBY_Qtrue  = 2
Qtrue = RUBY_Qtrue
RUBY_Qnil   = 4
Qnil = RUBY_Qnil
RUBY_Qundef = 6
Qundef = RUBY_Qundef

RUBY_IMMEDIATE_MASK = 0x03
RUBY_FIXNUM_FLAG    = 0x01
RUBY_FLONUM_MASK    = 0x00 # any values ANDed with FLONUM_MASK cannot be FLONUM_FLAG */
RUBY_FLONUM_FLAG    = 0x02
RUBY_SYMBOL_FLAG    = 0x0e
RUBY_SPECIAL_SHIFT  = 8

def get_cfp(dbg):
    values = {}
    pair = re.compile("  ([a-z_]+) = (0x\d+|\d+)")
    cfp = dbg.command("print *ruby_current_thread->cfp")
    for line in cfp.split("\n"):
        m = pair.match(line)
        if m:
            v = m.group(2)
            if v.startswith("0x"):
                value = int(v, 16)
            else:
                value = int(v, 10)
            values[m.group(1)] = value
    return values

class APIRubbyStackRequest(APIRequest):
    _fields = {}

    @server_side
    def dispatch(self):
        try:
            # Locate the top of the stack
            thread_addr = voltron.debugger.resolve_variable("ruby_current_thread")
            thread = voltron.debugger.read_pointer(thread_addr)

            # We need to find the location of the stack. We could do this with
            # pointer arith, but for now we just let lldb do the lifting for
            # us.

            cfp = get_cfp(voltron.debugger)

            # Lol how the fuck do we work out where the stack ends. Let's just
            # punt on there being ~8 values on it

            vals = []
            for i in range(8):
                pointer_width = 8 # TODO target pointer size
                addr = cfp["sp"] - pointer_width * i
                value = voltron.debugger.read_pointer(addr)
                if value == Qfalse:
                    val = { "type": "Boolean",
                            "value": False }
                elif value == Qtrue:
                    val = { "type": "Boolean",
                            "value": True }
                elif value == Qnil:
                    val = { "type": "Nilclass",
                            "value": None }
                elif value & RUBY_FIXNUM_FLAG:
                    val = { "type": "Fixnum",
                            "value": val >> 1 }
                # elif value & ~(0 << RUBY_SPECIAL_SHIFT) == RUBY_SYMBOL_FLAG
                elif value & RUBY_IMMEDIATE_MASK:
                    val = { "type": "immediate",
                            "value": "immediate" }
                else:
                    val = { "type": "unknown",
                            "value": value }
                val["addr"] = addr
                vals.append(val)


            res = APIRubbyStackResponse()
            res.thread = thread
            res.cfp = cfp
            res.vals = vals
        except NoSuchTargetException:
            res = APINoSuchTargetErrorResponse()
        except Exception as e:
            msg = "Exception executing debugger command: {}: {}".format(type(e), repr(e))
            log.exception(msg)
            res = APIGenericErrorResponse(msg)

        return res

    def get_current_thread(self):
        output = voltron.debugger.resolve_variable("ruby_current_thread")

    # TODO there has to be a better way to do this




class APIRubbyStackResponse(APISuccessResponse):
    _fields = {'thread': True,
               'cfp': True,
               'vals': True}

    thread = None
    cfp = None
    vals = None

class APIRubbyStackPlugin(APIPlugin):
    request = "rbstack"
    request_class = APIRubbyStackRequest
    response_class = APIRubbyStackResponse

