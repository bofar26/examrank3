#include <stdlib.h>
#include <stdio.h>

void	put_words(int *arr, int n, int *pick, int *found)
{
	int	i;
	int	first = 1;

	for(i = 0; i < n; i++)
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

void	dfs(int *arr, int n, int index, int sum, int target, int *pick, int *found)
{
	if (index == n)
	{
		if (sum == target)
			put_words(arr, n, pick, found);
		return ;
	}
	pick[index] = 0;
	dfs(arr, n, index + 1, sum, target, pick, found);
	pick[index] = 1;
	dfs(arr, n, index + 1, sum + arr[index], target, pick, found);
}

int	main(int argc, char **argv)
{
	int	n;
	int	*arr;
	int	*pick;
	int	target;
	int	found;

	if (argc < 2 || !*argv[1])
		return (1);
	found = 0;
	n = argc - 2;
	target = atoi(argv[1]);
	arr = (int *)malloc(n * sizeof(int));
	pick = (int *)calloc(n, sizeof(int));
	if (!arr || !pick)
		return (1);
	for (int i = 0; i < n; i ++)
		arr[i] = atoi(argv[i + 2]);
	dfs(arr, n, 0, 0, target, pick, &found);
	free(arr);
	free(pick);
	if (found == 0)
		printf("\n");
	return (0);
}
