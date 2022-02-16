#!/usr/bin/env python3

# Copyright (c) 2022 Glynn Forrest

# MIT licensed, see LICENSE.txt for details.

# This script is an extract from the full vault-helper.py script I use
# with clients. Any other version I have given to you is still
# licensed under those original terms.

import argparse, os, sys, requests, json, jsonschema, re
from colorama import Fore, Style

def red(text):
    return Fore.RED + text + Style.RESET_ALL

def yellow(text):
    return Fore.YELLOW + text + Style.RESET_ALL

def green(text):
    return Fore.GREEN + text + Style.RESET_ALL

def error(message=None):
    if message:
        print('{} {}'.format(red('ERROR'), message))

    sys.exit(1)


class VaultClient:
    def __init__(self, addr, token):
        self.addr = addr = addr.strip('/')
        self.token = token

    @staticmethod
    def create_from_env():
        return VaultClient(
            os.environ['VAULT_ADDR'],
            os.environ['VAULT_TOKEN']
        )

    def path(self, path):
        return '{}/v1/{}'.format(self.addr, path.strip('/'))

    def headers(self):
        return {
            'X-Vault-Token': self.token
        }

    def list(self, path):
        response = requests.get(self.path(path) + '?list=true', headers=self.headers())

        try:
            return response.json()['data']['keys']
        except KeyError:
            return []

    def list_secrets(self, path):
        path = path.strip('/')
        secrets = []

        for pathEnd in self.list(path):
            if pathEnd[-1] == '/':
                secrets = secrets + self.list_secrets('{}/{}'.format(path, pathEnd))
            else:
                secrets.append('{}/{}'.format(path, pathEnd))

        secrets.sort()

        return secrets

    def read_secret(self, path):
        response = requests.get(self.path(path), headers=self.headers())
        response.raise_for_status()

        return response.json()['data']

    def write_secret(self, path, data):
        requests.post(self.path(path), headers=self.headers(), data=json.dumps(data))


class VaultRule:
    def __init__(self, name, description, path_regex, schema):
        self.name = name
        self.description = description
        self.path_regex = path_regex
        jsonschema.Draft202012Validator.check_schema(schema)
        self.schema = schema

    def matches_path(self, path):
        return re.search(self.path_regex, path)

    def check_data(self, data):
        jsonschema.validate(data, self.schema)

    def describe(self):
        print('{} - {}'.format(yellow(self.name), self.description))
        print()
        print(yellow('Pattern: '))
        print(self.path_regex)
        print()
        print(yellow('Schema: '))
        print(json.dumps(self.schema, indent=2))

    def describe_json(self):
        print(json.dumps({
            "name": self.name,
            "description": self.description,
            "pattern": self.path_regex,
            "schema": self.schema,
        }, indent=2))

def schema_from_keys(keys):
    schema = {
        "type": "object",
        "properties": {},
        "additionalProperties": False,
        "required": []
    }

    for key, spec in keys.items():
        schema['properties'][key] = {}

        pieces = spec.split(':')
        spec_type = pieces[0]
        if spec_type[0:9] == 'optional_':
            spec_type = spec_type[9:]
        else:
            schema['required'].append(key)

        if spec_type not in ['string', 'integer', 'boolean']:
            raise Exception('Invalid type "{}". Available types for the shorthand syntax are "string", "integer", or "boolean".'.format(spec_type))

        schema['properties'][key] = {
            "type": spec_type
        }

        if len(pieces) > 1:
            if spec_type == 'string':
                schema['properties'][key]['pattern'] = pieces[1]
            if spec_type == 'integer':
                match = re.match('(\d+)-(\d+)', pieces[1])
                if not match:
                    raise Exception('Missing integer range')

                schema['properties'][key]['minimum'] = int(match[1])
                schema['properties'][key]['maximum'] = int(match[2])

    return schema



class VaultRules:
    rules = []

    def add(self, rule):
        self.rules.append(rule)

    def rule_by_path(self, secret_path):
        for rule in self.rules:
            if rule.matches_path(secret_path):
                return rule

        raise Exception("Secret path '{}' does not match any validation rules.".format(secret_path))

    def rule_by_name(self, rule_name):
        for rule in self.rules:
            if rule.name == rule_name:
                return rule

        raise Exception("Missing secret validation rule '{}'.".format(rule_name))

    def validate(self, secret_path, secret_data, ignore_missing_rule=False):
        try:
            rule = self.rule_by_path(secret_path)
        except Exception as e:
            if ignore_missing_rule:
                print('{}    {} ({})'.format(green('OK'), secret_path, red('missing rule')))
                return True

            print('{} {} ({}): {}'.format(red('ERROR'), secret_path, red('missing rule'), e))
            return False

        try:
            rule.check_data(secret_data)
            print('{}    {} ({})'.format(green('OK'), secret_path, yellow(rule.name)))
            return True
        except jsonschema.exceptions.ValidationError as e:
            print('{} {} ({}): {}.'.format(red('ERROR'), secret_path, yellow(rule.name), self.sanitize_error_message(e.message, secret_data)))
            return False

    def sanitize_error_message(self, message, value, key=''):
        # TODO: This is a hacky way to hide secret values from the
        # validation output, but it may subsitute legitimate words
        # in the error message for keys in the secret data.
        if type(value) == str:
            message = message.replace("'{}'".format(value), "'{}'".format(key))
        if type(value) == int:
            message = message.replace(str(value), "'{}'".format(key))
        if type(value) == dict:
            for key, item in value.items():
                message = self.sanitize_error_message(message, item, key)
        if type(value) == list:
            for item in value:
                message = self.sanitize_error_message(message, item)

        return message


    @staticmethod
    def load_from_file(filename):
        rules = VaultRules()
        with open(filename, mode='r', encoding='utf-8') as json_data:
            config = json.load(json_data)
            config_schema = {
                "type": "object",
                "properties": {
                    "rules": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "name": {
                                    "type": "string",
                                    "pattern": "^[-a-z0-9]+$"
                                },
                                "description": {
                                    "type": "string",
                                },
                                "pattern": {
                                    "type": "string",
                                },
                                "schema": {
                                    "type": "object"
                                },
                                "keys": {
                                    "type": "object",
                                    "additionalProperties": {
                                        "type": "string",
                                    }
                                }
                            },
                            "required": ["name", "description", "pattern"],
                            "additionalProperties": False
                        }
                    }
                },
                "required": ["rules"],
                "additionalProperties": False
            }

            jsonschema.validate(config, config_schema)
            for rule in config['rules']:
                if 'schema' in rule:
                    schema = rule['schema']
                else:
                    if 'keys' not in rule:
                        raise Exception('Rule {}: One of "schema" or "keys" is required.'.format(rule.name))
                    schema = schema_from_keys(rule['keys'])


                rules.add(VaultRule(
                    rule['name'],
                    rule['description'],
                    rule['pattern'],
                    schema
                ))


        return rules

class ValidateCommand:
    name = 'validate'
    description = 'Validate that a secret is valid'

    def register(self, subparser):
        subparser.add_argument('path', type=str)
        subparser.add_argument('--rules-file', default='rules.json')

    def run(self, args):
        v = VaultClient.create_from_env()
        rules = VaultRules.load_from_file(args.rules_file)

        try:
            secret_data = v.read_secret(args.path)
        except Exception as e:
            error(str(e))

        rules.validate(args.path, secret_data)


class ValidatePathCommand:
    name = 'validate-path'
    description = 'Validate that all the secrets in a given path are valid'

    def register(self, subparser):
        subparser.add_argument('path', type=str)
        subparser.add_argument('--rules-file', default='rules.json')
        subparser.add_argument('--stop-on-failure', action='store_true')
        subparser.add_argument('--ignore-missing-rule', action='store_true')

    def run(self, args):
        v = VaultClient.create_from_env()
        rules = VaultRules.load_from_file(args.rules_file)

        result = True

        for path in v.list_secrets(args.path):
            secret_data = v.read_secret(path)
            if not rules.validate(path, secret_data, args.ignore_missing_rule):
                if args.stop_on_failure:
                    sys.exit(1)

                result = False

        sys.exit(0 if result else 1)

class WriteCommand:
    name = 'write'
    description = 'Write a secret and ensure it conforms to a schema'

    def register(self, subparser):
        subparser.add_argument('path', type=str)
        subparser.add_argument('--rules-file', default='rules.json')

    def run(self, args):
        try:
            v = VaultClient.create_from_env()
            rules = VaultRules.load_from_file(args.rules_file)
            rule = rules.rule_by_path(args.path)
        except Exception as e:
            print('ERROR: ' + str(e))
            sys.exit(1)

        print('Writing {} secret type to {}'.format(yellow(rule.name), yellow(args.path)))
        data = {}

        for prop, prop_schema in rule.schema['properties'].items():
            if prop_schema['type'] not in ['string', 'integer', 'boolean']:
                error('Prop type "{}" is not supported. Only string, integer, and boolean values are supported by this command.'.format(prop_schema['type']))


        for prop, prop_schema in rule.schema['properties'].items():
            print()
            print(yellow(prop))
            print('{}: {}'.format(yellow('Type'), prop_schema['type']))
            if 'pattern' in prop_schema:
                print('{}: {}'.format(yellow('Pattern'), prop_schema['pattern']))

            data[prop] = self.get_value(prop_schema)

        v.write_secret(args.path, data)
        print('{}    wrote secret to {}.'.format(green('OK'), yellow(args.path)))

    def get_value(self, prop_schema):
        while True:
            print()
            value = input("Enter a value: ")
            if len(value) < 1:
                value = None
            try:
                jsonschema.validate(value, prop_schema)
                return value
            except jsonschema.exceptions.ValidationError as e:
                print('{} Invalid value: {}'.format(red('ERROR'), e.message))



class DescribeCommand:
    name = 'describe'
    description = 'Describe the structure of a secret schema'

    def register(self, subparser):
        subparser.add_argument('name', type=str)
        subparser.add_argument('--rules-file', default='rules.json')
        subparser.add_argument('--format', default='human', choices=['human', 'json'])

    def run(self, args):
        rules = VaultRules.load_from_file(args.rules_file)

        try:
            if '/' in args.name:
                error('Please enter the name of a secret rule (lowercase letters, numbers, and dashes only). Use "describe-path" to describe a schema by secret path.')

            rule = rules.rule_by_name(args.name)
            rule.describe_json() if args.format == 'json' else rule.describe()
        except Exception as e:
            error('{} ({}): {}'.format(args.name, red('missing rule'), e))

class DescribePathCommand:
    name = 'describe-path'
    description = 'Describe the schema of a secret in the given path'

    def register(self, subparser):
        subparser.add_argument('path', type=str)
        subparser.add_argument('--rules-file', default='rules.json')
        subparser.add_argument('--format', default='human', choices=['human', 'json'])

    def run(self, args):
        rules = VaultRules.load_from_file(args.rules_file)

        try:
            rule = rules.rule_by_path(args.path)
            rule.describe_json() if args.format == 'json' else rule.describe()
        except Exception as e:
            error('{} ({}): {}'.format(args.path, red('missing rule'), e))


class App:
    def __init__(self):
        self.parser = argparse.ArgumentParser(
            description='Helper commands to manage HashiCorp Vault.',
        )
        self.subparsers = self.parser.add_subparsers(
            dest="command",
        )

        self.add_command(ValidateCommand())
        self.add_command(ValidatePathCommand())
        self.add_command(WriteCommand())
        self.add_command(DescribeCommand())
        self.add_command(DescribePathCommand())

    def add_command(self, command):
        subparser = self.subparsers.add_parser(command.name, help=command.description)
        subparser.set_defaults(func=command.run)
        command.register(subparser)

    def run(self):
        args = self.parser.parse_args()
        try:
            args.func(args)
        except AttributeError as e:
            self.parser.print_usage()
            sys.exit(1)


if __name__ == "__main__":
    app = App()
    app.run()
