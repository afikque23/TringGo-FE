# Test FCM Push Notification via Postman

## 1. GET FCM Server Key dari Firebase Console

1. Buka Firebase Console: https://console.firebase.google.com
2. Pilih project: **motorcycle-management**
3. Klik ⚙️ **Settings** > **Project settings**
4. Tab **Cloud Messaging**
5. Copy **Server key** (FCM Legacy API)

## 2. Kirim Test Notification via Postman

### Request Details:

```
Method: POST
URL: https://fcm.googleapis.com/fcm/send
```

### Headers:

```
Authorization: key=YOUR_FCM_SERVER_KEY_HERE
Content-Type: application/json
```

### Body (JSON):

```json
{
  "to": "e1lYGTQuSvadNWHWx2WeYp:APA91bHA-iLm77rDT...",
  "notification": {
    "title": "Test Pop-up Notifikasi",
    "body": "Ini adalah test notifikasi dari Postman"
  },
  "data": {
    "category_key": "service",
    "notification_id": "999",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "priority": "high"
}
```

**Ganti:**

- `YOUR_FCM_SERVER_KEY_HERE` dengan Server Key dari Firebase Console
- FCM Token dengan token yang ada di log: `e1lYGTQuSvadNWHWx2WeYp:APA91bHA-iLm77rDT...` (gunakan full token dari log Flutter)

## 3. Expected Result:

Setelah send, Anda harus lihat:

- ✅ Pop-up notification muncul di layar HP (walaupun app terbuka)
- ✅ Log di console: `Foreground message: ...`
- ✅ Log di console: `🔔 Showing local notification...`
- ✅ Suara/vibration
- ✅ Badge count di dashboard bertambah

## 4. Troubleshooting Backend

Jika Postman berhasil tapi backend event tidak trigger notification, berarti backend belum terintegrasi dengan FCM sender.

Backend perlu:

1. Install Firebase Admin SDK (Laravel)
2. Kirim FCM notification saat event terjadi:
   - Odometer update (trip selesai)
   - Service reminder due
   - Manual distance added

Butuh saya bantu integrasikan FCM sender di backend?
