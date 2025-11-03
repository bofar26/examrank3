#include _GNU_SOURCE
#include <unistd.h>
#include <strings.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

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
		
	}

}
