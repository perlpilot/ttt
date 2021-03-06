requires "Dancer2" => "0.163000";
requires "Dancer2::Plugin::DBIC" => "0";
requires "Dancer2::Plugin::Auth::Tiny" => "0";
requires "Dancer2::Plugin::Deferred" => "0";
requires "Dancer2::Plugin::SendAs" => "0";
requires "Crypt::SaltedHash" => "0";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
    requires "JSON"            => "0";
};
