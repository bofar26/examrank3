#include "get_next_line.h"

size_t	ft_strlen(char *str)
{
	size_t	i = 0;

	while (*str)
	{
		str ++;
		i ++;
	}
	return (i);
}

char	*ft_strchr(char *str, int c)
{
	int	i = 0;

	while (str && str[i] && str[i] != (char)c)
		i ++;
	if (str && str[i] == (char)c)
		return (str + i)
}
