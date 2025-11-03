#define _GNU_SOURCE
# define BUFFER_SIZE 1024
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

static void	fill_stars(char *found, size_t plen)
{
	size_t	i = 0;
	while (i < plen)
		found[i++] = '*';
}


static void	replace_all(char *buf, size_t len, const char *pat, size_t plen)
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
		ft_memset(found, '*', plen);
		adv = (found + plen) - cur;
		cur += adv;
		len -= adv;
	}
}

int	main(int argc, char **argv)
{
	char *buf;
	size_t	len;
	const char	*pat;
	size_t	plen;
	ssize_t	r;
	size_t	carry;
	size_t	keep;

	if (argc != 2 || !*argv[1])
		return (1);
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
		r = read(0, buf, BUFFER_SIZE + carry);
		if (r < 0)
		{
			free(buf);
			return (perror("Error"), 1);
		}
	}
	if (carry > 0)
	{
		replace_all(buf, carry, pat, plen);
		if (write(1, buf, carry) < 0)
		{
			free(buf);
			return(perror("Error"), 1);
		}
	}
	return (0);
}

