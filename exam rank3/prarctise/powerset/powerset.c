#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

void	put_words(int *arr, int n, int *pick, int *found)
{
	int	i = 0;
	int	first = 1;

	for (i = 0; i < n; i ++)
	{
		if (pick[i])
		{
			if (first == 0)
				printf(" ");
			printf("%d", arr[i]);
			first = 0;
		}
	}
	printf("\n");
	*found = 1;
}

void	dfs(int	*arr, int n, int index, int sum, int target, int *pick, int *found)
{
	if (index == n)
	{
		if (sum == target)
			put_words(arr, n, pick, found);
		return ;
	}
	pick[index] = 0;
	dfs(arr, n , index + 1, sum, target, pick, found);
	pick[index] = 1;
	dfs(arr, n, index + 1, sum + arr[index], target, pick, found);
}
int	main(int argc, char **argv)
{
	int	*arr;
	int	*pick;
	int	n;
	int	target;
	int found = 0;

	if (argc < 2 || !*argv[1])
	{
		printf("\n");
		return (1);
	}
	n = argc - 2;
	target = atoi(argv[1]);
	arr = (int *)malloc(sizeof(int) * n);
	pick = (int *)calloc(sizeof(int), n);
	if (!arr || !pick)
	{
		printf("\n");
		return (1);
	}
	int i = 0;
	while (i < n)
	{
		arr[i] = atoi(argv[i + 2]);
		i ++;
	}
	dfs(arr, n, 0, 0, target, pick, &found);
	free(arr);
	free(pick);
	if (found == 0)
		return (printf("\n"), 0);
	return (0);
}
