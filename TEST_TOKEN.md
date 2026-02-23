# Test Token - Diagnose FE vs BE Issue

## Quick Test via Postman/curl

Gunakan token yang sama dari app untuk test backend:

```bash
# Token dari log app
TOKEN="58|FOOW5ETR0vZ3jNXtF8maxiwxcBcYour-Full-Token-Here"

# Test ke backend
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/vehicles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### Expected Results:

#### ✅ If Backend Returns 200 OK
→ **Masalah di FE** (connection/format issue)

#### ❌ If Backend Returns 401 Unauthenticated  
→ **Token expired** (normal, perlu refresh mechanism)

---

## Solusi Quick Fix (Test dulu):

### Option 1: Logout & Login Ulang (Dapat fresh token)
1. Buka app → Settings → Logout
2. Login lagi
3. Test apakah masih 401

### Option 2: Cek apakah refresh token works
Print refresh token di console dan test manual

---

## Solusi Permanen (Fix FE):

Services harus pakai `ApiClient` instead of raw `http` untuk auto-refresh.

**VehicleService current (WRONG):**
```dart
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/vehicles'),
  headers: headers,
);
```

**Should be (CORRECT):**
```dart
final apiClient = ApiClient();
final response = await apiClient.get('/vehicles');
```

Ini akan otomatis handle 401 dan refresh token.
