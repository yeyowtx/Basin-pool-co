// Basin Pool Co. Quick Estimate Calculator
// Real-time pricing engine for customer appointments

// Dynamic Pricing Configuration - Pulls from Admin System
let PRICING = {
    pools: {
        '6ft': 0,
        '8ft': 0,
        '10ft': 0
    },
    decks: {
        basic: 25,    // per sq ft
        premium: 35,  // per sq ft
        luxury: 45    // per sq ft
    },
    addons: {
        saltwater: 0,
        heating: 0,
        premiumSite: 0,
        deckSeating: 800,
        pergola: 2500,
        lighting: 1200
    },
    jorgeStructure: {
        baseInstallation: 300,  // Jorge's base payment per master plan
        sitePrep: 75,          // Jorge's site prep bonus
        saltSystem: 50,        // Jorge's salt system bonus
        heatingSystem: 100,    // Jorge's heating bonus
        shadeSystem: 75,       // Jorge's shade system bonus
        speedBonus: 75,        // Speed completion bonus
        reviewBonus: 100,      // 5-star review bonus
        helper: 90             // Helper cost per job
    }
};

// Load admin configuration if available
function loadAdminPricing() {
    try {
        const adminConfig = localStorage.getItem('basinPoolAdminConfig');
        if (adminConfig) {
            const config = JSON.parse(adminConfig);
            
            // Update Jorge's structure from admin config
            if (config.jorgeRates) {
                PRICING.jorgeStructure = { ...PRICING.jorgeStructure, ...config.jorgeRates };
            }
            
            console.log('Loaded admin configuration');
        }
    } catch (error) {
        console.error('Failed to load admin pricing:', error);
    }
    
    // ALWAYS use Master Plan fixed pricing (not calculated)
    PRICING.pools = { 
        '6ft': 2495,   // "The Splash" - FIXED customer price
        '8ft': 2795,   // "The Oasis" - FIXED customer price
        '10ft': 3495   // "The Resort" - FIXED customer price
    };
    
    PRICING.addons = { 
        saltwater: 697,      // Spa Experience - FIXED customer price
        heating: 1497,       // Heating System - FIXED customer price
        premiumSite: 400,    // Turnkey Site Prep - FIXED customer price
        shade: 1797          // Shade System - FIXED customer price
    };
    
    console.log('Loaded Master Plan fixed pricing');
}

// Current quote state
let currentQuote = {
    customer: {},
    pool: null,
    deck: null,
    addons: [],
    subtotal: 0,
    discount: 0,
    total: 0,
    deposit: 0
};

// Initialize calculator
document.addEventListener('DOMContentLoaded', function() {
    loadAdminPricing();
    updatePackagePricing();
    setupEventListeners();
    updateDeckPricing();
    updateQuoteSummary();
});

// Event Listeners Setup
function setupEventListeners() {
    // Pool package selection
    document.querySelectorAll('.select-package').forEach(btn => {
        btn.addEventListener('click', function() {
            const card = this.closest('.package-card');
            const size = card.dataset.size;
            selectPoolPackage(size);
        });
    });

    // Deck package selection
    document.querySelectorAll('.select-deck').forEach(btn => {
        btn.addEventListener('click', function() {
            const price = parseInt(this.dataset.price);
            const type = this.closest('.deck-package').dataset.type;
            selectDeckPackage(type, price);
        });
    });

    // Deck size change
    document.getElementById('deckSize').addEventListener('change', function() {
        if (this.value === 'custom') {
            document.getElementById('customSizeInputs').style.display = 'block';
        } else {
            document.getElementById('customSizeInputs').style.display = 'none';
            updateDeckPricing();
        }
    });

    // Custom deck size inputs
    document.getElementById('deckWidth')?.addEventListener('input', updateCustomDeckSize);
    document.getElementById('deckLength')?.addEventListener('input', updateCustomDeckSize);

    // Add-ons
    document.querySelectorAll('.addon-item input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', updateAddons);
    });

    // Discount selection
    document.getElementById('discountPercent').addEventListener('change', updateQuoteSummary);

    // Customer info
    document.querySelectorAll('.customer-input').forEach(input => {
        input.addEventListener('input', updateCustomerInfo);
    });

    // Action buttons
    document.getElementById('generateQuote').addEventListener('click', generateQuote);
    document.getElementById('collectDeposit').addEventListener('click', collectDeposit);
    document.getElementById('emailQuote').addEventListener('click', emailQuote);

    // Modal controls
    document.querySelector('.close').addEventListener('click', closeModal);
    document.getElementById('printQuote').addEventListener('click', printQuote);
    document.getElementById('downloadPDF').addEventListener('click', downloadPDF);
}

// Pool Package Selection
function selectPoolPackage(size) {
    // Clear previous selection
    document.querySelectorAll('.package-card').forEach(card => {
        card.classList.remove('selected');
    });

    // Select new package
    const selectedCard = document.querySelector(`[data-size="${size}"]`);
    selectedCard.classList.add('selected');

    // Update quote
    currentQuote.pool = {
        size: size,
        price: PRICING.pools[size],
        name: `${size} Pool Package`
    };

    updateQuoteSummary();
}

// Deck Package Selection
function selectDeckPackage(type, pricePerSqFt) {
    // Clear previous selection
    document.querySelectorAll('.deck-package').forEach(pkg => {
        pkg.classList.remove('selected');
    });

    // Select new package
    const selectedPackage = document.querySelector(`[data-type="${type}"]`);
    selectedPackage.classList.add('selected');

    // Calculate total based on size
    const sqFt = getCurrentDeckSize();
    const totalPrice = pricePerSqFt * sqFt;

    // Update quote
    currentQuote.deck = {
        type: type,
        pricePerSqFt: pricePerSqFt,
        sqFt: sqFt,
        price: totalPrice,
        name: `${type.charAt(0).toUpperCase() + type.slice(1)} Deck (${sqFt} sq ft)`
    };

    updateQuoteSummary();
}

// Get current deck size
function getCurrentDeckSize() {
    const deckSizeSelect = document.getElementById('deckSize');
    if (deckSizeSelect.value === 'custom') {
        const width = parseInt(document.getElementById('deckWidth').value) || 0;
        const length = parseInt(document.getElementById('deckLength').value) || 0;
        return width * length;
    }
    return parseInt(deckSizeSelect.value);
}

// Update deck pricing display
function updateDeckPricing() {
    const sqFt = getCurrentDeckSize();
    
    document.getElementById('basicDeckTotal').textContent = formatCurrency(25 * sqFt);
    document.getElementById('premiumDeckTotal').textContent = formatCurrency(35 * sqFt);
    document.getElementById('luxuryDeckTotal').textContent = formatCurrency(45 * sqFt);

    // Update current selection if deck is selected
    if (currentQuote.deck) {
        currentQuote.deck.sqFt = sqFt;
        currentQuote.deck.price = currentQuote.deck.pricePerSqFt * sqFt;
        currentQuote.deck.name = `${currentQuote.deck.type.charAt(0).toUpperCase() + currentQuote.deck.type.slice(1)} Deck (${sqFt} sq ft)`;
        updateQuoteSummary();
    }
}

// Update custom deck size
function updateCustomDeckSize() {
    updateDeckPricing();
}

// Update add-ons
function updateAddons() {
    currentQuote.addons = [];
    
    // Check site-ready status first
    const siteReadyCheckbox = document.getElementById('siteReady');
    const siteReadySelected = siteReadyCheckbox && siteReadyCheckbox.checked;
    
    document.querySelectorAll('.addon-item input[type="checkbox"]:checked').forEach(checkbox => {
        // Skip site-ready as it's handled separately
        if (checkbox.id === 'siteReady') return;
        
        // If site is ready and this is site prep, skip it (conflict)
        if (siteReadySelected && checkbox.id === 'premiumSite') {
            checkbox.checked = false; // Uncheck conflicting option
            return;
        }
        
        const price = parseInt(checkbox.dataset.price) || parseInt(checkbox.dataset.discount) || 0;
        const name = checkbox.nextElementSibling.querySelector('.addon-name').textContent;
        
        // Get correct pricing for addons
        let addonPrice = price;
        if (checkbox.id === 'saltwater') addonPrice = PRICING.addons.saltwater;
        else if (checkbox.id === 'heating') addonPrice = PRICING.addons.heating;
        else if (checkbox.id === 'premiumSite') addonPrice = PRICING.addons.premiumSite;
        else if (checkbox.id === 'shade') addonPrice = PRICING.addons.shade;
        
        currentQuote.addons.push({
            id: checkbox.id,
            name: name,
            price: addonPrice
        });
    });

    updateQuoteSummary();
}

// Update customer information
function updateCustomerInfo() {
    currentQuote.customer = {
        name: document.getElementById('customerName').value,
        phone: document.getElementById('customerPhone').value,
        email: document.getElementById('customerEmail').value
    };
}

// Update quote summary
function updateQuoteSummary() {
    let subtotal = 0;
    const servicesDiv = document.getElementById('selectedServices');
    servicesDiv.innerHTML = '';

    // Add pool to quote
    if (currentQuote.pool) {
        subtotal += currentQuote.pool.price;
        servicesDiv.innerHTML += `
            <div class="service-line">
                <span>${currentQuote.pool.name}</span>
                <span>${formatCurrency(currentQuote.pool.price)}</span>
            </div>
        `;
    }

    // Add deck to quote
    if (currentQuote.deck) {
        subtotal += currentQuote.deck.price;
        servicesDiv.innerHTML += `
            <div class="service-line">
                <span>${currentQuote.deck.name}</span>
                <span>${formatCurrency(currentQuote.deck.price)}</span>
            </div>
        `;
    }

    // Add add-ons to quote
    currentQuote.addons.forEach(addon => {
        subtotal += addon.price;
        servicesDiv.innerHTML += `
            <div class="service-line addon">
                <span>${addon.name}</span>
                <span>${formatCurrency(addon.price)}</span>
            </div>
        `;
    });

    // Calculate discount
    const discountPercent = parseInt(document.getElementById('discountPercent').value) || 0;
    let discountAmount = subtotal * (discountPercent / 100);
    
    // Add site-ready discount if selected
    const siteReadyCheckbox = document.getElementById('siteReady');
    if (siteReadyCheckbox && siteReadyCheckbox.checked) {
        discountAmount += 400; // Site-ready saves $400
    }
    
    const total = subtotal - discountAmount;
    
    // 50/25/25 payment structure
    const deposit = total * 0.5;      // 50% deposit
    const mobilization = total * 0.25; // 25% mobilization  
    const completion = total * 0.25;   // 25% completion

    // Update totals
    currentQuote.subtotal = subtotal;
    currentQuote.discount = discountAmount;
    currentQuote.total = total;
    currentQuote.deposit = deposit;

    // Update display
    document.getElementById('subtotalAmount').textContent = formatCurrency(subtotal);
    document.getElementById('discountAmount').textContent = formatCurrency(discountAmount);
    document.getElementById('totalAmount').textContent = formatCurrency(total);
    document.getElementById('depositAmount').textContent = formatCurrency(deposit);
    document.getElementById('mobilizationAmount').textContent = formatCurrency(mobilization);
    document.getElementById('completionAmount').textContent = formatCurrency(completion);

    // Enable/disable buttons based on selection
    const hasServices = currentQuote.pool || currentQuote.deck;
    document.getElementById('generateQuote').disabled = !hasServices;
    document.getElementById('collectDeposit').disabled = !hasServices || total === 0;
}

// Generate Professional Quote
function generateQuote() {
    if (!currentQuote.customer.name) {
        alert('Please enter customer name before generating quote.');
        document.getElementById('customerName').focus();
        return;
    }

    const quoteHTML = `
        <div class="quote-document">
            <div class="quote-header">
                <h2>🏊 Basin Pool Co.</h2>
                <p>Professional Pool & Deck Installation</p>
                <div class="quote-date">Date: ${new Date().toLocaleDateString()}</div>
                <div class="quote-number">Quote #: BPC-${Date.now().toString().slice(-6)}</div>
            </div>

            <div class="customer-details">
                <h3>Customer Information</h3>
                <p><strong>Name:</strong> ${currentQuote.customer.name}</p>
                <p><strong>Phone:</strong> ${currentQuote.customer.phone}</p>
                <p><strong>Email:</strong> ${currentQuote.customer.email}</p>
            </div>

            <div class="quote-services">
                <h3>Services & Materials</h3>
                ${document.getElementById('selectedServices').innerHTML}
            </div>

            <div class="quote-totals">
                <div class="total-line">
                    <span>Subtotal:</span>
                    <span>${formatCurrency(currentQuote.subtotal)}</span>
                </div>
                ${currentQuote.discount > 0 ? `
                <div class="total-line discount">
                    <span>Discount (${document.getElementById('discountPercent').value}%):</span>
                    <span>-${formatCurrency(currentQuote.discount)}</span>
                </div>
                ` : ''}
                <div class="total-line final">
                    <span><strong>Total Project Cost:</strong></span>
                    <span><strong>${formatCurrency(currentQuote.total)}</strong></span>
                </div>
                <div class="total-line deposit">
                    <span><strong>Deposit Required:</strong></span>
                    <span><strong>${formatCurrency(currentQuote.deposit)}</strong></span>
                </div>
            </div>

            <div class="payment-schedule">
                <h3>Payment Schedule</h3>
                <div class="payment-breakdown">
                    <div class="payment-item">
                        <span>Today (50% Deposit):</span>
                        <span><strong>${formatCurrency(currentQuote.total * 0.5)}</strong></span>
                    </div>
                    <div class="payment-item">
                        <span>Mobilization (25%):</span>
                        <span><strong>${formatCurrency(currentQuote.total * 0.25)}</strong></span>
                    </div>
                    <div class="payment-item">
                        <span>Completion (25%):</span>
                        <span><strong>${formatCurrency(currentQuote.total * 0.25)}</strong></span>
                    </div>
                </div>
            </div>

            <div class="quote-terms">
                <h3>Terms & Conditions</h3>
                <ul>
                    <li>50% deposit required to schedule installation</li>
                    <li>25% due upon mobilization to site</li>
                    <li>Final 25% due upon completion</li>
                    <li>Same-day installation (weather permitting)</li>
                    <li>1-year warranty on all installations</li>
                    <li>Quote valid for 30 days</li>
                </ul>
            </div>

            <div class="quote-signature">
                <div class="signature-line">
                    <p>Customer Signature: ___________________________ Date: ___________</p>
                </div>
                <div class="company-signature">
                    <p>Basin Pool Co. Representative</p>
                    <p>Phone: (432) 555-POOL | Email: info@basinpoolco.com</p>
                </div>
            </div>
        </div>
    `;

    document.getElementById('quoteContent').innerHTML = quoteHTML;
    document.getElementById('quoteModal').style.display = 'block';
}

// Collect Deposit
function collectDeposit() {
    if (currentQuote.total === 0) {
        alert('Please select services before collecting deposit.');
        return;
    }

    // In a real implementation, this would integrate with Square/Stripe
    const depositAmount = formatCurrency(currentQuote.deposit);
    const confirmed = confirm(`Collect deposit of ${depositAmount}?\n\nThis would normally open your payment processor.`);
    
    if (confirmed) {
        // Simulate payment processing
        alert(`Payment processing simulation:\n\nAmount: ${depositAmount}\nCustomer: ${currentQuote.customer.name}\n\nIn production, this would integrate with your payment processor.`);
        
        // Mark as deposit collected
        document.getElementById('collectDeposit').textContent = 'Deposit Collected ✓';
        document.getElementById('collectDeposit').style.backgroundColor = '#27ae60';
    }
}

// Email Quote
function emailQuote() {
    if (!currentQuote.customer.email) {
        alert('Please enter customer email address.');
        document.getElementById('customerEmail').focus();
        return;
    }

    // In a real implementation, this would send via email service
    alert(`Quote would be emailed to: ${currentQuote.customer.email}\n\nIn production, this would integrate with your email service.`);
}

// Print Quote
function printQuote() {
    window.print();
}

// Download PDF
function downloadPDF() {
    // In a real implementation, this would generate a PDF
    alert('PDF generation would be implemented here using a library like jsPDF or server-side generation.');
}

// Close Modal
function closeModal() {
    document.getElementById('quoteModal').style.display = 'none';
}

// Update package pricing display
function updatePackagePricing() {
    // Update pool package prices in HTML
    const priceElements = document.querySelectorAll('.package-price');
    if (priceElements.length >= 3) {
        priceElements[0].textContent = formatCurrency(PRICING.pools['6ft']);
        priceElements[1].textContent = formatCurrency(PRICING.pools['8ft']);
        priceElements[2].textContent = formatCurrency(PRICING.pools['10ft']);
    }
    
    // Update addon prices
    const addonPrices = document.querySelectorAll('.addon-price');
    addonPrices.forEach(element => {
        const addonId = element.closest('.addon-item')?.querySelector('input')?.id;
        if (addonId === 'saltwater') {
            element.textContent = '+' + formatCurrency(PRICING.addons.saltwater);
        } else if (addonId === 'heating') {
            element.textContent = '+' + formatCurrency(PRICING.addons.heating);
        } else if (addonId === 'premiumSite') {
            element.textContent = '+' + formatCurrency(PRICING.addons.premiumSite);
        }
    });
}

// Check inventory availability and show lead times
function checkAvailability(packageSize) {
    try {
        const adminConfig = localStorage.getItem('basinPoolAdminConfig');
        if (adminConfig) {
            const config = JSON.parse(adminConfig);
            const inventory = config.inventory || {};
            const leadTimes = config.leadTimes || { local: 3, online: 5 };
            
            let available = false;
            let leadTime = 0;
            
            if (packageSize === '6ft' && inventory.tanks6ft > 0 && inventory.pumpsSX2800 > 0) {
                available = true;
            } else if (packageSize === '8ft' && inventory.tanks8ft > 0 && inventory.pumpsSX2800 > 0) {
                available = true;
            } else if (packageSize === '10ft' && inventory.tanks10ft > 0 && inventory.pumpsSX2800 > 0) {
                available = true;
            } else {
                leadTime = leadTimes.local || 3;
            }
            
            return { available, leadTime };
        }
    } catch (error) {
        console.error('Failed to check availability:', error);
    }
    
    return { available: false, leadTime: 5 };
}

// Add site-ready discount logic
function calculateSiteReadyDiscount(subtotal) {
    // Customer saves $400 when site is ready (Jorge's structure)
    return 400;
}

// Utility Functions
function formatCurrency(amount) {
    return '$' + amount.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('quoteModal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
}