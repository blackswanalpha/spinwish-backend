# Spotify Integration - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Get Spotify Credentials (2 minutes)

1. Go to https://developer.spotify.com/dashboard
2. Log in with your Spotify account
3. Click **"Create an App"**
4. Fill in:
   - App Name: `SpinWish Backend`
   - App Description: `Music request platform`
5. Click **"Create"**
6. Copy your **Client ID** and **Client Secret**

### Step 2: Configure Backend (1 minute)

Open `backend/src/main/resources/application.properties` and update:

```properties
spotify.client-id=YOUR_CLIENT_ID_HERE
spotify.client-secret=YOUR_CLIENT_SECRET_HERE
```

Or set environment variables:

```bash
export SPOTIFY_CLIENT_ID=your_client_id_here
export SPOTIFY_CLIENT_SECRET=your_client_secret_here
```

### Step 3: Build and Run (2 minutes)

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Step 4: Test It! (30 seconds)

```bash
# Trigger manual sync
curl -X POST http://localhost:8080/api/v1/spotify/sync

# Check statistics
curl http://localhost:8080/api/v1/spotify/stats

# View songs (wait 30 seconds first)
curl http://localhost:8080/api/v1/songs | jq '.'
```

## ✅ That's It!

Your backend will now automatically fetch songs from Spotify every 66 seconds.

## 📊 Monitor Progress

### Check Logs
```bash
tail -f backend/backend.log | grep Spotify
```

### Check Statistics
```bash
curl http://localhost:8080/api/v1/spotify/stats
```

### View Songs in Database
```bash
curl http://localhost:8080/api/v1/songs | jq '[.[] | select(.spotifyUrl != null)] | length'
```

## 🎵 What Gets Fetched?

- **Artists**: Discovered via a-z, 0-9 searches
- **Songs**: Top 10 tracks per artist from 16 major markets
- **Metadata**: Name, album, duration, artwork, popularity, genres
- **Pricing**: Auto-calculated based on popularity ($10-$50)

## 🔧 Configuration Options

### Disable Auto-Sync
```properties
spotify.fetch.enabled=false
```

### Adjust Rate Limiting
```properties
spotify.fetch.rate-limit-delay-ms=500  # Slower (safer)
```

## 🐛 Troubleshooting

### "Authentication failed"
- Double-check your Client ID and Client Secret
- Make sure there are no extra spaces
- Verify credentials at https://developer.spotify.com/dashboard

### "No songs appearing"
- Wait 1-2 minutes for initial sync
- Check logs: `tail -f backend/backend.log`
- Verify sync is enabled: `spotify.fetch.enabled=true`

### "Rate limit exceeded"
- Increase delay: `spotify.fetch.rate-limit-delay-ms=500`
- Wait a few minutes and try again

## 📱 Flutter App

No changes needed! The Flutter app automatically displays Spotify songs through the existing `/api/v1/songs` endpoint.

## 🎯 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/spotify/sync` | POST | Trigger manual sync |
| `/api/v1/spotify/stats` | GET | Get statistics |
| `/api/v1/spotify/health` | GET | Health check |
| `/api/v1/songs` | GET | View all songs |
| `/api/v1/artists` | GET | View all artists |

## 📚 Full Documentation

For detailed information, see:
- `SPOTIFY_INTEGRATION.md` - Complete guide
- `SPOTIFY_IMPLEMENTATION_SUMMARY.md` - Technical details

## 🎉 Success!

Once configured, you'll have:
- ✅ Thousands of songs from Spotify
- ✅ High-quality artwork
- ✅ Accurate metadata
- ✅ Automatic updates
- ✅ No manual data entry needed!

## 💡 Pro Tips

1. **First Run**: Initial sync takes 30-60 minutes
2. **Monitoring**: Use `/api/v1/spotify/stats` to track progress
3. **Testing**: Use `./test-spotify-integration.sh` for automated tests
4. **Production**: Set credentials via environment variables
5. **Performance**: Adjust rate limiting based on your needs

## 🆘 Need Help?

1. Check application logs
2. Review `SPOTIFY_INTEGRATION.md`
3. Test with `./test-spotify-integration.sh`
4. Verify Spotify API status: https://developer.spotify.com/status

---

**Happy Spinning! 🎵🎧**

