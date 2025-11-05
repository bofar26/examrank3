#include "get_next_line.h"

size_t	ft_strlen(char *str)
{
	size_t	i=0;

	while (str && str[i])
		i ++;
	return (i);
}

char	*ft_strchr(char	*str, int c)
{
	int	i;

	while (str && str[i] != c)
		i ++;
	if (str && str[i] == c)
		return (str + i);
	return (NULL);
}

void	*ft_memcpy(void *dst, const void *str, size_t n)
{
	size_t i = 0;

	while (i < n)
	{
		(char *)dst[i] = (char *)str[i];
		i ++;
	}
	return (dst);
}
