/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   permutations.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mipang <mipang@student.42.fr>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/15 10:13:05 by mipang            #+#    #+#             */
/*   Updated: 2025/11/06 00:33:04 by mipang           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>
#include <stdlib.h>

size_t	ft_strlen(char *str)
{
	size_t	len = 0;

	while (str && str[len])
		len ++;
	return (len);
}

static void	put_words(char *path, int n)
{
	int	i;

	i = 0;
	while (i < n)
	{
		write(1, &path[i], 1);
		i ++;
	}
	write(1, "\n", 1);
}

static void	dfs(char *arr, int n, int depth, char *path, char *used)
{
	int	i;

	i = 0;
	if (depth == n)
	{
		put_words(path, n);
		return ;
	}
	while (i < n)
	{
		if (!used[i])
		{
			used[i] = 1;
			path[depth] = arr[i];
			dfs(arr, n, depth + 1, path, used);
			used[i] = 0;
		}
		i ++;
	}
}

static void	selection_sort(char *a, int n)
{
	int i, j, m;
	char t;

	for (i = 0; i + 1 < n; i++)
	{
		m = i;
		for (j = i + 1; j < n; j++)
			if (a[j] < a[m])
				m = j;
		if (m != i)
		{
			t = a[i];
			a[i] = a[m];
			a[m] = t;
		}
	}
}

int	main(int argc, char **argv)
{
	char	*path;
	char	*used;
	char	*arr;
	int	n;
	int	i;

	if (argc < 2 || !argv[1][0])
	{
		printf("\n");
		return (1);
	}
	n = ft_strlen(argv[1]);
	path = (char *)malloc(n + 1);
	used = (char *)calloc(1,n + 1);
	arr = (char *)malloc(n + 1);
	if (!arr || !path || !used)
	{
		free(arr);
		free(path);
		free(used);
		return (1);
	}
	i = 0;
	while (i < n)
	{
		arr[i] = argv[1][i];
		i ++;
	}
	dfs(arr, n, 0, path, used);
	free(arr);
	free(path);
	free(used);
	return (0);
}

