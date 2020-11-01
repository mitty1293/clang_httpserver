# main.c について
## 1. ソケットを作る
最初にソケット（通信の口）を作る。ソケットを読み書きすることで通信を実現する。
第1引数の「AF_INET」はIPv4による接続を表し、第2引数の「SOCK_STREAM」はバイトストリーム形式の通信を表す。
```c
int rsock
rsock = socket(AF_INET, SOCK_STREAM, 0);
```
### `socket(int domain, int type, int protocol)`
OSにソケットの作成を依頼するシステムコール。
- domain :
    - 通信を行なうドメインを指定する。どのprotocol familyを通信に使用するかを指定する。これらのファミリーは <sys/socket.h> に定義されている。
    - AF_INET
        - IPv4 インターネットプロトコル
- type :
    - 通信方式を指定する。
    - SOCK_STREAM
        - 順序性と信頼性があり、双方向の、接続されたbyte streamを提供する。
- protocol :
    - ソケットによって使用される固有のプロトコルを指定する。通常それぞれの ソケットは、与えられたプロトコルファミリーの種類ごとに一つのプロトコルのみをサポートする。その場合は protocol に 0 を指定できる。

## 2. ソケットにアドレスを割り当てる
作成したソケットにアドレスを割り当てる。「ソケットに名前を付ける」とイメージすると良い。
割り当てる具体的な情報は、sockaddr_in構造体に定義。今回はIPv4で8080番ポートを指定。アドレスは特に指定しないのでINADDR_ANY。
```c
/* 構造体sockaddr_in型の変数addrを定義 */
struct sockaddr_in addr;
 
/* socket setting */
addr.sin_family      = AF_INET;
addr.sin_port        = htons(8080);
addr.sin_addr.s_addr = INADDR_ANY;
 
/* binding socket */    
bind(rsock, (struct sockaddr *)&addr, sizeof(addr));
```
### `struct sockaddr_in`
ソケットプログラミングで使われる構造体。`/usr/include/netinet/in.h`に以下のように定義されている。
```c
struct sockaddr_in {
        sa_family_t sin_family;
        in_port_t sin_port;
        struct in_addr sin_addr;
        uint8_t sin_zero[8];
};
```
- sin_family:
- sin_port:
    - ポート番号。
- sin_addr:
    - IPアドレス。

また、`struct in_addr`は`/usr/include/netinet/in.h`に以下のように定義されている。<br>
in_addr構造体は、in_addr_t型のs_addrしかメンバに持たない構造体である。
```c
struct in_addr { in_addr_t s_addr; };
```
また、`in_addr_t`は`/usr/include/netinet/in.h`に以下のように定義されている。<br>
32bitの整数のIPアドレスを格納するだけなので、ただのuint32_tである。
```c
typedef uint32_t in_addr_t;
```
## 3. 接続を待ち受ける
bindしたソケットに対してlistenで接続を待つ。第2引数は接続待ちキューの最大長だが、適当に5を指定。
```c
listen(rsock, 5);
```

## 4. 接続を受け付ける
接続要求に対してacceptで受け付ける。acceptの戻り値として接続済みのソケットが返ってくる。
このとき、第2引数のclientには接続元のアドレス情報が格納される。
```c
int wsock;
int len;
struct sockaddr_in client;
 
len = sizeof(client);
wsock = accept(rsock, (struct sockaddr *)&client, &len);
```

## 5. データを書き込む
acceptで受け取ったソケットに対してデータを書き込む。今回はどんな接続に対しても「HTTP1.1 200 OK」を返す。
これで、リクエストに対して返事を返すことができる。
```c
write(wsock, "HTTP1.1 200 OK", 14);
```

# 動作確認
## コンパイル、httpサーバ起動
```c
# gcc main.c
# ./a.out
```

## ブラウザでアクセス
ブラウザで`http://<server-ip>:8010`にアクセスしhttpサーバにリクエストを送る。

## 開発者ツールでレスポンスを確認
### Chromeの場合
![devtools_chrome](https://github.com/mitty1293/img/blob/main/httpserver/devtools_chrome.png)

### Firefoxの場合
![devtools_firfox](https://github.com/mitty1293/img/blob/main/httpserver/devtools_firefox.png)
