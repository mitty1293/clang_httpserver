# main.c について
## 1. ソケットを作る
最初にソケット（通信の口）を作る。ソケットを読み書きすることで通信を実現する。
第1引数の「AF_INET」はIPv4による接続を表し、第2引数の「SOCK_STREAM」はバイトストリーム形式の通信を表す。
```c
int rsock
rsock = socket(AF_INET, SOCK_STREAM, 0);
```
### `int socket(int domain, int type, int protocol)`
OSにソケットの作成を依頼するシステムコール。
各ソケットの識別子となるファイルディスクリプターを返す。
- domain :
    - 通信を行なうドメインを指定する。どのAddress family(protocol familyと同義と考えて良い)を通信に使用するかを指定する。
    - AF_INET
        - IPv4 インターネットプロトコル
- type :
    - 通信方式を指定する。
    - SOCK_STREAM
        - 順序性と信頼性があり、双方向の、接続されたbyte streamを提供する。
- protocol :
    - ソケットによって使用される固有のプロトコルを指定する。通常それぞれのソケットは、与えられたAddress familyの種類ごとに一つのプロトコルのみをサポートする。その場合は protocol に 0 を指定できる。
### Address family
目的の通信をするために必要な通信プロトコルをひとまとめにしたもの
Address familyを指定することで、システムに与えられたアドレスをどのように解釈するかを指示する。これらのファミリーは <sys/socket.h> に定義されている。
- AF_INET
    - AF_INETを指定した場合、ローカルプロセスとリモートホスト上で動作するプロセス間のソケット通信を提供する。IPv4 インターネットプロトコルを示す。
- AF_UNIX
    - AF_UNIXを指定した場合、同じ OS 上で動作するプロセス間のソケット通信を提供する。

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
    - Address familyを指定する。
    - AF_INET
        - IPv4 インターネットプロトコル
- sin_port:
    - ポート番号をnetwork byte orderで指定する。
    - network byte order
        - ネットワークを通じて伝送する際に、各バイトをどのような順番で記録・伝送するかを定めた順序。TCP/IPでは。TCP/IPでは慣習的に最上位から下位バイトに向けて順に記述するbig endianが用いられる。network byte orderと対比して、各コンピュータ固有のバイト順のことを「host byte order」と呼ぶ。
- sin_addr:
    - IPアドレスを指定する。
    - `struct in_addr`は`/usr/include/netinet/in.h`に以下のように定義されている。<br>
        in_addr構造体は、in_addr_t型のs_addrしかメンバに持たない構造体である。
        ```c
        struct in_addr { in_addr_t s_addr; };
        ```
    - `in_addr_t`は`/usr/include/netinet/in.h`に以下のように定義されている。<br>
        32bitの整数のIPアドレスを格納するだけなので、ただのuint32_tである。
        ```c
        typedef uint32_t in_addr_t;
        ```
### `uint16_t htons(uint16_t)`
`/usr/include/netinet/in.h`に定義されている。<br>
16bit符号なし整数をhost byte orderで受取り、network byte orderで返す。<br>
host byte orderのIPポート番号をnetwork byte orderのIPポート番号に変換することができる。
### `INADDR_ANY`
`/usr/include/netinet/in.h`に以下のように定義されている。<br>
```c
#define INADDR_ANY        ((in_addr_t) 0x00000000)
```
Cで、IPの処理に用いられるマクロの一つ。バインドに用いる任意のアドレスを持つ。<br>
一般には0.0.0.0が定義され、全てのローカルインターフェイスにバインドされうることを意味する。<br>
例えばサーバープログラムを作る場合、どのアドレスからの接続でも受け入れるように待ち受ける(ことが多い)、つまり接続を受けるネットワークインターフェイスがどれでもいいので、bind()の引数にINADDR_ANYが指定される。
### `int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)`
ソケットに名前をつける。<br>
`socket`でソケットが作成されたとき、そのソケットは名前空間 (Address family) に存在するが、アドレスは割り当てられていない。<br>
`bind()`は、ファイルディスクリプター`sockfd`で参照されるソケットに`addr`で指定されたアドレスを割り当てる。`addrlen`には`addr`が指す構造体のサイズをバイト単位で指定する。<br>
成功した場合はゼロ、エラー時には-1を返す。
- sockfd:
    - 任意のソケットを示すファイルディスクリプタ。<br>
    socket()でソケット作成時に返されるファイルディスクリプタ。
- addr:
    - ソケットに割り当てるアドレス。
    - `struct sockaddr`は`/usr/include/sys/socket.h`に以下のように定義されている。<br>
    addr に渡される構造体へのポインターをキャストし、 コンパイラの警告メッセージを抑えるためだけに存在する。<br>
    &でsockaddr_in構造体のアドレスを参照し、sockaddr構造体へキャストしている<br>
    参考：https://teratail.com/questions/210977
        ```c
        struct sockaddr {             
            sa_family_t sa_family;
            char sa_data[14];
        };
        ```
- addrlen:
    - addrの指す構造体のサイズ。
    - sizeof()
        - メモリサイズを返す。

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
