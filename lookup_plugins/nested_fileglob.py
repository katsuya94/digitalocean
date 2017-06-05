from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import glob

from jinja2.exceptions import UndefinedError

from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleError, AnsibleUndefinedVariable
from ansible.utils.listify import listify_lookup_plugin_terms
from ansible.module_utils._text import to_bytes, to_text

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

class LookupModule(LookupBase):
    def _lookup_variable(self, term, variables):
        try:
            return listify_lookup_plugin_terms(term, templar=self._templar, loader=self._loader, fail_on_undefined=True)
        except UndefinedError as e:
            raise AnsibleUndefinedVariable("The variable given for items was undefined. The error was: %s" % e)
    
    def run(self, terms, variables=None, **kwargs):
        if type(terms) is not dict:
            raise AnsibleError("nested_fileglob expects a dict")
        
        if u'items' not in terms:
            raise AnsibleError("nested_fileglob expects items")
        item_terms = self._lookup_variable(terms[u'items'], variables)

        if u'glob' not in terms:
            raise AnsibleError("nested_fileglob expects glob")
        glob_term = terms[u'glob']

        ret = []
        for item_term in item_terms:
            term = glob_term.replace(u'*', item_term, 1)
            term_file = os.path.basename(term)
            dwimmed_path = self.find_file_in_search_path(variables, 'files', os.path.dirname(term))
            if dwimmed_path:
                globbed = glob.glob(to_bytes(os.path.join(dwimmed_path, term_file), errors='surrogate_or_strict'))
                ret.extend((item_term, to_text(g, errors='surrogate_or_strict')) for g in globbed if os.path.isfile(g))
        return ret
