/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   powerset_pratice.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mipang <mipang@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-10-14 20:28:04 by mipang            #+#    #+#             */
/*   Updated: 2025-10-14 20:28:04 by mipang           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>

static void	put_words(const int *a, int n, int *pick)
{
	int	first;
	int	i;

	i = 0;
	first = 1;
	while (i < n)
	{
		if (pick[i])
		{
			if (first == 0)
				printf(" ");
			printf("%d", a[i]);
			first = 0;
		}
		i ++;
	}
	printf("\n");
}

static void	dfs(const int *a, int n, int index, int sum, int target, int *pick)
{
	if (index == n)
	{
		if (sum == target)
			put_words(a, n, pick);
		return ;
	}
	pick[index] = 0;
	dfs(a, n, index + 1, sum, target, pick);
	pick[index] = 1;
	dfs(a, n, index + 1, sum + a[index], target, pick);
}

int	main(int argc, char **argv)
{
	int	*pick;
	int	*a;
	int	n;
	int	i;
	int	target;
	int	sum;

	if (argc < 2)
		return 1;
	n = argc - 2;
	target = atoi(argv[1]);
	if (n <= 0)
	{
		if (target == 0)
			printf("\n");
		return (0);
	}
	a = (int *)malloc(n * sizeof(int));
	pick = (int *)calloc(n, sizeof(int));
	if (!a || !pick)
	{
		free(a);
		free(pick);
		return (1);
	}
	i = 0;
	while (i < n)
	{
		a[i] = atoi(argv[i + 2]);
		i ++;
	}
	dfs(a, n, 0, 0, target, pick);
	free(a);
	free(pick);
	return (0);
}
