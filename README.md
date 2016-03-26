# QA system prototype
It is really useful to understand german for understanding this repo.

## Installation
You need

- Stanford Open IE and its models
	- <https://www.dropbox.com/s/zte00ut23o9up6t/stanford-openie.jar?dl=0>
	- <https://www.dropbox.com/s/1gy9vt40xi4hb0p/stanford-openie-models.jar?dl=0>
	- <https://www.dropbox.com/s/s3nouv71dsveats/slf4j.jar?dl=0>
- Stanford Parser <https://www.dropbox.com/sh/ktamg99ctq59kay/AAD8bfThM2nGlz1055tp14hMa?dl=0>
- ReVerb <https://www.dropbox.com/s/h3bdb5kyl2knwc4/reverb-latest.jar?dl=0>
- Nodebox Linguistics Library <https://www.dropbox.com/sh/5xnrzrdseatlcro/AABQNDPN29rgfgkNZWXGxoLva?dl=0>
- nltk_data <https://www.dropbox.com/sh/wp6c6rmon52vjd2/AABhWQ1EkvfA4lBN1qzgmArNa?dl=0>

see Dockerfile for more information about where to put the needed software

## Running
	./pipeline.sh corpora/Introduction-to-Cloud-Computing.txt stdin

## Overview
![overviewqasystem](https://raw.githubusercontent.com/ronnyworm/bachelorthesis_qasystem/master/pipeline.jpg)

## Information about the Docker-Image
in german

<https://hub.docker.com/r/ronnydockerhubid/bachelorarbeitfas/>