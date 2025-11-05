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
	size_t	adv;

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

int	main(int argc, char **argv)
{
	char	*buf;
	char	*pat;
	size_t	len;
	size_t	plen;
	size_t	keep;
	size_t	carry;
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
	buf = (char *)malloc(BUFFER_SIZE + keep);
	if (!buf)
		return (perror("Error"), 1);
	r = read()
}
