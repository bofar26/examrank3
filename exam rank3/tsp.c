// tsp.c — 极简回溯版（n <= 11）
// 编译：cc -O2 tsp.c -lm -o tsp
#include <stdio.h>
#include <math.h>
#include <float.h>

static int   n;
static float X[12], Y[12];
static float best;

static inline float dist(int a, int b) {
    float dx = X[a] - X[b], dy = Y[a] - Y[b];
    return sqrtf(dx*dx + dy*dy);
}

static void dfs(int last, int used, int cnt, float len) {
    if (len >= best) return;                 // 剪枝
    if (cnt == n) {                          // 全部到过 -> 回到 0
        float total = len + dist(last, 0);
        if (total < best) best = total;
        return;
    }
    for (int i = 1; i < n; ++i) {            // 0 号固定为起点
        if (!(used & (1 << i))) {
            dfs(i, used | (1 << i), cnt + 1, len + dist(last, i));
        }
    }
}

int main(void) {
    float x, y;
    n = 0;
    while (n < 12 && fscanf(stdin, " %f , %f", &x, &y) == 2) {
        X[n] = x; Y[n] = y; ++n;
    }
    if (n <= 1) { fprintf(stdout, "0.00\n"); return 0; }

    best = FLT_MAX;
    dfs(0, 1<<0, 1, 0.0f);
    fprintf(stdout, "%.2f\n", best);
    return 0;
}
