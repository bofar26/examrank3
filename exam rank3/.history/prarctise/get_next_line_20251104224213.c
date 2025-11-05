#include "get_next_line.h"

size_t	ft_strlen(char *str)
{
	size_t	i=0;

	while (str && str[i])
		i ++;
	return (i);
}

char	*
