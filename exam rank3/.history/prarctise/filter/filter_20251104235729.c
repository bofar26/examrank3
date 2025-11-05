#define _GNU_SOURCE
#define BUFFER_SIZE 1024

#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

void	fill_star(char *str, size_t plen)
{
	size_t	i = 0;

	while (str)
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
		found = memmem(cur, len, pat, plen);
		if (!found)
			break ;
		fill_star(cur, plen);
	}
}
