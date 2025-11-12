#include <stdio.h>
#include <stdlib.h>

void	put_words(int *pos, int n)
{
	int	i;

	for (i = 0; i < n; i++)
	{
		if (i)
			fprintf(stdout, " ");
		fprintf(stdout, "%d", pos[i]);
	}
	fprintf(stdout, "\n");
}

void	dfs(int *pos, int col, int n, int *used_col, int *used_d1, int *used_d2)
{
	int	row;
	int	d1, d2;

	if (col == n)
	{
		put_words(pos, n);
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
			dfs(pos, col + 1, n, used_col, used_d1, used_d2);
			used_col[row] = 0;
			used_d1[d1] = 0;
			used_d2[d2] = 0;
		}
	}
}

int	main(int argc, char **argv)
{
	if (argc != 2 || !*argv[1])
		return (1);
	int n = atoi(argv[1]);
	int	pos[n];
	int	used_col[n];
	int	used_d1[2 * n - 1];
	int	used_d2[2 * n - 1];
	for (int i = 0; i < n; i ++)
		used_col[i] = 0;
	for (int m = 0; m < 2*n - 1; m ++)
		used_d1[m] = used_d2[m] = 0;
	dfs(pos, 0, n, used_col, used_d1, used_d2);
	return (0);
}
