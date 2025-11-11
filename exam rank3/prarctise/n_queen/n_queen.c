#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

void	put_words(int *pos, int n, int *found)
{
	int i;

	for (i = 0; i < n; i ++)
	{
		if (i)
			fprintf(stdout, " ");
		fprintf(stdout, "%d", pos[i]);
	}
	fprintf(stdout, "\n");
	*found = 1;
}

void	dfs(int *pos, int col, int n, int *used_col, int *used_d1, int *used_d2, int *found)
{
	int	row;
	int	d1, d2;

	if (col == n)
	{
		put_words(pos, n, found);
		return ;
	}
	for (row = 0; row < n; row ++)
	{
		d1 = row + col;
		d2 = row - col + (n - 1);
		if (!used_col[row] && !used_d1[d1] && !used_d2[d2])
		{
			pos[col] = row;
			used_col[row] = 1;
			used_d1[d1] = 1;
			used_d2[d2] = 1;
			dfs(pos, col + 1, n, used_col, used_d1, used_d2, found);
			used_col[row] = 0;
			used_d1[d1] = 0;
			used_d2[d2] = 0;
		}
	}
}

int	main(int argc, char **argv)
{
	int	n;

	if (argc != 2 || !*argv[1])
		return (1);
	n = atoi(argv[1]);
	int	used_col[n];
	int	pos[n];
	int	used_d1[2 * n];
	int	used_d2[2 * n];
	int	found = 0;

	int i = 0;
	for(i = 0; i < n; i ++)
		used_col[i] = 0;
	for(int j = 0; j < 2 * n; j ++)
		used_d1[j] = used_d2[j] = 0;
	dfs(pos, 0, n, used_col, used_d1, used_d2, &found);
	if (found == 0)
		fprintf(stdout, "\n");
	return (0);
}
