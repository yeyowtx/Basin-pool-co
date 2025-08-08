# 🚀 Receipt Scanner Production Setup Guide

## Overview
This guide walks you through setting up the receipt scanner with real OCR and product verification APIs.

## Step 1: Veryfi OCR API Setup

### 1.1 Create Veryfi Account
1. Go to https://hub.veryfi.com/signup/
2. Sign up for an account
3. Choose your plan:
   - **Free**: 100 documents/month - Good for testing
   - **Starter**: $39/month, 1,000 documents - Small business
   - **Growth**: $199/month, 10,000 documents - High volume

### 1.2 Get API Credentials
1. Login to your Veryfi dashboard
2. Navigate to **API Keys** section
3. Copy these three values:
   - **Client ID** (starts with `vrfy_`)
   - **Username** (your account username)
   - **API Key** (long string of characters)

### 1.3 Configure Basin Pool App
1. Open `config.js` in your Basin Pool app
2. Replace the placeholder values:

```javascript
OCR_API: {
    CLIENT_ID: 'vrfy_your_actual_client_id_here',    // Replace this
    USERNAME: 'your_actual_username_here',           // Replace this  
    API_KEY: 'your_actual_api_key_here',            // Replace this
    // ... rest stays the same
}
```

## Step 2: BigBox API Setup (Optional - for Home Depot verification)

### 2.1 Get BigBox API Key
1. Go to https://www.bigboxapi.com/
2. Sign up and choose a plan:
   - **Basic**: $29/month, 10,000 requests
   - **Professional**: $99/month, 50,000 requests
3. Get your API key from the dashboard

### 2.2 Configure Product Lookup
1. In `config.js`, update the BigBox settings:

```javascript
PRODUCT_LOOKUP: {
    ENABLED: true,                                   // Change to true
    HOME_DEPOT_API_KEY: 'your_bigbox_api_key_here', // Replace this
    // ... rest stays the same
}
```

## Step 3: Test Production Setup

### 3.1 Test OCR with Real Receipt
1. Open your Basin Pool app
2. Tap "📷 Scan Receipt" 
3. Take a photo of a real Home Depot receipt
4. Process the receipt
5. Verify it extracts correct items and prices

### 3.2 Expected Behavior
- **With Veryfi API**: Real OCR processing, accurate item extraction
- **Without API keys**: Falls back to demo mode with mock data
- **With BigBox API**: Price verification and product enhancement
- **Errors**: Clear error messages if APIs are misconfigured

## Step 4: Cost Management

### 4.1 Monitor Usage
- **Veryfi Dashboard**: Track document processing count
- **BigBox Dashboard**: Monitor API request usage
- **Browser Console**: Check for API errors

### 4.2 Cost Estimates (Monthly)
- **Light Usage** (50 receipts): ~$20-30/month
- **Moderate Usage** (200 receipts): ~$50-80/month  
- **Heavy Usage** (500+ receipts): ~$150-300/month

## Step 5: Error Handling & Troubleshooting

### Common Issues:
1. **"Camera access denied"**: User needs to allow camera permissions
2. **"Veryfi API key not configured"**: Check credentials in config.js
3. **"No items found on receipt"**: Receipt image quality too poor
4. **"BigBox API error"**: Check API key and quota limits

### Debug Mode:
Open browser console (F12) to see detailed logging:
- OCR processing status
- API response details
- Error messages and stack traces

## Step 6: Security Considerations

### 6.1 API Key Protection
- Never commit real API keys to Git
- Consider using environment variables in production
- Rotate API keys periodically

### 6.2 Data Privacy
- Veryfi processes receipt images in the cloud
- Configure `AUTO_DELETE: true` if you want images deleted after processing
- Consider data retention policies

## Step 7: Production Checklist

- [ ] Veryfi account created and API keys configured
- [ ] BigBox API key obtained (if using product verification)
- [ ] Test with real receipts on mobile device
- [ ] Camera permissions working on target devices
- [ ] Error handling tested with poor quality images
- [ ] Usage monitoring set up for cost control
- [ ] API keys secured and not committed to version control

## Support

If you encounter issues:
1. Check browser console for error details
2. Verify API credentials are correct
3. Test with high-quality receipt photos
4. Contact Veryfi/BigBox support for API-specific issues

## Cost-Effective Tips

1. **Start with Free Tier**: Use Veryfi free tier (100/month) for initial testing
2. **Batch Processing**: Process multiple receipts at once to optimize API usage
3. **Image Quality**: Ensure good lighting and clear photos to reduce failed attempts
4. **Error Handling**: Implement retry logic for temporary API failures
5. **Skip Product Lookup**: Disable BigBox API initially to reduce costs

---

**Ready to go live!** Once configured, your Basin Pool inventory will have professional-grade receipt scanning with real OCR and product verification.