# ✅ Spotify Integration Verification Checklist

Use this checklist to verify that your Spotify integration is working correctly.

---

## 📋 Pre-Start Checklist

### Configuration
- [x] Spotify credentials configured in `SpotifyConfig.java`
  - Client ID: `b7f3b06480734fad9f7a877da42b7f8b`
  - Client Secret: `a00eaebfe18d49e593ce6156fb39082d`
- [x] SpotifyFetchService created
- [x] SpotifyController created
- [x] Songs entity updated with `spotifyUrl` field
- [x] SongRepository enhanced with Spotify queries
- [x] Dependencies added to `pom.xml`

### Files Present
- [x] `backend/src/main/java/com/spinwish/backend/config/SpotifyConfig.java`
- [x] `backend/src/main/java/com/spinwish/backend/services/SpotifyFetchService.java`
- [x] `backend/src/main/java/com/spinwish/backend/controllers/SpotifyController.java`
- [x] Documentation files created
- [x] Test script created

---

## 🚀 Startup Checklist

### Step 1: Build the Project
```bash
cd backend
mvn clean install
```

**Expected Output:**
```
[INFO] BUILD SUCCESS
```

**Status:** [ ] Success / [ ] Failed

---

### Step 2: Start the Application
```bash
mvn spring-boot:run
```

**Expected Output:**
```
Started BackendApplication in X.XXX seconds
```

**Status:** [ ] Success / [ ] Failed

---

### Step 3: Check Logs for Spotify Initialization
```bash
tail -f backend.log | grep -i spotify
```

**Expected Output:**
```
INFO  - Initializing Spotify API with client ID: b7f3b064...
```

**Status:** [ ] Success / [ ] Failed

---

## 🧪 Testing Checklist

### Test 1: Health Check
```bash
curl http://localhost:8080/api/v1/spotify/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "spotify-integration",
  "timestamp": 1234567890
}
```

**Status:** [ ] Pass / [ ] Fail

---

### Test 2: Trigger Manual Sync
```bash
curl -X POST http://localhost:8080/api/v1/spotify/sync
```

**Expected Response:**
```json
{
  "status": "success",
  "message": "Spotify sync started in background",
  "timestamp": 1234567890
}
```

**Status:** [ ] Pass / [ ] Fail

---

### Test 3: Wait for Sync (30 seconds)
```bash
sleep 30
```

**Status:** [ ] Waited

---

### Test 4: Check Statistics
```bash
curl http://localhost:8080/api/v1/spotify/stats
```

**Expected Response:**
```json
{
  "status": "success",
  "statistics": "Artists processed: X, Songs processed: Y",
  "timestamp": 1234567890
}
```

**Where X > 0 and Y > 0**

**Status:** [ ] Pass / [ ] Fail

**Actual Values:**
- Artists processed: _______
- Songs processed: _______

---

### Test 5: Check Songs Endpoint
```bash
curl http://localhost:8080/api/v1/songs
```

**Expected:** JSON array with songs

**Status:** [ ] Pass / [ ] Fail

---

### Test 6: Count Spotify Songs
```bash
curl http://localhost:8080/api/v1/songs | jq '[.[] | select(.spotifyUrl != null)] | length'
```

**Expected:** Number greater than 0

**Status:** [ ] Pass / [ ] Fail

**Actual Count:** _______

---

### Test 7: View Sample Spotify Song
```bash
curl http://localhost:8080/api/v1/songs | jq '[.[] | select(.spotifyUrl != null)] | .[0]'
```

**Expected Fields:**
- [ ] `id`
- [ ] `name` / `title`
- [ ] `artist` / `artistName`
- [ ] `album`
- [ ] `genre`
- [ ] `duration`
- [ ] `artworkUrl` (Spotify URL)
- [ ] `baseRequestPrice`
- [ ] `popularity`
- [ ] `isExplicit`
- [ ] `spotifyUrl` (not null)

**Status:** [ ] Pass / [ ] Fail

---

### Test 8: Check Artists Endpoint
```bash
curl http://localhost:8080/api/v1/artists
```

**Expected:** JSON array with artists

**Status:** [ ] Pass / [ ] Fail

---

### Test 9: Run Automated Test Script
```bash
./test-spotify-integration.sh
```

**Expected:** All tests pass with green checkmarks

**Status:** [ ] Pass / [ ] Fail

---

## 📊 Monitoring Checklist

### After 5 Minutes

**Check Statistics:**
```bash
curl http://localhost:8080/api/v1/spotify/stats
```

**Expected:**
- Artists processed: 50-100
- Songs processed: 500-1000

**Actual:**
- Artists processed: _______
- Songs processed: _______

**Status:** [ ] On Track / [ ] Behind / [ ] Ahead

---

### After 15 Minutes

**Check Statistics:**
```bash
curl http://localhost:8080/api/v1/spotify/stats
```

**Expected:**
- Artists processed: 200-400
- Songs processed: 2000-4000

**Actual:**
- Artists processed: _______
- Songs processed: _______

**Status:** [ ] On Track / [ ] Behind / [ ] Ahead

---

### After 30 Minutes

**Check Statistics:**
```bash
curl http://localhost:8080/api/v1/spotify/stats
```

**Expected:**
- Artists processed: 500-1000
- Songs processed: 5000-10000

**Actual:**
- Artists processed: _______
- Songs processed: _______

**Status:** [ ] On Track / [ ] Behind / [ ] Ahead

---

## 🔍 Log Verification Checklist

### Check for Success Messages
```bash
grep -i "successfully authenticated" backend.log
```

**Expected:** At least one occurrence

**Status:** [ ] Found / [ ] Not Found

---

### Check for Artist Saves
```bash
grep -i "saved new artist" backend.log | head -5
```

**Expected:** Multiple artist names

**Status:** [ ] Found / [ ] Not Found

**Sample Artists:** _______________________

---

### Check for Song Saves
```bash
grep -i "saved new song" backend.log | head -5
```

**Expected:** Multiple song names

**Status:** [ ] Found / [ ] Not Found

**Sample Songs:** _______________________

---

### Check for Errors
```bash
grep -i "error" backend.log | grep -i spotify
```

**Expected:** No critical errors (some rate limit warnings are OK)

**Status:** [ ] No Errors / [ ] Has Errors

**Error Details (if any):** _______________________

---

## 📱 Flutter App Checklist

### Open Flutter App
**Status:** [ ] Opened

---

### Navigate to Song List
**Status:** [ ] Navigated

---

### Check for Spotify Songs
Look for songs with:
- [ ] High-quality artwork (Spotify images)
- [ ] Accurate durations
- [ ] Popularity indicators
- [ ] Various genres

**Status:** [ ] Visible / [ ] Not Visible

---

### Search for a Popular Artist
Try searching for: "Taylor Swift", "Drake", "Ed Sheeran"

**Status:** [ ] Found / [ ] Not Found

---

### Request a Spotify Song
**Status:** [ ] Success / [ ] Failed

---

## 🎯 Performance Checklist

### API Response Times

**Health Check:**
```bash
time curl http://localhost:8080/api/v1/spotify/health
```

**Expected:** < 100ms

**Actual:** _______ms

**Status:** [ ] Good / [ ] Slow

---

**Statistics:**
```bash
time curl http://localhost:8080/api/v1/spotify/stats
```

**Expected:** < 100ms

**Actual:** _______ms

**Status:** [ ] Good / [ ] Slow

---

**Songs List:**
```bash
time curl http://localhost:8080/api/v1/songs
```

**Expected:** < 500ms (depends on song count)

**Actual:** _______ms

**Status:** [ ] Good / [ ] Slow

---

## 🐛 Troubleshooting Checklist

### If No Songs Appear

- [ ] Check if service is running: `curl http://localhost:8080/api/v1/spotify/health`
- [ ] Check logs for errors: `grep -i error backend.log`
- [ ] Verify credentials in `SpotifyConfig.java`
- [ ] Trigger manual sync: `curl -X POST http://localhost:8080/api/v1/spotify/sync`
- [ ] Wait 1-2 minutes and check again
- [ ] Check database connection
- [ ] Verify `spotify.fetch.enabled=true` in `application.properties`

---

### If Authentication Fails

- [ ] Verify Client ID: `b7f3b06480734fad9f7a877da42b7f8b`
- [ ] Verify Client Secret: `a00eaebfe18d49e593ce6156fb39082d`
- [ ] Check Spotify Developer Dashboard: https://developer.spotify.com/dashboard
- [ ] Ensure app is active (not deleted)
- [ ] Check for typos in credentials
- [ ] Restart application

---

### If Rate Limited

- [ ] Check logs for "429" errors
- [ ] Increase delay in `application.properties`: `spotify.fetch.rate-limit-delay-ms=500`
- [ ] Wait 5-10 minutes
- [ ] Restart application
- [ ] Reduce number of markets in `SpotifyFetchService.java`

---

## ✅ Final Verification

### All Systems Go?

- [ ] Backend starts successfully
- [ ] Spotify authentication works
- [ ] Artists are being fetched
- [ ] Songs are being saved
- [ ] No critical errors in logs
- [ ] API endpoints respond correctly
- [ ] Statistics show progress
- [ ] Songs appear in database
- [ ] Flutter app displays songs
- [ ] Performance is acceptable

---

## 🎉 Success Criteria

**Minimum Requirements:**
- ✅ At least 50 artists processed
- ✅ At least 500 songs processed
- ✅ No authentication errors
- ✅ API endpoints responding
- ✅ Songs visible in Flutter app

**Optimal Performance:**
- ✅ 500+ artists processed
- ✅ 5000+ songs processed
- ✅ < 100ms API response times
- ✅ No errors in logs
- ✅ Smooth Flutter app experience

---

## 📝 Notes Section

**Date Tested:** _______________________

**Tester Name:** _______________________

**Environment:** [ ] Development / [ ] Staging / [ ] Production

**Additional Observations:**
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________

---

## 🚀 Next Steps After Verification

Once all checks pass:

1. [ ] Document any issues encountered
2. [ ] Adjust configuration if needed
3. [ ] Monitor for 24 hours
4. [ ] Set up production monitoring
5. [ ] Configure backup strategy
6. [ ] Train team on new features
7. [ ] Update user documentation
8. [ ] Celebrate! 🎉

---

**Verification Complete:** [ ] Yes / [ ] No

**Ready for Production:** [ ] Yes / [ ] No

**Sign-off:** _______________________  **Date:** _______________________

