#define _GNU_SOURCE
#define BUFFER_SIZE 1024
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>

void	*ft_memset(char *str, int word, size_t plen)
{
	char	*cur;
	size_t	i;

	i = 0;
	cur = str;
	while (i < plen)
	{
		cur[i] = word;
		i ++;
	}
	return (cur);
}

void	replace_all(char *buf, size_t len, char *pat, size_t plen)
{
	char	*cur;
	char	*found;

	cur = buf;
	while (len >= plen)
	{
		found = memmem(cur, len, pat, plen);
		if (!found)
			break ;
		ft_memset(cur, '*', plen);
		adv = (found + plen) - cur;
		cur += adv;
		len -= adv;
	}
}
