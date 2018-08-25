---
layout: slide
title: 世界最悪のログイン処理コードを救う
description: 世界最悪のログイン処理コードを救えない
theme: night
---

# 世界最悪の<br>ログイン処理コードを救う
matsub.rk @PMOB



## 世界最悪のログイン処理コード
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="600px">


## 世の評判
- クライアント上のJavaScriptで書かれている
    - ログイン処理の全容がバレバレ
- Cookieに書き込む認証情報がザル過ぎる
- 任意のSQLを実行できてしまう
- パスワードを平文で保存している

> すごく…セキュリティーホールです…


# ほんとぉ？



<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="600px">



## セキュリティホールっぽいもの
- `apiService.sql`
- `$("#password").val()`
- `$.cookie('loggedin', 'yes', {expires: 1})`


## シバいていきましょう



## `apiService.sql`
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="600px">


## `apiService.sql`
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="400px">

`apiService` クラスの静的メソッド？


## `apiService.sql`
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="400px">

- 非同期処理を使っていない
    - **DBにリクエストを送ってはいない** ことが察せられます
- もっと上の部分で、クライアントにストアされているのでは


## ここで疑問
- このログイン処理はいつ呼ばれるのか？


### このログイン処理はいつ呼ばれるのか？
1. 踏み台ユーザーとしてログイン（すごくセキュア）
    - このときユーザー情報をストア
2. 作業ユーザーに切り替える際にここが呼ばれる


### ってことにしてください



### `$("#password").val()`
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-img.png" height="600px">


### この `$` ってなんだ


### jQuery?


### NO


### jQuery
jQueryの `$` は `jQuery` プロトタイプのショートカット

```javascript
>> jQuery === $
true
```


なので `$` というシンボル自体は好きに使える

```javascript
>> function $(x) { return x*2 }
>> $(10)
20
```


### ということは
`$("#password").val()` をいじろう

```javascript
class $ {
    constructor (domQuery) {
    }

    val () {
    }
}
```


### constructor
普通にDOMエレメントを持っておきましょう。

```javascript
class $ {
    constructor (domQuery) {
        this.elm = document.querySelector(domQuery)
    }
}
```


### val
バックエンドからハッシュ値をもらう。

```javascript
class $ {
    val () {
        hashedValue = fetch(`/api/hash/${this.elm.value}`)
        return hashedValue
    }
}
```


### これで
```javascript
account.password === password
```

がセキュアになる可能性が生まれた


### いや待て
`fetch` ってPromiseなので、値がそのまま帰ってこないな...


### うっ頭が...
```javascript
class $ {
    val () {
        var result = {value: undefined}
        fetch(`/api/hash/${this.elm.value}`)
            .then(function(response) {
                result.value = response.json().value
            })
        return result
    }
}
```

さっきのapiServiceも同様でしたね


### あとそういえば
class使えないじゃん

最悪コードの中でnewが呼ばれていないので、  
このままではエラーになってしまいます。


### 解決
```javascript
function $(domQuery) { return new _$(domQuery) }
class _$ {
    ...
}
```



### 最後じゃよ
`$.cookie('loggedin', 'yes', {expires: 1})`


同様に `$` の中でバックエンドを叩いて

apiServiceで取れるものと同じ文字列を

バックエンドからもらいましょう


```javascript
$.cookie = async function(key, value, option) {
    const response = await fetch(`/api/jwt/${value}`)
    document.cookie = `${key}=${response.text()}`
}
```
`{expires: 1}` は何だかわからなかったので放置



## 結果
```javascript
class _$ {
    constructor (domQuery) {
        this.elm = document.querySelector(domQuery)
    }

    val () {
        var result = {value: undefined}
        fetch(`/api/hash/${this.elm.value}`)
            .then(function(response) {
                result.value = response.json().value
            })
        return result
    }

    click (cb) {
        this.elm.addEventListener('click', cb)
    }
}

function $(domQuery) { return new _$(domQuery) }
$.cookie = async function(key, value, option) {
    const response = await fetch(`/api/jwt/${value}`)
    document.cookie = `${key}=${response.text()}`
}
```


あとバックエンドの複雑な処理がひつよう


クソを救おうとしたら、クソを包んだなにかができた



## 最後に
<img src="{{ site.baseurl }}/assets/images/LT-worst-login/worst-like.png" width="600px">



## わかる



## おわり
