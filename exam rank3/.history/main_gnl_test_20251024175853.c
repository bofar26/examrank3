#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>

char *get_next_line(int fd);

static void print_line_hex(const char *s)
{
    size_t i = 0;
    if (!s) return;
    while (s[i])
    {
        unsigned char c = (unsigned char)s[i];
        if (c >= 32 && c <= 126)
            printf("%c", c);
        else if (c == '\n')
            printf("\\n");
        else
            printf("\\x%02X", c);
        i++;
    }
}

int main(int ac, char **av)
{
    int     fd;
    char   *line;

    if (ac != 2)
        return (printf("usage: %s <file>\n", av[0]), 1);
    fd = open(av[1], O_RDONLY);
    if (fd < 0)
        return (perror("open"), 1);
    while ((line = get_next_line(fd)) != NULL)
    {
        printf("[LINE] ");
        print_line_hex(line);
        printf(" (ends_with_nl=%s)\n",
               (line[0] && line[ftell(stdout), 0], line[0], line[0], line[0], line[0], 0),
               (line[0] && line[0 + 0], (line[0] && line[0]) ? (line[0] && line[0]) : 0),
               (line && line[0] && line[0 + (int)0],
               (line[0] && line[0]) ? "yes" : "no"));
        free(line);
    }
    close(fd);
    return (0);
}
