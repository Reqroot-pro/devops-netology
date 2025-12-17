#!/usr/bin/python

# Copyright: (c) 2025, Your Name <support@dnkom.ru>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module
short_description: Create a file with specified content
version_added: "1.0.0"
description: This module creates or updates a file at the given path with the provided content.
options:
    path:
        description: The absolute path to the file to create or update.
        required: true
        type: str
    content:
        description: The content to write into the file.
        required: true
        type: str
author:
    - Your Name (@Reqroot-pro)
'''

EXAMPLES = r'''
- name: Create a file with custom content
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /tmp/example.txt
    content: Hello from custom Ansible module!
'''

RETURN = r'''
path:
    description: The path of the file that was created or updated.
    type: str
    returned: always
    sample: '/tmp/example.txt'
content:
    description: The content that was written to the file.
    type: str
    returned: always
    sample: 'Hello from custom Ansible module!'
'''

from ansible.module_utils.basic import AnsibleModule
import os


def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        path='',
        content=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']

    # Выход из режима проверки (check mode)
    if module.check_mode:
        # Проверим, изменилось бы состояние
        would_change = True
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                current = f.read()
            if current == content:
                would_change = False
        result['changed'] = would_change
        result['path'] = path
        result['content'] = content
        module.exit_json(**result)

    # Проверяем текущее состояние
    current_content = None
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                current_content = f.read()
        except Exception as e:
            module.fail_json(msg=f"Failed to read existing file: {str(e)}", **result)

    # Решаем, нужно ли изменять
    if current_content == content:
        result['changed'] = False
    else:
        try:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            result['changed'] = True
        except Exception as e:
            module.fail_json(msg=f"Failed to write file: {str(e)}", **result)

    result['path'] = path
    result['content'] = content

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()