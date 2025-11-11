#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

size_t	ft_strlen(char *str)
{
	size_t	len = 0;

	while (str && str[len])
		len ++;
	return (len);
}

void	dfs(char *str, size_t n, size_t depth, char *path, char *used)
{
	size_t	i = 0;

	if (depth == n)
	{
		path[n] = '\0';
		puts(path);
		return ;
	}
	while (i < n)
	{
		if (!used[i])
		{
			used[i] = 1;
			path[depth] = str[i];
			dfs(str, n, depth + 1, path, used);
			used[i] = 0;
		}
		i ++;
	}
}

void	selection_sort(char *str, size_t n)
{
	size_t	i,j,m;
	char	t;

	for (i = 0; i + 1 < n; i++)
	{
		m = i;
		for (j = i + 1; j < n; j++)
			if (str[j] < str[m])
				m = j;
		if (m != i)
		{
			t = str[i];
			str[i] = str[m];
			str[m] = t;
		}
	}
}

int	main(int argc, char **argv)
{
	char	*str;
	char	*path;
	char	*used;
	size_t	n;
	size_t	i = 0;

	if (argc != 2 || !*argv[1])
	{
		write(1, "\n", 1);
		return (1);
	}
	n = ft_strlen(argv[1]);
	str = (char *)malloc(n + 1);
	path = (char *)malloc(n + 1);
	used = (char *)calloc(1, n + 1);
	if (!str || !path || !used)
		return (1);
	while (i < n)
	{
		str[i] = argv[1][i];
		i ++;
	}
	selection_sort(str, n);
	dfs(str, n, 0, path, used);
	free(str);
	free(path);
	free(used);
	return (0);
}
