#!/usr/bin/env python2
# -*- coding: utf-8 -*-

def Entry():
	
	from urllib import urlencode, quote
	import sys
	sys.stdout.write(quote(sys.stdin.read()))

Entry()
