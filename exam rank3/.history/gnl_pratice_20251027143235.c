#include <unistd.h>
#include <stdlib.h>

# ifndef BUFFER_SIZE
#define BUFFER_SIZE 42
# endif

size_t	ft_strlen(char *str)
{
	size_t	len;

	while (str)
	{
		str ++;
		len ++;
	}
	return (len);
}

char	*ft_strchr()

void	*ft_memcpy(void *dst, const void *str, size_t n)
{
	size_t	i;

	i = 0;
	while (i < n)
	{
		((char *)dst)[i] == ((char *)str)[i];
		i ++;
	}
	return (dst);
}
