import logging

from voltron.view import *
from voltron.plugin import *
from voltron.api import *

log = logging.getLogger('view')

ADDR_FORMAT_64 = '0x{0:0=16X}'
# cfp: {u'me': 0, u'iseq': 16795689, u'self': 4312234160, u'sp': 4302307344, u'dfp': 1049730, u'pc': 1049730, u'flag': 321, u'bp': 4302307344, u'lfp': 1049730, u'block_iseq': 0, u'proc': 0}

class RubbyStackView (TerminalView):
    # TODO deal with 32 bit platforms
    TEMPLATE = """\
thread    : 0x{thread:%(ptr)s}
===
self      : 0x{cfp[self]:%(ptr)s}
pc        : 0x{cfp[pc]:%(ptr)s}
sp        : 0x{cfp[sp]:%(ptr)s}

iseq      : 0x{cfp[iseq]:%(ptr)s}
block_iseq: 0x{cfp[block_iseq]:%(ptr)s}

dfp       : 0x{cfp[dfp]:%(ptr)s}
flag      : 0b{cfp[flag]:0=16b}

stack
===
""" % {"ptr": "0=16x"}

    STACK_TEMPLATE = """\
0x{addr:%(ptr)s}: ({type}) {value}
""" % {"ptr": "0=16x"}

    @classmethod
    def configure_subparser(cls, subparsers):
        sp = subparsers.add_parser('rubby-stack', aliases=('rbstack',),
                                   help='Display the contents of the rubby native stack')
        VoltronView.add_generic_arguments(sp)
        # sp.add_argument('command', action='store', help='command to run')
        sp.set_defaults(func=RubbyStackView)
        pass

    def render(self):
        # Set up header and error message if applicable
        self.title = '[RUBBY]'

        res = self.client.perform_request('rbstack', block=self.block)

        data = {
            "thread": res.thread,
            "cfp": res.cfp,
        }

        # don't render if it timed out, probably haven't stepped the debugger again
        if res.timed_out:
            return

        if res and res.is_success:
            # Get the command output
            self.body = self.TEMPLATE.format(**data)
            for val in res.vals:
                self.body += self.STACK_TEMPLATE.format(**val)
        else:
            log.error("Error executing command: {}".format(res.message))
            self.body = self.colour(res.message, 'red')

        # Call parent's render method
        super(RubbyStackView, self).render()


class RubbyStackViewPlugin(ViewPlugin):
    plugin_type = 'view'
    name = 'rbstack'
    view_class = RubbyStackView
