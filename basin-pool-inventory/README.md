# Basin Pool Co. - Inventory Tracker

A comprehensive inventory and deposit calculation system for pool installation business operations.

## =€ Features

- **Complete Inventory Management** - Track all materials across 7 categories
- **Real-time Cost Calculations** - Automatic deposit and total calculations
- **Cloud Sync** - Google Sheets API integration for backup and collaboration
- **Mobile Responsive** - Optimized for phones, tablets, and desktop
- **Auto-save** - Automatic local storage backup every 30 seconds
- **Export Options** - JSON and CSV export capabilities
- **Status Tracking** - Click-to-cycle status indicators (Pending ’ Partial ’ Verified)
- **Professional UI** - Clean, modern interface with gradient design

## =Ë Inventory Categories

### Cliff's Installation (21 items)
Complete lean startup package including:
- 8ft CountyLine Tank (700 gal)
- Intex SX2800 Sand Filter Pump
- Salt water system components
- Heating system with FOGATTI heater
- All plumbing and electrical components

### One-Time Tools (6 items)
- Hole saw sets
- Cordless drill
- Step bits
- Level and measuring tools
- Socket sets and wrenches
- Shop vacuum

### Additional Inventory
- **Tanks**: 6ft, 8ft, and 10ft options
- **Pump Systems**: SX2800 and SX3000 models
- **Salt Water Systems**: QS200 units and pool salt
- **Heating Systems**: Additional heaters and components
- **Standard Hardware**: Fittings, hoses, and accessories

## =à Setup Instructions

### Basic Setup (No Cloud Sync)

1. **Download the files** to your computer
2. **Open index.html** in any modern web browser
3. **Start using immediately** - data saves automatically to your browser

### Advanced Setup (With Cloud Sync)

#### Step 1: Create Google Sheet
1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it "Basin Pool Inventory"
4. Copy the spreadsheet ID from the URL (between `/d/` and `/edit`)

#### Step 2: Get Google Sheets API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable the Google Sheets API
4. Create credentials (API key)
5. Restrict the API key to Google Sheets API only

#### Step 3: Configure the Application
1. Open `config.js` in a text editor
2. Replace `YOUR_GOOGLE_SHEETS_API_KEY_HERE` with your API key
3. Replace `YOUR_GOOGLE_SHEET_ID_HERE` with your spreadsheet ID
4. Save the file

```javascript
GOOGLE_SHEETS: {
    API_KEY: 'your_actual_api_key_here',
    SHEET_ID: 'your_actual_sheet_id_here',
    SHEET_NAME: 'Inventory_Data'
}
```

#### Step 4: Share Your Google Sheet
1. Open your Google Sheet
2. Click "Share" button
3. Set to "Anyone with the link can edit"
4. Copy the sharing link for team access

### Web Server Setup (Optional)

For production use, serve the files from a web server:

```bash
# Using Python (if installed)
python -m http.server 8000

# Using Node.js (if installed)
npx serve .

# Using PHP (if installed)
php -S localhost:8000
```

Then access at `http://localhost:8000`

## =ñ Usage Guide

### Adding/Editing Items
- **Actual Price**: Enter real costs as you get quotes
- **Quantity**: Adjust quantities needed for inventory
- **Supplier Links**: Add supplier URLs for easy reordering
- **Notes**: Track important details and specifications

### Status Management
Click status badges to cycle through:
- =4 **Pending** - Not yet researched/ordered
- =á **Partial** - In progress or partially verified
- =â **Verified** - Confirmed pricing and availability

### Data Management
- **Auto-save**: Changes save automatically every 30 seconds
- **Manual Backup**: Use =¾ Backup button to export JSON
- **Restore**: Use =Â Restore to import previous backup
- **Cloud Sync**:  Sync button (requires Google Sheets setup)
- **Clear All**: =Ñ Reset to default data (with confirmation)

### Export Options
- **=Ê Export CSV**: Spreadsheet-compatible format
- **=¾ Export JSON**: Complete data backup
- **=¨ Print Report**: Printer-friendly version

## =' Configuration Options

Edit `config.js` to customize:

### Auto-save Settings
```javascript
AUTO_SAVE: {
    ENABLED: true,
    INTERVAL: 30000, // 30 seconds
}
```

### Cloud Sync Settings
```javascript
CLOUD_SYNC: {
    ENABLED: false, // Set to true when configured
    INTERVAL: 300000, // 5 minutes
}
```

### Export Settings
```javascript
EXPORT: {
    FILENAME_PREFIX: 'basin_pool_inventory',
    INCLUDE_TIMESTAMP: true
}
```

## =Ê Summary Calculations

The system automatically calculates:

- **Total Items**: Count of all inventory items
- **Verified Items**: Count of items with verified status
- **One-Time Tools**: Total cost of tools (one-time purchase)
- **Per-Job Materials**: Total cost of materials needed per job
- **Cliff's Materials**: Total cost of Cliff's lean startup package
- **Total Deposit**: Sum of all categories for customer deposit

## = Data Structure

Each inventory item contains:
```javascript
{
    name: "Item name",
    estimatedPrice: 100.00,
    actualPrice: 95.00,
    quantity: 2,
    usage: "per-job", // one-time, per-job, reusable, consumable
    link: "https://supplier.com/item",
    status: "verified", // pending, partial, verified
    notes: "Additional details"
}
```

## <¨ Mobile Responsive Design

- **Desktop**: Full table layout with all columns visible
- **Tablet**: Condensed layout with smaller inputs
- **Mobile**: Stacked card layout for easy touch interaction
- **Print**: Clean, professional print formatting

## = Data Security

- **Local Storage**: Data stored in browser's local storage
- **Google Sheets**: Optional cloud backup with your own API credentials
- **No External Servers**: All processing happens in your browser
- **Privacy**: No data sent to third parties (except Google Sheets if configured)

## =¨ Troubleshooting

### Cloud Sync Not Working
1. Check API key is valid and unrestricted
2. Verify Sheet ID is correct
3. Ensure Google Sheet is publicly accessible
4. Check browser console for error messages

### Data Not Saving
1. Ensure browser allows local storage
2. Check if storage quota is exceeded
3. Try clearing browser cache and reloading
4. Use manual backup as alternative

### Mobile Display Issues
1. Ensure viewport meta tag is present
2. Test in different browsers
3. Clear browser cache
4. Check if CSS file loaded correctly

## =Þ Support

For technical support or questions:
1. Check browser console for error messages
2. Verify all files are present and accessible
3. Test with different browsers
4. Review configuration settings in `config.js`

## = Version History

- **v4.0** - Cloud Edition with Google Sheets integration
- **v3.0** - Complete Edition (original single-file version)

## =Ä License

This software is provided for Basin Pool Co. business operations. All rights reserved.

---

**Basin Pool Co. - Professional Pool Installation Services**