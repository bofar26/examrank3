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

	if (argc != 2 || !argv[1])
		return(perror("Error"), 1);
	carry = 0;
	pat = argv[1];
	plen = strlen(pat);
	if (plen > 1)
		keep = plen - 1;
	else
		keep = 0;
	buf = (char *)malloc(BUFFER_SIZE + keep);
	if (!buf)
		return (perror("Error"), 1);
	r = read(0, buf, BUFFER_SIZE);
	if (r < 0)
	{
		free(buf);
		return (perror("Error"), 1);
	}
	while (r > 0)
	{
		len = r + carry;
		replace_all(buf, len, pat, plen)
	}
}
