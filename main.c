#include <uefi.h>

int main(int argc, char **argv)
{
    FILE *file = fopen("\\config\\config.json", "r");
    if (!file)
    {
        printf("Null file\n");
    }
    else
    {
        char buffer[20] = {0};
        fread(buffer, 1, 20, file);
        printf("Read: %s\n", buffer);
    }
    sleep(10);
    return 0;
}
