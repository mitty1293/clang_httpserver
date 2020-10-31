# main.c の解説
## ソケットを作る
```c
int rsock
rsock = socket(AF_INET, SOCK_STREAM, 0);
```