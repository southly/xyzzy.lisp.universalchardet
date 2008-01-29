uchardet.dll（「universalchardet」のCライブラリ）を xyzzy から利用します。

* 利用法
 xyzzy.exe のあるところに uchardet.dll をおきます。
 $XYZZY/site-lisp/siteinit.l 又は ~/.xyzzy からに以下を記述します。
   (require "uchardet/uchardet")

* ライセンス
 ライブラリと同様に
 - Mozilla Public License 1.1
 - GNU General Public License 2.0
 - GNU Lesser General Public License 2.1
 のトリプルライセンスとします。

* 更新履歴
 - 2008-01-29 : insert-file-contents でのエンコーディングの自動認識を抑
                止するために、ed::find-file-auto-encoding を再定義。
 - 2008-01-21 : 初版

* 参考
 Universalchardet - やる気向上作戦（http://www.void.in/wiki/Universalchardet）

質問等は NANRI <southly@gmail.com> まで、お願いします。
