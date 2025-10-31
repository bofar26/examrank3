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
	return (len)
}
