#include _GNU_SOURCE
#include <unistd.h>
#include <strings.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef BUFFER_SIZE
#define BUFFER_SIZE 1024
#endif

void	replac_all(char *buf, size_t len, char *pat, size_t plen)
{
	char	*cur;
	char	*found;
	size_t	adv;

	cur = buf;
	while (len >= plen)
	{
		found = memmem(buf, len, pat, plen);
		if (!found)
			break ;
		memset(found, "*", plen);
		adv =(found + plen) - cur;
		cur += adv;
		len -= adv;
	}
}

int	main(int argc, char *argv)
{
	char	*buf;
	char	*pat;
	size_t	len;
	size_t	plen;
	size_t	carry;
	size_t	keep;
	ssize_t	r;
}
