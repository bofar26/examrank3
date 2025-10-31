#include <unistd.h>
#include <stdlib.h>
#ifndef BUFFER_SIZE
#define BUFFER_SIZE = 42
#endif

size_t	ft_strlen(char* str)
{
	size_t	len = 0;

	while (str)
	{
		str ++;
		len ++;
	}
	return (len);
}

char*	ft_strchr(char *str, int c)
{
	int	i;

	i = 0;
	while (str && str[i] != c)
		i ++;
	if (str && str[i] == c)
		return (str + i);
	return (NULL);
}

void	*ft_memecpy(void *dst, const void *str, size_t n)
{
	size_t	i = 0;

	while (i < n)
	{
		((char *)dst)[i] = ((char *)str)[i];
		i ++;
	}
	return (dst);
}

int	str_append_mem(char **s1, char *s2, size_t n)
{
	size_t len1;
	char	*tmp;

	len1 = *s1 ? ft_strlen(*s1) : 0;
	tmp = malloc(len1 + n + 1);
	if (!tmp)
		return (NULL);
	if (*s1)
		ft_memecpy(tmp, *s1, len1);
	if (s2 && n)
		ft_memcpy(tmp + len1, s2, n);
	tmp[len1 + n] = '\0';
	free(*s1);
	*s1 = tmp;
	return (1);
}

void	shift_left(char *b, size_t from)
{
	size_t i;

	i = 0;
	while (b[from + i])
}
