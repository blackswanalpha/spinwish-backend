# Spotify Integration Guide

## Overview

The SpinWish backend now includes Spotify Web API integration to automatically fetch and populate artists and songs from Spotify. This integration runs as a scheduled background task and can also be triggered manually via REST API.

## Features

- ✅ Automatic artist discovery from Spotify
- ✅ Top tracks fetching for each artist across major markets
- ✅ Duplicate prevention (checks both Spotify URL and name+artist+album)
- ✅ Genre mapping from artist metadata
- ✅ Dynamic pricing based on song popularity
- ✅ Rate limiting to respect Spotify API quotas
- ✅ Comprehensive error handling and logging
- ✅ Manual sync trigger via REST API
- ✅ Statistics tracking

## Setup Instructions

### 1. Get Spotify API Credentials

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account
3. Click "Create an App"
4. Fill in the app details:
   - **App Name**: SpinWish Backend
   - **App Description**: Music request platform
   - **Redirect URI**: Not needed for Client Credentials flow
5. Accept the terms and create the app
6. Copy your **Client ID** and **Client Secret**

### 2. Configure Application Properties

Add your Spotify credentials to `backend/src/main/resources/application.properties`:

```properties
# Spotify API Configuration
spotify.client-id=YOUR_CLIENT_ID_HERE
spotify.client-secret=YOUR_CLIENT_SECRET_HERE
spotify.fetch.enabled=true
spotify.fetch.rate-limit-delay-ms=300
```

Or set them as environment variables:

```bash
export SPOTIFY_CLIENT_ID=your_client_id_here
export SPOTIFY_CLIENT_SECRET=your_client_secret_here
```

### 3. Database Schema Updates

The `Songs` entity now includes a `spotify_url` field. If using JPA auto-update, this will be added automatically. For production, you may want to create a migration:

```sql
ALTER TABLE songs ADD COLUMN spotify_url VARCHAR(255);
```

### 4. Build and Run

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

## How It Works

### Scheduled Crawling

The `SpotifyFetchService` runs automatically every 66 seconds (configurable) and:

1. **Authenticates** with Spotify using Client Credentials flow
2. **Searches for artists** using alphabetic and numeric queries (a-z, 0-9)
3. **Fetches top tracks** for each artist across 16 major markets
4. **Saves to database** with duplicate checking
5. **Applies genre mapping** from artist metadata
6. **Calculates pricing** based on song popularity

### Artist Processing

- Searches Spotify for artists matching each letter/number
- Saves artist name, image, and genres
- Prevents duplicates by checking artist name

### Song Processing

- Fetches top 10 tracks per artist per market
- Extracts: name, album, duration, artwork, popularity, explicit flag
- Maps genres from artist data
- Calculates base request price (10-50 based on popularity)
- Prevents duplicates by checking Spotify URL or name+artist+album combination

### Rate Limiting

- Default delay: 300ms between API calls
- Configurable via `spotify.fetch.rate-limit-delay-ms`
- Prevents hitting Spotify API rate limits

## API Endpoints

### Manual Sync Trigger

```http
POST /api/v1/spotify/sync
```

Triggers the Spotify crawl process in the background.

**Response:**
```json
{
  "status": "success",
  "message": "Spotify sync started in background",
  "timestamp": 1234567890
}
```

### Get Statistics

```http
GET /api/v1/spotify/stats
```

Returns statistics about processed artists and songs.

**Response:**
```json
{
  "status": "success",
  "statistics": "Artists processed: 150, Songs processed: 1200",
  "timestamp": 1234567890
}
```

### Health Check

```http
GET /api/v1/spotify/health
```

Checks if Spotify integration is properly configured.

**Response:**
```json
{
  "status": "healthy",
  "service": "spotify-integration",
  "timestamp": 1234567890
}
```

## Configuration Options

| Property | Default | Description |
|----------|---------|-------------|
| `spotify.client-id` | - | Your Spotify Client ID (required) |
| `spotify.client-secret` | - | Your Spotify Client Secret (required) |
| `spotify.fetch.enabled` | `true` | Enable/disable automatic fetching |
| `spotify.fetch.rate-limit-delay-ms` | `300` | Delay between API calls in milliseconds |

## Disabling Automatic Sync

To disable automatic syncing (e.g., in development):

```properties
spotify.fetch.enabled=false
```

You can still trigger manual syncs via the REST API.

## Monitoring and Logs

The service logs important events:

- ✅ Authentication success/failure
- ✅ Artists and songs processed
- ✅ Errors during API calls
- ✅ Duplicate detections
- ✅ Sync completion statistics

Example log output:
```
INFO  SpotifyFetchService - Successfully authenticated with Spotify API
INFO  SpotifyFetchService - Saved new artist: Taylor Swift
DEBUG SpotifyFetchService - Saved new song: Anti-Hero by Taylor Swift
INFO  SpotifyFetchService - Spotify crawl completed. Artists processed: 150, Songs processed: 1200
```

## Pricing Strategy

Songs are automatically priced based on Spotify popularity (0-100):

| Popularity | Base Price |
|------------|------------|
| 80-100 | $50.00 |
| 60-79 | $30.00 |
| 40-59 | $20.00 |
| 20-39 | $15.00 |
| 0-19 | $10.00 |

## Genre Mapping

Since Spotify doesn't provide genres at the track level:

1. Extracts genres from artist metadata
2. Uses the first genre if multiple are available
3. Defaults to "Pop" if no genres found

## Market Coverage

The service fetches tracks from 16 major markets:

- 🇺🇸 United States
- 🇬🇧 United Kingdom
- 🇨🇦 Canada
- 🇦🇺 Australia
- 🇩🇪 Germany
- 🇫🇷 France
- 🇪🇸 Spain
- 🇮🇹 Italy
- 🇧🇷 Brazil
- 🇲🇽 Mexico
- 🇯🇵 Japan
- 🇰🇷 South Korea
- 🇮🇳 India
- 🇿🇦 South Africa
- 🇰🇪 Kenya
- 🇳🇬 Nigeria

This ensures a diverse catalog while managing API quota usage.

## Troubleshooting

### Authentication Fails

**Error:** `Failed to authenticate with Spotify API`

**Solution:**
- Verify your Client ID and Client Secret are correct
- Check that credentials are not expired
- Ensure no extra spaces in configuration

### No Songs Being Added

**Possible causes:**
1. `spotify.fetch.enabled=false` - Enable it
2. All songs already exist - Check logs for "already exists" messages
3. API rate limiting - Check for rate limit errors in logs

### Rate Limit Errors

**Error:** `429 Too Many Requests`

**Solution:**
- Increase `spotify.fetch.rate-limit-delay-ms` (e.g., to 500 or 1000)
- Reduce the number of markets in `SpotifyFetchService.majorMarkets`

## Testing

### Test Manual Sync

```bash
curl -X POST http://localhost:8080/api/v1/spotify/sync
```

### Check Statistics

```bash
curl http://localhost:8080/api/v1/spotify/stats
```

### Verify Songs in Database

```bash
curl http://localhost:8080/api/v1/songs
```

Look for songs with `spotifyUrl` populated.

## Flutter App Integration

The Flutter app automatically receives Spotify songs through the existing `/api/v1/songs` endpoint. No changes needed on the Flutter side - songs will appear with:

- Spotify artwork URLs
- Accurate durations
- Popularity scores
- Explicit content flags
- Spotify URLs (for future deep linking)

## Performance Considerations

- **Initial sync** may take 30-60 minutes depending on API limits
- **Subsequent syncs** are faster due to duplicate checking
- **Database growth**: Expect ~10-50 songs per artist
- **API quota**: Spotify allows ~180 requests/minute with Client Credentials

## Future Enhancements

Potential improvements:

- [ ] Search specific artists by name
- [ ] Fetch full albums instead of just top tracks
- [ ] Add playlist import functionality
- [ ] Implement incremental updates (only new releases)
- [ ] Add Spotify preview URL for 30-second clips
- [ ] Support for podcast episodes
- [ ] Advanced genre classification using ML

## Support

For issues or questions:
1. Check application logs for detailed error messages
2. Verify Spotify API credentials
3. Test with manual sync endpoint
4. Review Spotify API status: https://developer.spotify.com/status

## License

This integration uses the [Spotify Web API Java](https://github.com/spotify-web-api-java/spotify-web-api-java) library, which is licensed under the MIT License.

