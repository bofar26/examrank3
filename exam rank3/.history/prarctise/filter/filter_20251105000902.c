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
	carry = 0;
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
		len = carry + r;
		replace_all(buf, len, pat, plen);
		if (len > keep)
		{
			if (write(1, buf, len - keep) < 0)
				return (perror("Error"), 1);
			memmove(buf, buf + len - keep, keep);
			carry = keep;
		}
		else
			carry = len;
		r = read(0, buf, BUFFER_SIZE + carry);
		if (r < 0)
		{
			free(buf);
			return (perror("Error"), 1);
		}
	}
	if (carry > 0)
	{
		replace_all(buf, len, pat, plen)
		if (write(1, buf, carry) < 0)
		{
			free(buf);
			return (perror("Error"), 1);
		}
	}
}
