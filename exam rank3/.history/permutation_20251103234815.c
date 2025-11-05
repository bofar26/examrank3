/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   permutation.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mipang <mipang@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-10-15 10:13:05 by mipang            #+#    #+#             */
/*   Updated: 2025-10-15 10:13:05 by mipang           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */
#include <stdio.h>
#include <stdlib.h>

static void	put_words(int *path, int n)
{
	int	i;
	int	first;

	i = 0;
	first = 1;
	while (i < n)
	{
		if (first == 0)
			printf(" ");
		printf("%d", path[i]);
		first = 0;
		i ++;
	}
	printf("\n");
}

static void	dfs(int *arr, int n, int depth, int *path, int *used)
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

int	main(int argc, char **argv)
{
	int	*path;
	int	*used;
	int	*arr;
	int	n;
	int	i;

	if (argc < 2)
		return (1);
	n = argc - 1;
	path = (int *)malloc(n * sizeof(int));
	used = (int *)calloc(n, sizeof(int));
	arr = (int *)malloc(n * sizeof(int));
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
		arr[i] = atoi(argv[i + 1]);
		i ++;
	}
	dfs(arr, n, 0, path, used);
	free(arr);
	free(path);
	free(used);
	return (0);
}

