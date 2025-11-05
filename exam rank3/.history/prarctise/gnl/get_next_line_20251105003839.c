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
	if (*s1)
		ft_memcpy(tmp,*s1, len1);
	if (s2 && n)
		ft_memcpy(tmp + len1, s2, n);
	tmp[len1 + n] = '\0';
	free(*s1);
	*s1 = tmp;
	return (1);
}

void	shift_left(char *b, size_t from)
{
	size_t	i = 0;

	while (b[from + i])
	{
		b[i] = b[from + i];
		i ++;
	}
	b[i] = '\0';
}

char	get_next_line(int fd)
{
	char	b[BUFFER_SIZE + 1];
	char	*line;
	char	*nl;
	ssize_t	r;

	if (fd < 0 || BUFFER_SIZE <= 0)
		return (1);
	line = NULL;
	while (1)
	{
		nl = ft_strchr(b, '\n');
		if (nl)
		{
			if (!str_append_mem())
		}
	}
}

