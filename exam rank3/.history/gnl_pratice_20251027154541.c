#include <unistd.h>
#include <stdlib.h>

#ifndef BUFFER_SIZE
#define BUFFER_SIZE 42
#endif

size_t	ft_strlen(char *str)
{
	size_t	len;

	len = 0;
	while(str)
	{
		str ++;
		len ++;
	}
	return (len);
}

char	*ft_strchr(char *str, int c)
{
	int	i;

	i = 0;
	while (str && str[i] != c)
		i ++;
	if (str && str[i] == c)
		return (str + i);
	return (NULL);
}

void	*ft_memcpy(void *dst, const void *str, size_t n)
{
	size_t	i;

	i = 0;
	while (i < n)
	{
		((char *)dst)[i] = ((char *)str)
	}
}
