#!/usr/bin/env python2
# -*- coding: utf-8 -*-

def Entry():
	
	from urllib import urlencode, unquote
	import sys
	sys.stdout.write(unquote(sys.stdin.read()))

Entry()

