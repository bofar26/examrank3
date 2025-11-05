#define _GNU_SOURCE
#define BUFFER_SIZE 1024
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>

void	fill_stars(char *str, size_t plen)
{
	size_t	i = 0;

	while (i < plen)
	{
		str[i] = '*';
		i ++;
	}
}

void	replace_all(char *buf, size_t len, char *pat, size_t plen)
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
		fill_stars(found, plen);
		adv = (found + plen) - cur;
		cur += adv;
		len -= adv;
	}
}



