#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUFFER_SIZE
# define BUFFER_SIZE 42
# endif

static int	ft_strlen(char *str)
{
	int	len;

	len = 0;
	while (str && str[len] != '\0')
		len ++;
	return (len);
}

static char *ft_memcpy(char *dest, const char *src, int n)
{
	int	i;
	i = 0;
	if (!dest || !src)
		return (NULL);
	while (i < n)
	{
		dest[i] = src[i];
		i ++;
	}
	return (dest);
}


static void shift_right_to_left(char *buf, int start)
{
	int tail = 0;
	while (buf[start + tail] != '\0')
		tail++;
	memmove(buf, buf + start, (size_t)tail + 1);
}

static int	append_mem(char **line, const char *buf, int n)
{
	int	len1;
	char	*new_str;

	if (*line != NULL)
		len1 = ft_strlen(*line);
	else
		len1 = 0;
	new_str = malloc(len1 + n + 1);
	if (!new_str)
		return (0);
	if (*line != NULL)
		ft_memcpy(new_str, *line, len1);
	if (buf != NULL && n > 0)
		ft_memcpy(new_str + len1, buf, n);
	new_str[len1 + n] = '\0';
	free(*line);
	*line = new_str;
	return (1);
}

char	*gnl(int fd)
{
	static char	buf[BUFFER_SIZE + 1];
	char	*line;
	char	*nl_ptr;
	ssize_t	bytes;
	int	i;

	if (fd < 0 || BUFFER_SIZE < 0)
		return (NULL);
	line = NULL;
	while (1)
	{
		nl_ptr = NULL;
		i = 0;
		while (buf[i] != '\0')
		{
			if (buf[i] == '\n')
			{
				nl_ptr = buf + i;
				break;
			}
			i ++;
		}
		if (nl_ptr != NULL)
		{
			if (!append_mem(&line, buf, nl_ptr - buf + 1))
				return (free(line), NULL);
			shift_right_to_left(buf, (int)((nl_ptr - buf) + 1));
			return (line);
		}
		if (buf[0] != '\0')
		{
        	if (!append_mem(&line, buf, ft_strlen(buf)))
            	return (free(line), NULL);
       		buf[0] = '\0';
    	}
		bytes = read(fd, buf, BUFFER_SIZE);
		if (bytes <= 0)
		{
			if (bytes < 0)
			{
				free(line);
				line = NULL;
			}
			else
				buf[0] = '\0';
			return (line);
		}
		buf[bytes] = '\0';
	}
}


/*
#include <fcntl.h>
#include <stdio.h>

int main(int ac, char **av)
{
    int fd;
    char *line;

    if (ac == 2)
        fd = open(av[1], O_RDONLY);
    else
        fd = 0;

    while ((line = gnl(fd)))
    {
        printf("%s", line);
        free(line);
    }
    if (ac == 2)
        close(fd);
    return 0;
}
	*/
