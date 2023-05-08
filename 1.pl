#!/usr/bin/perl
use IO::Socket;
use strict;

my $user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0;)";

# прочитаем URL
my $url = shift or die "Usage: $0 <url>\n";

# извлечем доменное имя
my ($domain) = $url =~ m|^(?:https?://)?([^/]+)|;

# получим IP-адрес сервера
my $ip = gethostbyname($domain);

# создадим сокет
my $socket = IO::Socket::INET->new(
    PeerAddr => $ip,
    PeerPort => 80,
    Proto    => 'tcp',
) or die "Can't connect to $ip\n";

# сформируем HTTP-запрос
my $request = "GET $url HTTP/1.0\r\n" .
    "Host: $domain\r\n" .
    "User-Agent: $user_agent\r\n" .
    "\r\n";

# отправим запрос
print $socket $request;

# получим ответ
my $response = "";
while (<$socket>) {
    $response .= $_;
}

if ($response =~ /(\d+) \S+ Found/) {
    # проверим, был ли установлен код состояния 302
    my $code = $1;
    print "Code: $code\n";
}

print $response;