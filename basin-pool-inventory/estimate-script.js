// Basin Pool Co. Quick Estimate Calculator
// Clean rebuild - no more broken code

// Master Plan Fixed Pricing
const PRICING = {
    pools: {
        '6ft': 2495,   // "The Splash"
        '8ft': 2795,   // "The Oasis" 
        '10ft': 3495   // "The Resort"
    },
    addons: {
        saltwater: 697,      // Spa Experience
        heating: 1497,       // Heating System
        premiumSite: 400,    // Turnkey Site Prep
        shade: 1797          // Shade System
    }
};

// Current quote state
let currentQuote = {
    customer: {},
    pool: null,
    addons: [],
    subtotal: 0,
    discount: 0,
    total: 0,
    deposit: 0
};

// Initialize when DOM loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('Calculator initializing...');
    setupEventListeners();
    updateQuoteSummary();
    console.log('Calculator ready!');
});

// Setup all event listeners
function setupEventListeners() {
    console.log('Setting up event listeners...');
    
    // Pool package buttons
    document.querySelectorAll('.select-package').forEach(btn => {
        btn.addEventListener('click', function() {
            const card = this.closest('.package-card');
            const size = card.dataset.size;
            selectPoolPackage(size);
        });
    });

    // Addon checkboxes
    document.querySelectorAll('.addon-item input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', updateAddons);
    });

    // Customer info inputs
    document.querySelectorAll('.customer-input').forEach(input => {
        input.addEventListener('input', updateCustomerInfo);
    });

    // Discount selection
    const discountSelect = document.getElementById('discountPercent');
    if (discountSelect) {
        discountSelect.addEventListener('change', updateQuoteSummary);
    }

    // Action buttons
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

    // Modal controls
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

    console.log('Event listeners ready!');
}

// Select pool package
function selectPoolPackage(size) {
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

    // Update quote
    currentQuote.pool = {
        size: size,
        price: PRICING.pools[size],
        name: `${size} Pool Package`
    };

    console.log('Pool selected:', currentQuote.pool);
    updateQuoteSummary();
}

// Update addons
function updateAddons() {
    currentQuote.addons = [];
    
    // Check site-ready status
    const siteReadyChecked = document.getElementById('siteReady')?.checked || false;
    
    document.querySelectorAll('.addon-item input[type="checkbox"]:checked').forEach(checkbox => {
        if (checkbox.id === 'siteReady') return; // Handle separately
        
        // Skip site prep if site is ready
        if (siteReadyChecked && checkbox.id === 'premiumSite') {
            checkbox.checked = false;
            return;
        }
        
        let price = 0;
        let name = '';
        
        // Get addon details
        const label = checkbox.nextElementSibling;
        if (label) {
            const nameElement = label.querySelector('.addon-name');
            if (nameElement) {
                name = nameElement.textContent;
            }
        }
        
        // Get price from PRICING
        if (checkbox.id === 'saltwater') price = PRICING.addons.saltwater;
        else if (checkbox.id === 'heating') price = PRICING.addons.heating;
        else if (checkbox.id === 'premiumSite') price = PRICING.addons.premiumSite;
        else if (checkbox.id === 'shade') price = PRICING.addons.shade;
        
        if (price > 0) {
            currentQuote.addons.push({
                id: checkbox.id,
                name: name,
                price: price
            });
        }
    });

    updateQuoteSummary();
}

// Update customer info
function updateCustomerInfo() {
    currentQuote.customer = {
        name: document.getElementById('customerName')?.value || '',
        phone: document.getElementById('customerPhone')?.value || '',
        email: document.getElementById('customerEmail')?.value || ''
    };
}

// Update quote summary
function updateQuoteSummary() {
    let subtotal = 0;
    const servicesDiv = document.getElementById('selectedServices');
    if (servicesDiv) {
        servicesDiv.innerHTML = '';
    }

    // Add pool to quote
    if (currentQuote.pool) {
        subtotal += currentQuote.pool.price;
        if (servicesDiv) {
            servicesDiv.innerHTML += `
                <div class="service-line">
                    <span>${currentQuote.pool.name}</span>
                    <span>${formatCurrency(currentQuote.pool.price)}</span>
                </div>
            `;
        }
    }

    // Add addons to quote
    currentQuote.addons.forEach(addon => {
        subtotal += addon.price;
        if (servicesDiv) {
            servicesDiv.innerHTML += `
                <div class="service-line addon">
                    <span>${addon.name}</span>
                    <span>${formatCurrency(addon.price)}</span>
                </div>
            `;
        }
    });

    // Calculate discount
    const discountPercent = parseInt(document.getElementById('discountPercent')?.value || '0');
    let discountAmount = subtotal * (discountPercent / 100);
    
    // Add site-ready discount
    const siteReadyChecked = document.getElementById('siteReady')?.checked || false;
    if (siteReadyChecked) {
        discountAmount += 400; // Site-ready saves $400
    }
    
    const total = subtotal - discountAmount;
    
    // 50/25/25 payment structure
    const deposit = total * 0.5;
    const mobilization = total * 0.25;
    const completion = total * 0.25;

    // Update quote object
    currentQuote.subtotal = subtotal;
    currentQuote.discount = discountAmount;
    currentQuote.total = total;
    currentQuote.deposit = deposit;

    // Update display
    updateElement('subtotalAmount', formatCurrency(subtotal));
    updateElement('discountAmount', formatCurrency(discountAmount));
    updateElement('totalAmount', formatCurrency(total));
    updateElement('depositAmount', formatCurrency(deposit));
    updateElement('mobilizationAmount', formatCurrency(mobilization));
    updateElement('completionAmount', formatCurrency(completion));

    // Enable/disable buttons
    const hasServices = currentQuote.pool !== null;
    const generateBtn = document.getElementById('generateQuote');
    const collectBtn = document.getElementById('collectDeposit');
    
    if (generateBtn) generateBtn.disabled = !hasServices;
    if (collectBtn) collectBtn.disabled = !hasServices || total === 0;

    console.log('Quote updated:', {
        subtotal: subtotal,
        discount: discountAmount,
        total: total,
        deposit: deposit
    });
}

// Helper function to safely update element text
function updateElement(id, text) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = text;
    }
}

// Format currency
function formatCurrency(amount) {
    return '$' + amount.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}

// Generate quote
function generateQuote() {
    if (!currentQuote.customer.name) {
        alert('Please enter customer name before generating quote.');
        const nameInput = document.getElementById('customerName');
        if (nameInput) nameInput.focus();
        return;
    }

    const quoteHTML = generateQuoteHTML();
    const quoteContent = document.getElementById('quoteContent');
    const quoteModal = document.getElementById('quoteModal');
    
    if (quoteContent) quoteContent.innerHTML = quoteHTML;
    if (quoteModal) quoteModal.style.display = 'block';
}

// Generate quote HTML
function generateQuoteHTML() {
    return `
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
                ${document.getElementById('selectedServices')?.innerHTML || ''}
            </div>

            <div class="quote-totals">
                <div class="total-line">
                    <span>Subtotal:</span>
                    <span>${formatCurrency(currentQuote.subtotal)}</span>
                </div>
                ${currentQuote.discount > 0 ? `
                <div class="total-line discount">
                    <span>Discount:</span>
                    <span>-${formatCurrency(currentQuote.discount)}</span>
                </div>
                ` : ''}
                <div class="total-line final">
                    <span><strong>Total Project Cost:</strong></span>
                    <span><strong>${formatCurrency(currentQuote.total)}</strong></span>
                </div>
            </div>

            <div class="payment-schedule">
                <h3>Payment Schedule (50/25/25)</h3>
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
        </div>
    `;
}

// Collect deposit
function collectDeposit() {
    if (currentQuote.total === 0) {
        alert('Please select services before collecting deposit.');
        return;
    }

    const depositAmount = formatCurrency(currentQuote.deposit);
    const confirmed = confirm(`Collect deposit of ${depositAmount}?\n\nThis would normally open your payment processor.`);
    
    if (confirmed) {
        alert(`Payment processing simulation:\n\nAmount: ${depositAmount}\nCustomer: ${currentQuote.customer.name}\n\nIn production, this would integrate with your payment processor.`);
        
        const collectBtn = document.getElementById('collectDeposit');
        if (collectBtn) {
            collectBtn.textContent = 'Deposit Collected ✓';
            collectBtn.style.backgroundColor = '#27ae60';
        }
    }
}

// Email quote
function emailQuote() {
    if (!currentQuote.customer.email) {
        alert('Please enter customer email address.');
        const emailInput = document.getElementById('customerEmail');
        if (emailInput) emailInput.focus();
        return;
    }

    alert(`Quote would be emailed to: ${currentQuote.customer.email}\n\nIn production, this would integrate with your email service.`);
}

// Print quote
function printQuote() {
    window.print();
}

// Download PDF
function downloadPDF() {
    alert('PDF generation would be implemented here using a library like jsPDF or server-side generation.');
}

// Close modal
function closeModal() {
    const quoteModal = document.getElementById('quoteModal');
    if (quoteModal) {
        quoteModal.style.display = 'none';
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('quoteModal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
}