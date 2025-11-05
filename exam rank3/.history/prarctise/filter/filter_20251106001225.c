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
		found = memmem(cur, len, pat, plen);
		if (!found)
			break ;
		fill_stars(found, plen);
		adv = (found + plen) - cur;
		cur += adv;
		len -= adv;
	}
}

int	main(int argc, char **argv)
{
	char	*buf;
	char	*pat;
	size_t	len;
	size_t	plen;
	size_t	carry;
	size_t	keep;
	ssize_t	r;

	if (argc != 2 || !argv[1][0])
		return (1);
	pat = argv[1];
	plen = strlen(pat);
	carry = 0;
	if (plen > 1)
		keep = plen -1;
	else
		keep = 0;
	buf = malloc(BUFFER_SIZE + keep);
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
		len = carry + r;
		replace_all(buf, len, pat, plen);
		if (len > keep)
		{
			if (write(1, buf, len - keep) < 0)
			{
				free(buf);
				return (perror("Error"), 1);
			}
			memmove(buf, buf + len - keep, keep);
			carry = keep;
		}
		else
			carry = len;
		r = read(0, buf + carry, BUFFER_SIZE);
		if (r < 0)
		{
			free(buf);
			return (perror("Error"), 1);
		}
	}
	if (carry > 0)
	{
		
	}
}

