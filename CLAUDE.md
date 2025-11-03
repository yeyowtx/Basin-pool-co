# CLAUDE.md - Christmas Light Inventory Tracker

## 🎯 **PROJECT VISION**

**Purpose**: Professional Christmas light inventory tracking system for contractors  
**Integration**: Connects with roof measurement tool for complete job material planning  
**Users**: Installers, project managers, office staff, VAs

## 🏗️ **PROJECT OVERVIEW**

### **Core Problem Solved**
- **Real-time inventory tracking**: Know exactly what's in stock vs what needs ordering
- **Cost basis management**: Track true material costs for accurate margins
- **Job material planning**: Export from measurement tool, track actual usage
- **Installer documentation**: Record what was actually used vs planned

### **Key Integration Points**
- **Roof Measurement Tool**: Import calculated material lists
- **Quote Generation**: Use real inventory costs for pricing
- **Job Completion**: Track actual vs planned material usage
- **Accounting Systems**: Export for QuickBooks/other systems

## 🎨 **DESIGN INSPIRATION: RooflinePro Analysis**

### **Visual Design System (Extracted Nov 3, 2025)**
- **Primary Color**: `#ECFF00` (bright yellow/green accent)
- **Background**: Dark sidebar `#2d2d2d`, light main area `#F9FAFB`
- **Typography**: Clean sans-serif, multiple font weights
- **Component Style**: Rounded corners, subtle shadows, clean spacing

### **Layout Structure**
```
├── Fixed Dark Sidebar (Navigation)
├── Main Content Area
    ├── Header (Title + Action Buttons)
    ├── Alert/Status Bar (Stock warnings)
    ├── Settings Panel (Calculator inputs)
    ├── Tab Navigation (Product categories)
    └── Product Grid (Cards with details)
```

### **Product Card Pattern**
- **Color Indicator**: Colored circle for visual identification
- **Product Info**: Name, SKU, category
- **Stock Data**: Current quantity, cost basis, sell price
- **Status Badges**: Low stock alerts, availability
- **Actions**: Edit, delete, quick adjust

### **Tech Stack Observed**
- **Framework**: React/Next.js with Tailwind CSS
- **Components**: Modern component architecture
- **Icons**: Lucide React icon library
- **State**: Client-side state management

## 💡 **OUR IMPLEMENTATION APPROACH**

### **Starting Point**
- **Base File**: index.html from roof measurement tool (Google Maps integration)
- **Modify For**: Inventory management instead of measurement
- **Keep**: Professional styling, responsive layout, clean UX

### **Tech Stack (2025 Modern)**
- **Frontend**: Next.js 15 + TypeScript + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + real-time subscriptions)
- **UI Components**: Shadcn/ui (matches RooflinePro aesthetic)
- **State Management**: Zustand + React Query
- **Mobile**: Progressive Web App (PWA) for installers

## 📊 **DATABASE SCHEMA**

### **Core Tables**
```sql
-- Product catalog
products (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    sku VARCHAR UNIQUE NOT NULL,
    category VARCHAR CHECK (category IN ('lights', 'clips', 'wire', 'extras')),
    color VARCHAR,
    cost_basis DECIMAL(10,2), -- What we paid
    sell_price DECIMAL(10,2), -- What we charge
    reorder_point INTEGER DEFAULT 5,
    supplier VARCHAR,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Inventory transactions (all stock movements)
inventory_transactions (
    id UUID PRIMARY KEY,
    product_id UUID REFERENCES products(id),
    transaction_type VARCHAR CHECK (transaction_type IN ('purchase', 'sale', 'adjustment', 'job_usage')),
    quantity INTEGER, -- Positive for in, negative for out
    cost_each DECIMAL(10,2),
    reason VARCHAR,
    job_id UUID, -- Reference to job if applicable
    created_by UUID, -- User who made the transaction
    created_at TIMESTAMP DEFAULT NOW()
);

-- Jobs and material planning
jobs (
    id UUID PRIMARY KEY,
    customer_name VARCHAR NOT NULL,
    address TEXT,
    quote_total DECIMAL(10,2),
    status VARCHAR DEFAULT 'planned',
    roof_measurement_data JSONB, -- Import from measurement tool
    created_at TIMESTAMP DEFAULT NOW()
);

-- Job material requirements
job_materials (
    id UUID PRIMARY KEY,
    job_id UUID REFERENCES jobs(id),
    product_id UUID REFERENCES products(id),
    planned_quantity INTEGER NOT NULL,
    actual_quantity INTEGER, -- Filled by installer
    cost_each DECIMAL(10,2),
    notes TEXT
);

-- Current stock levels (materialized view)
CREATE MATERIALIZED VIEW current_stock AS
SELECT 
    p.id as product_id,
    p.name,
    p.sku,
    p.category,
    COALESCE(SUM(it.quantity), 0) as current_quantity,
    AVG(CASE WHEN it.quantity > 0 THEN it.cost_each END) as avg_cost,
    MAX(it.created_at) as last_transaction
FROM products p
LEFT JOIN inventory_transactions it ON p.id = it.product_id
GROUP BY p.id, p.name, p.sku, p.category;
```

## 🚀 **DEVELOPMENT PHASES**

### **Phase 1: Core Inventory (Week 1)**
- **Product Management**: CRUD for lights, clips, wire, extras
- **Stock Tracking**: Add/adjust inventory levels
- **Basic UI**: Clean product cards, category tabs
- **Cost Basis**: Track purchase costs vs sell prices

### **Phase 2: Integration (Week 2)**
- **Measurement Tool Connection**: Import material calculations
- **Job Planning**: Convert quotes to job material lists
- **Stock Validation**: Check availability before job assignment
- **Cost Integration**: Use real inventory costs in quotes

### **Phase 3: Installer Interface (Week 3)**
- **Mobile PWA**: Offline-capable interface for field use
- **Job Checklist**: Mark materials used during installation
- **Quick Adjustments**: Easy stock updates from job site
- **Photo Documentation**: Before/after with material usage

### **Phase 4: Business Intelligence (Week 4)**
- **Reporting Dashboard**: Stock levels, usage trends, margins
- **Reorder Management**: Automated alerts and purchase orders
- **Cost Analysis**: True job profitability with real material costs
- **Supplier Integration**: Track lead times and bulk pricing

## 🎯 **KEY FEATURES ROADMAP**

### **MVP (Minimum Viable Product)**
- [ ] Product catalog with categories
- [ ] Stock level tracking
- [ ] Basic add/edit/delete products
- [ ] Simple stock adjustments
- [ ] Low stock alerts

### **V1 (Production Ready)**
- [ ] Job material planning
- [ ] Integration with measurement tool
- [ ] Installer mobile interface
- [ ] Cost basis calculations
- [ ] Real-time stock updates

### **V2 (Advanced Features)**
- [ ] Advanced reporting and analytics
- [ ] Purchase order automation
- [ ] Supplier management
- [ ] Barcode scanning
- [ ] Multi-location support

## 📱 **USER WORKFLOWS**

### **Office Staff Workflow**
1. **Planning**: Import material list from measurement tool
2. **Stock Check**: Verify availability of required materials
3. **Procurement**: Generate purchase orders for missing items
4. **Job Assignment**: Prepare material kit for installer

### **Installer Workflow**
1. **Job Start**: Review planned materials on mobile device
2. **Installation**: Mark materials used as work progresses
3. **Adjustments**: Record any changes or additional materials
4. **Completion**: Submit final material usage report

### **Manager Workflow**
1. **Monitoring**: Real-time view of stock levels across all jobs
2. **Analysis**: Review actual vs planned material usage
3. **Optimization**: Adjust stocking levels based on usage patterns
4. **Reporting**: Generate cost and margin reports

## 🔧 **INTEGRATION SPECIFICATIONS**

### **Roof Measurement Tool Integration**
```javascript
// Export material list from measurement tool
const materialList = {
    jobId: 'uuid',
    customerInfo: {...},
    materials: [
        {
            productSku: 'C9L011',
            quantity: 150,
            plannedCost: 127.50
        }
    ]
};

// Import to inventory tracker
await createJobFromMeasurement(materialList);
```

### **Real-time Updates**
- **Supabase Subscriptions**: Live stock level updates
- **WebSocket Integration**: Instant notifications across devices
- **Offline Support**: PWA caching for field operations

## 📈 **SUCCESS METRICS**

### **Operational Efficiency**
- **Stock Accuracy**: 99%+ inventory accuracy
- **Job Prep Time**: 50% reduction in material preparation time
- **Order Fulfillment**: 95%+ jobs completed without material shortages

### **Financial Impact**
- **Margin Visibility**: Real-time true cost calculations
- **Inventory Turnover**: Optimize stock levels to reduce carrying costs
- **Waste Reduction**: Track and minimize material waste

### **User Adoption**
- **Installer Usage**: 100% job material tracking compliance
- **Manager Insights**: Daily review of inventory status
- **Office Efficiency**: Automated reorder notifications

## 🚨 **TECHNICAL CONSIDERATIONS**

### **Performance**
- **Real-time Updates**: Efficient database subscriptions
- **Mobile Optimization**: Fast loading on cellular connections
- **Offline Capability**: Critical for field operations

### **Security**
- **User Authentication**: Role-based access control
- **Data Privacy**: Secure customer and cost information
- **Audit Trail**: Complete transaction history

### **Scalability**
- **Multi-location**: Support for multiple warehouses/trucks
- **High Volume**: Handle thousands of transactions daily
- **Integration Ready**: APIs for third-party connections

## 🔗 **STARTING FILES**

### **Base Template**
- **Source**: `/Users/apple/roof-worktree-cards/index.html`
- **Contains**: Google Maps integration, professional styling, responsive layout
- **Modify**: Replace measurement tools with inventory management
- **Keep**: Overall structure, styling patterns, clean UX

### **Key Components to Adapt**
- **Sidebar Navigation**: Adapt for inventory categories
- **Main Content Area**: Replace map with product grid
- **Calculator Section**: Repurpose for stock management
- **Modal System**: Use for add/edit product forms

---

*Project: Christmas Light Inventory Tracker*  
*Created: November 3, 2025*  
*Base: Roof Measurement Tool (Google Maps + Material Calculator)*  
*Inspiration: RooflinePro Material Library Design*  
*Status: 🚧 Planning Phase - Ready for Development*