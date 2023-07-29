#!/usr/bin/env python3
""" Lints Py and shell files
"""

import lintography

lintography.PyLinter().list().run()

lintography.ShellLinter().list().run()

# lintography.TextLinter(
#     skip_linters=(
#         'proselint',
#         'markdownlint',
#         # '/usr/local/bin/vale',
#     )
# ).list()
