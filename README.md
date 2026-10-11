# PublicIssueReporter

Flutter 製の公共物故障報告アプリです。Google マップに現在地を表示し、位置情報の更新を追跡します。写真（最大5枚）と故障内容を添えて報告できます。

## Google Maps API キーの設定

Google Maps Platform で Maps SDK for Android と Maps SDK for iOS を有効にした API キーを用意し、次の2か所の `YOUR_GOOGLE_MAPS_API_KEY` を置き換えてください。

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

iOS は `AppDelegate.swift` が `GMSApiKey` を読み込みます。API キーには Android のパッケージ名／署名証明書または iOS の Bundle ID によるアプリケーション制限と、Maps SDK の API 制限を設定してください。クライアント用キーはアプリから確認できるため、サーバー用の秘密鍵を使わず、実キーを公開リポジトリへコミットしないでください。

## 起動

```sh
flutter pub get
flutter run
```

位置情報とカメラを使用するには、実機でそれぞれの権限を許可してください。位置情報を取得できない場合は、画面上部から再試行できます。

## 故障報告

写真と故障内容のいずれかを入力すると報告確認に進みます。現時点の仕様には報告データを保存するバックエンド API が定義されていないため、送信確認後は完了メッセージを表示します。サーバーへの保存には、別途 API 連携が必要です。
