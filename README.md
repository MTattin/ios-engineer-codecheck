# 株式会社ゆめみ iOS エンジニアコードチェック課題

## 概要

本プロジェクトは株式会社ゆめみ（以下弊社）が、弊社に iOS エンジニアを希望する方に出す課題のベースプロジェクトです。本課題が与えられた方は、下記の概要を詳しく読んだ上で課題を取り組んでください。

## アプリ仕様

本アプリは GitHub のリポジトリーを検索するアプリです。

![動作イメージ](README_Images/app.gif)

### 環境

- IDE：基本最新の安定版（本概要更新時点では Xcode 13.0）
- Swift：基本最新の安定版（本概要更新時点では Swift 5.5）
- 開発ターゲット：基本最新の安定版（本概要更新時点では iOS 15.0）
- サードパーティーライブラリーの利用：オープンソースのものに限り制限しない

### 動作

1. 何かしらのキーワードを入力
2. GitHub API（`search/repositories`）でリポジトリーを検索し、結果一覧を概要（リポジトリ名）で表示
3. 特定の結果を選択したら、該当リポジトリの詳細（リポジトリ名、オーナーアイコン、プロジェクト言語、Star 数、Watcher 数、Fork 数、Issue 数）を表示

## 課題取り組み方法

Issues を確認した上、本プロジェクトを [**Duplicate** してください](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/duplicating-a-repository)（Fork しないようにしてください。必要ならプライベートリポジトリーにしても大丈夫です）。今後のコミットは全てご自身のリポジトリーで行ってください。

コードチェックの課題 Issue は全て [`課題`](https://github.com/yumemi/ios-engineer-codecheck/milestone/1) Milestone がついており、難易度に応じて Label が [`初級`](https://github.com/yumemi/ios-engineer-codecheck/issues?q=is%3Aopen+is%3Aissue+label%3A初級+milestone%3A課題)、[`中級`](https://github.com/yumemi/ios-engineer-codecheck/issues?q=is%3Aopen+is%3Aissue+label%3A中級+milestone%3A課題+) と [`ボーナス`](https://github.com/yumemi/ios-engineer-codecheck/issues?q=is%3Aopen+is%3Aissue+label%3Aボーナス+milestone%3A課題+) に分けられています。課題の必須／選択は下記の表とします：

|   | 初級 | 中級 | ボーナス
|--:|:--:|:--:|:--:|
| 新卒／未経験者 | 必須 | 選択 | 選択 |
| 中途／経験者 | 必須 | 必須 | 選択 |


課題 Issueをご自身のリポジトリーにコピーするGitHub Actionsをご用意しております。  
[こちらのWorkflow](./.github/workflows/copy-issues.yml)を[手動でトリガーする](https://docs.github.com/ja/actions/managing-workflow-runs/manually-running-a-workflow)ことでコピーできますのでご活用下さい。

課題が完成したら、リポジトリーのアドレスを教えてください。

## 参考記事

提出された課題の評価ポイントに関しては、[こちらの記事](https://qiita.com/lovee/items/d76c68341ec3e7beb611)に詳しく書かれてありますので、ぜひご覧ください。

---

# 課題について

## Issuesについて

全てのIssueに対して対応を行いました。

git-flowに基づいて、developブランチからそれぞれのfeatureブランチをローカルで作成し、developへマージを行い、developからmainへのPRを作成して作業を行いました。

チーム開発であれば、featureブランチをリモートへプッシュして、featureからdevelopへのプルリクという流れだと思いますが、今回は一人で課題としてだったので、上記フローで開発を進めました。


ただ、最初の#1と#2に関しましては、普段はメインでBitbucketを利用している為、二つのIssueを1つのプルリクで対応をおこなってしまいました。

また、#4と#6に関しましては、Fat VC回避のタイミングで、MVPベースにリファクタリングを行いましたので、1つのプルリクになっています。


## 環境について

Xcode : Version 13.2.1 (13C100)
Simulator : iOS 15.2

## 今回の開発に関する概要

* 可読性を維持する為にswift-formatをSPMで導入

* バグの修正
    * ＃３で潰したと思っていましたが、開発を続けていく中で発見した物も、都度、修正を行いました。

* MVPへのリファクタリング

* Unitテスト、UIテストを追加
    * テスト実装後は、Xcodeで取得できるカバレッジのスクリーンショットを、それぞれのPRには添付しています。

* UIのブラッシュアップとして以下を実装
    * 一覧のセルのデザイン変更
    * 一覧画面のタイトル変更（検索成功の場合はタコが赤くなります。）
    * 詳細画面のデザイン変更

* 新機能追加として以下を実装
    * 詳細画面にリポジトリをブラウザで開くボタンを追加
    * 詳細画面に関して、横向き用の画面を追加


以上になります。

ギリギリになりましたが、よろしくお願い致します。
