#include <stdlib.h>
#include <unistd.h>

# ifndef BUFFER_SIZE
#define BUFFER_SIZE 42
# endif

static int	ft_strlen(char *str)
{
	int	len;

	len = 0;
	while (str[len] != '\0')
		len ++;
	return (len);
}

static char	*ft_memcopy(char *dest, char *str, int n)
{
	int	i;

	i = 0;
	if (!dest || !str)
		return (NULL);
	while (i < n)
	{
		dest[i] = str[i];
		i ++;
	}
	return (dest);
}

char	*gnl(int fd)
{
	
}

