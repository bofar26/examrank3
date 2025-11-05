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
		return (str + i);
	return (NULL);
}

void	*ft_memcpy(void *dst, const void *str, size_t n)
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
	size_t	len1;
	char	*tmp;

	len1 = *s1 ? ft_strlen(*s1) : 0;
	tmp = (char *)malloc(len1 + n);
	if (!tmp)
		return (0);
	
}
