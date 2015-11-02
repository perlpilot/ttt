#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use TicTacToe;
use TicTacToe::API;

TicTacToe->deploy;  # create tables
TicTacToe->to_app;
