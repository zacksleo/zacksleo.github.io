layout: utf8
title: gollum
date: 2017-03-11 15:12:15
tags:
---

> incompatible character encodings: UTF-8 and ASCII-8BIT

When use gollum , you may be got this error, below can helps you solves the problem.

+ install `gollum-rugged_adapter`
+ start gullom with `--adapter rugged`

```
sudo apt-get install cmake
sudo gem install gollum-rugged_adapter
gollum --adapter rugged

```

Here is a detailed demo for Dockerfile

```

FROM ruby
RUN apt-get -y update && apt-get -y install libicu-dev
RUN gem install gollum
RUN gem install github-markdown org-ruby 
# RUN gem install --pre gollum-rugged_adapter
RUN apt-get -y install cmake
RUN gem install gollum-rugged_adapter
VOLUME /docs
WORKDIR /docs
CMD ["gollum", "--port", "80", "--adapter", "rugged"]
#CMD ["gollum", "--port", "80"]

EXPOSE 80

```