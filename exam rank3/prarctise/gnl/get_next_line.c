#include "get_next_line.h"

size_t	ft_strlen(char *str)
{
	size_t	len = 0;

	while (str && str[len])
		len ++;
	return (len);
}

char	*ft_strchr(char *str, int c)
{
	int	i = 0;

	while (str && str[i] && str[i] != (char)c)
		i ++;
	if (str && str[i] && str[i] == (char)c)
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
	tmp = malloc(len1 + n + 1);
	if (!tmp)
		return (0);
	if (*s1)
		ft_memcpy(tmp, *s1, len1);
	if (s2 && n)
		ft_memcpy(tmp + len1, s2, n);
	tmp[len1 + n] = '\0';
	free(*s1);
	*s1 = tmp;
	return (1);
}

void	shift_left(char *b, int from)
{
	int	i = 0;

	while (b[i + from])
	{
		b[i] = b[i + from];
		i ++;
	}
	b[i] = '\0';
}

char	*get_next_line(int fd)
{
	static char	b[BUFFER_SIZE + 1];
	char	*line;
	char	*nl;
	ssize_t	r;

	if (fd < 0 || BUFFER_SIZE <= 0)
		return (NULL);
	line = NULL;
	while (1)
	{
		nl = ft_strchr(b, '\n');
		if (nl)
		{
			if (!str_append_mem(&line, b, nl - b + 1))
				return (free(line), NULL);
			shift_left(b, nl- b + 1);
			return (line);
		}
		if (b[0] && !str_append_mem(&line, b, ft_strlen(b)))
			return (free(line), NULL);
		b[0] = '\0';
		r = read(fd, b, BUFFER_SIZE);
		if (r < 0)
			return (free(line), NULL);
		if (r == 0)
			return ((!line || !*line) ? (free(line), NULL) : line);
		b[r] = '\0';
	}
}
/*
#include <stdio.h>
#include <fcntl.h>

int	main(int argc, char **argv)
{
	char	*line;
	int	fd;
	int	i = 1;
	char	*file;

	if (argc < 2 || !*argv[1])
		return (1);
	file = argv[1];
	fd = open(file, O_RDONLY);
	if (fd < 0)
		return (1);
	while ((line = get_next_line(fd)) != NULL)
	{
		printf("line %d %s", i, line);
		free(line);
		i ++;
	}
	free(line);
	return (0);
}*/
