# main.c の解説
## ソケットを作る
最初にソケット（通信の口）を作る。ソケットを読み書きすることで通信を実現する。
```c
int rsock
rsock = socket(AF_INET, SOCK_STREAM, 0);
```
第1引数の「AF_INET」はIPv4による接続を表し、第2引数の「SOCK_STREAM」はバイトストリーム形式の通信を表す。

## ソケットにアドレスを割り当てる
作成したソケットにアドレスを割り当てます。「ソケットに名前を付ける」とイメージすると良い。
```c
struct sockaddr_in addr;
 
/* socket setting */
addr.sin_family      = AF_INET;
addr.sin_port        = htons(8080);
addr.sin_addr.s_addr = INADDR_ANY;
 
/* binding socket */    
bind(rsock, (struct sockaddr *)&addr, sizeof(addr));
```
割り当てる具体的な情報は、sockaddr_in構造体に定義。今回はIPv4で8080番ポートを指定。アドレスは特に指定しないのでINADDR_ANY。

## 接続を待ち受ける
bindしたソケットに対してlistenで接続を待つ。第2引数は接続待ちキューの最大長だが、適当に5を指定。
```c
listen(rsock, 5);
```

## 接続を受け付ける
接続要求に対してacceptで受け付ける。acceptの戻り値として接続済みのソケットが返ってくる。
```c
int wsock;
int len;
struct sockaddr_in client;
 
len = sizeof(client);
wsock = accept(rsock, (struct sockaddr *)&client, &len);
```
このとき、第2引数のclientには接続元のアドレス情報が格納される。

## データを書き込む
acceptで受け取ったソケットに対してデータを書き込む。今回はどんな接続に対しても「HTTP1.1 200 OK」を返す。
```c
write(wsock, "HTTP1.1 200 OK", 14);
```
これで、リクエストに対して返事を返すことができる。

# コンパイル、httpサーバ起動
```c
# gcc main.c
# ./a.out
```

# 動作確認
## ブラウザでアクセス
ブラウザで`http://<server-ip>:8010`にアクセスしhttpサーバにリクエストを送る。

## 開発者ツールでレスポンスを確認
### Chromeの場合
![devtools_chrome](https://github.com/mitty1293/img/blob/main/httpserver/devtools_chrome.png)

### Firefoxの場合
![devtools_firfox](https://github.com/mitty1293/img/blob/main/httpserver/devtools_firefox.png)