// Basin Pool Co. Quick Estimate Calculator
// FRESH DEPLOY - Cache Bust: 2025-08-04-02:00:00
// Clean sales tool with Master Plan pricing and mobile navigation

// MASTER PLAN PRICING - CORRECT BASE PRICES
const PRICING = {
    pools: {
        '6ft': 2495,   // "The Splash" - Master Plan base price
        '8ft': 2795,   // "The Oasis" - Master Plan base price
        '10ft': 3495   // "The Resort" - Master Plan base price
    },
    addons: {
        saltwater: 697,      // Spa Experience
        heating: 1497,       // Heating System  
        premiumSite: 400,    // Turnkey Site Prep (as addon)
        shade: 1797          // Shade System
    },
    sitePrepCost: 400        // Site preparation value
};

// Current selection
let selectedPool = null;
let selectedAddons = [];
let siteReady = false;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('Calculator starting with correct prices:', PRICING);
    setupEventListeners();
    updateTotal();
});

// Setup event listeners
function setupEventListeners() {
    // Pool selection buttons
    document.querySelectorAll('.select-package').forEach(btn => {
        btn.addEventListener('click', function() {
            const card = this.closest('.package-card');
            const size = card.dataset.size;
            selectPool(size);
        });
    });

    // Addon checkboxes
    document.querySelectorAll('.addon-item input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', updateAddons);
    });

    // Customer inputs
    document.querySelectorAll('.customer-input').forEach(input => {
        input.addEventListener('input', updateCustomer);
    });

    // Discount
    const discountSelect = document.getElementById('discountPercent');
    if (discountSelect) {
        discountSelect.addEventListener('change', updateTotal);
    }

    // Buttons
    const generateBtn = document.getElementById('generateQuote');
    if (generateBtn) {
        generateBtn.addEventListener('click', generateQuote);
    }

    const collectBtn = document.getElementById('collectDeposit');
    if (collectBtn) {
        collectBtn.addEventListener('click', collectDeposit);
    }

    const emailBtn = document.getElementById('emailQuote');
    if (emailBtn) {
        emailBtn.addEventListener('click', emailQuote);
    }

    // Modal
    const closeBtn = document.querySelector('.close');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeModal);
    }

    const printBtn = document.getElementById('printQuote');
    if (printBtn) {
        printBtn.addEventListener('click', printQuote);
    }

    const downloadBtn = document.getElementById('downloadPDF');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', downloadPDF);
    }

    console.log('Event listeners ready');
}

// Select pool package
function selectPool(size) {
    console.log('Selecting pool:', size, 'Price:', PRICING.pools[size]);
    
    // Clear previous selection
    document.querySelectorAll('.package-card').forEach(card => {
        card.classList.remove('selected');
    });

    // Select new package
    const selectedCard = document.querySelector(`[data-size="${size}"]`);
    if (selectedCard) {
        selectedCard.classList.add('selected');
    }

    // Store selection (Master Plan base price)
    selectedPool = {
        size: size,
        price: PRICING.pools[size],
        name: `${size} Pool Package`
    };

    updateTotal();
}

// Update addons
function updateAddons() {
    selectedAddons = [];
    
    // Get checked addons
    document.querySelectorAll('.addon-item input[type="checkbox"]:checked').forEach(checkbox => {

        let price = 0;
        let name = checkbox.nextElementSibling?.querySelector('.addon-name')?.textContent || 'Unknown';

        // Get price from PRICING object
        if (checkbox.id === 'saltwater') price = PRICING.addons.saltwater;
        else if (checkbox.id === 'heating') price = PRICING.addons.heating;
        else if (checkbox.id === 'premiumSite') price = PRICING.addons.premiumSite;
        else if (checkbox.id === 'shade') price = PRICING.addons.shade;

        if (price > 0) {
            selectedAddons.push({
                id: checkbox.id,
                name: name,
                price: price
            });
        }
    });

    updateTotal();
}

// Update customer info
let customerInfo = {};
function updateCustomer() {
    customerInfo = {
        name: document.getElementById('customerName')?.value || '',
        phone: document.getElementById('customerPhone')?.value || '',
        email: document.getElementById('customerEmail')?.value || ''
    };
}

// Update total - HANDLES SITE PREP DISCOUNT
function updateTotal() {
    let total = 0;
    
    // Show selected services
    const servicesDiv = document.getElementById('selectedServices');
    if (servicesDiv) {
        servicesDiv.innerHTML = '';
    }

    // Add pool price (Master Plan base price)
    if (selectedPool) {
        total += selectedPool.price;
        
        if (servicesDiv) {
            servicesDiv.innerHTML += `
                <div class="service-line">
                    <span>${selectedPool.name}</span>
                    <span>$${selectedPool.price.toLocaleString()}</span>
                </div>
            `;
        }
    }

    // Add addon prices
    selectedAddons.forEach(addon => {
        total += addon.price;
        if (servicesDiv) {
            servicesDiv.innerHTML += `
                <div class="service-line addon">
                    <span>${addon.name}</span>
                    <span>$${addon.price.toLocaleString()}</span>
                </div>
            `;
        }
    });

    // Calculate discounts
    let discount = 0;
    
    // Manual discount
    const discountPercent = parseInt(document.getElementById('discountPercent')?.value || '0');
    if (discountPercent > 0) {
        discount += Math.round(total * (discountPercent / 100));
    }

    // Final total
    const finalTotal = total - discount;

    // 50/25/25 payment structure
    const deposit = Math.round(finalTotal * 0.5);
    const mobilization = Math.round(finalTotal * 0.25);
    const completion = Math.round(finalTotal * 0.25);

    // Update display
    updateElement('subtotalAmount', `$${total.toLocaleString()}`);
    updateElement('discountAmount', `$${discount.toLocaleString()}`);
    updateElement('totalAmount', `$${finalTotal.toLocaleString()}`);
    updateElement('depositAmount', `$${deposit.toLocaleString()}`);
    updateElement('mobilizationAmount', `$${mobilization.toLocaleString()}`);
    updateElement('completionAmount', `$${completion.toLocaleString()}`);

    // Enable/disable buttons
    const hasPool = selectedPool !== null;
    updateElement('generateQuote', hasPool ? '' : 'disabled', 'disabled');
    updateElement('collectDeposit', hasPool ? '' : 'disabled', 'disabled');

    console.log('Total updated:', {
        subtotal: total,
        discount: discount,
        final: finalTotal,
        deposit: deposit
    });
}

// Helper to safely update elements
function updateElement(id, text, attribute = 'textContent') {
    const element = document.getElementById(id);
    if (element) {
        if (attribute === 'disabled') {
            if (text === 'disabled') {
                element.disabled = true;
            } else {
                element.disabled = false;
            }
        } else {
            element[attribute] = text;
        }
    }
}

// Generate quote
function generateQuote() {
    if (!customerInfo.name) {
        alert('Please enter customer name');
        document.getElementById('customerName')?.focus();
        return;
    }

    const quoteHTML = `
        <div class="quote-document">
            <div class="quote-header">
                <h2>🏊 Basin Pool Co.</h2>
                <p>Professional Pool Installation</p>
                <div class="quote-date">Date: ${new Date().toLocaleDateString()}</div>
                <div class="quote-number">Quote #: BPC-${Date.now().toString().slice(-6)}</div>
            </div>

            <div class="customer-details">
                <h3>Customer Information</h3>
                <p><strong>Name:</strong> ${customerInfo.name}</p>
                <p><strong>Phone:</strong> ${customerInfo.phone}</p>
                <p><strong>Email:</strong> ${customerInfo.email}</p>
            </div>

            <div class="quote-services">
                <h3>Services & Materials</h3>
                ${document.getElementById('selectedServices')?.innerHTML || ''}
            </div>

            <div class="quote-totals">
                <div class="total-line">
                    <span>Subtotal:</span>
                    <span>${document.getElementById('subtotalAmount')?.textContent || '$0'}</span>
                </div>
                <div class="total-line">
                    <span>Discount:</span>
                    <span>-${document.getElementById('discountAmount')?.textContent || '$0'}</span>
                </div>
                <div class="total-line final">
                    <span><strong>Total Project Cost:</strong></span>
                    <span><strong>${document.getElementById('totalAmount')?.textContent || '$0'}</strong></span>
                </div>
            </div>

            <div class="payment-schedule">
                <h3>Payment Schedule (50/25/25)</h3>
                <div class="payment-breakdown">
                    <div class="payment-item">
                        <span>Today (50% Deposit):</span>
                        <span><strong>${document.getElementById('depositAmount')?.textContent || '$0'}</strong></span>
                    </div>
                    <div class="payment-item">
                        <span>Mobilization (25%):</span>
                        <span><strong>${document.getElementById('mobilizationAmount')?.textContent || '$0'}</strong></span>
                    </div>
                    <div class="payment-item">
                        <span>Completion (25%):</span>
                        <span><strong>${document.getElementById('completionAmount')?.textContent || '$0'}</strong></span>
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
        </div>
    `;

    const quoteModal = document.getElementById('quoteModal');
    const quoteContent = document.getElementById('quoteContent');
    
    if (quoteContent) quoteContent.innerHTML = quoteHTML;
    if (quoteModal) quoteModal.style.display = 'block';
}

// Collect deposit
function collectDeposit() {
    const depositAmount = document.getElementById('depositAmount')?.textContent || '$0';
    const confirmed = confirm(`Collect deposit of ${depositAmount}?\n\nThis would open your payment processor.`);
    
    if (confirmed) {
        alert(`Processing payment: ${depositAmount}\nCustomer: ${customerInfo.name}\n\nWould integrate with payment processor.`);
        
        const collectBtn = document.getElementById('collectDeposit');
        if (collectBtn) {
            collectBtn.textContent = 'Deposit Collected ✓';
            collectBtn.style.backgroundColor = '#27ae60';
        }
    }
}

// Email quote
function emailQuote() {
    if (!customerInfo.email) {
        alert('Please enter customer email');
        document.getElementById('customerEmail')?.focus();
        return;
    }
    alert(`Quote would be emailed to: ${customerInfo.email}`);
}

// Print quote
function printQuote() {
    window.print();
}

// Download PDF
function downloadPDF() {
    alert('PDF generation would be implemented with jsPDF library');
}

// Close modal
function closeModal() {
    const quoteModal = document.getElementById('quoteModal');
    if (quoteModal) quoteModal.style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('quoteModal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
}