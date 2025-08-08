// Complete 16-Step GHL Sub-Account Onboarding
// Based on official checklist document

const clientData = $input.first().json;

const tasks = [
  {
    name: "1. Integrations",
    content: `**INTEGRATIONS SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\nSub-Account: ${$('Webhook').item.json.body.location?.id}\n\n• Google Business Profile\n• Facebook Ads\n• Google Ads\n• QuickBooks\n• Payment Process\n• 3rd Party Apps\n\n⚠️ Critical for client onboarding success`,
    assigneeId: "88411787"
  },
  {
    name: "2. Website",
    content: `**WEBSITE SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Landing Page creation\n• Standard Terms & Conditions\n• Standard Privacy Policy\n• Domain Setup\n\n📚 Resource: How to use the Domain Connect feature`,
    assigneeId: "88411787"
  },
  {
    name: "3. Phone System",
    content: `**PHONE SYSTEM & A2P REGISTRATION**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• A2P Registration (CRITICAL)\n• Need EIN: COLLECT FROM CLIENT\n• Need Support Email: COLLECT FROM CLIENT\n\n📚 Resource: A2P 10DLC Brand Approval Best Practices\n\n⚠️ Cannot proceed without EIN and support email`,
    assigneeId: "44371660"
  },
  {
    name: "4. Pipelines",
    content: `**PIPELINE SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n⚠️ PRESENT EXACT PIPELINES TO CLIENT AND SEE WHAT DIFFERENCES THE CLIENT LIKES\n\nMake sure to include all numbers for chronological order:\n• Sales Pipeline\n• Master Plan Pipeline\n• Active Job Pipeline\n• Change Order Pipeline\n• Review Pipeline\n• Referral Pipeline`,
    assigneeId: "88411787"
  },
  {
    name: "5. Custom Field Folders",
    content: `**CUSTOM FIELD FOLDERS**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• New Project Questionnaire (Intake)\n• Qualification Questionnaire\n• On-Site Consultation Questionnaire\n• Design Questionnaire\n• Pre-CW Questionnaire\n• Post-CW Questionnaire\n\n📋 Create folders first, then add fields`,
    assigneeId: "88411787"
  },
  {
    name: "6. Custom Value Folders",
    content: `**CUSTOM VALUE FOLDERS**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Calendar Links\n• Form/Survey Links\n\n📁 Organize custom values for easy access`,
    assigneeId: "88411787"
  },
  {
    name: "7. Forms/Surveys",
    content: `**FORMS & SURVEYS**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Calendar Forms\n• Qualification Forms (⚠️ based on client's qualification process)\n• On-Site Consultation\n• Shakedown/Project Prep Meeting\n• Pre-Construction Walkthrough\n• Post-Construction Walkthrough\n• Project Photoshoot Checklist\n\n📝 Customize forms based on client needs`,
    assigneeId: "88411787"
  },
  {
    name: "8. Custom Values + Trigger Links",
    content: `**CUSTOM VALUES & TRIGGER LINKS**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Save surveys as custom values\n• Save custom values as trigger links with UTM parameters\n• Format: ?contact_id={{contact.id}}\n• Example: {{custom_values.landscaping_job_outcome_survey}}?contact_id={{contact.id}}\n\n🔗 Essential for workflow automation`,
    assigneeId: "88411787"
  },
  {
    name: "9. Add Users",
    content: `**ADD USERS TO SUB-ACCOUNT**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Add owner\n• Add all users to sub-account BEFORE creating calendars\n• COLLECT ALL CONTACTS + PHONE + EMAIL\n\n⚠️ CRITICAL: Must complete BEFORE creating calendars`,
    assigneeId: "88411787"
  },
  {
    name: "10. Calendars",
    content: `**CALENDAR SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\nSet up as SERVICE CALENDARS. Create calendar groups first, then add calendars with different colors.\n\n**Calendar Groups:**\n• Consultation Calendar Group\n• Construction Calendars Group\n\n**Calendars:**\n• On-Site Consultation (Light Blue)\n• On-Site Project Presentation (Dark Green)\n• Pre-Construction Walkthrough (Dark Red)\n• Post-Construction Walkthrough (Purple)\n• Project Photoshoot (Dark Blue)\n\n🗓️ Visual color coding essential`,
    assigneeId: "88411787"
  },
  {
    name: "11. Estimate & Invoice Settings",
    content: `**PAYMENT PROCESSING SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Setup Stripe account if needed\n• Connect payment processor\n• Turn auto invoice on\n\n💰 Critical for revenue collection`,
    assigneeId: "88411787"
  },
  {
    name: "12. Automations + Tag Setup",
    content: `**AUTOMATION WORKFLOWS**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Sales Automations\n• Job Management\n• Project Stacking\n• Review Management\n• Schedule Review Post in Social Planner\n\n🤖 Core workflow automation`,
    assigneeId: "88411787"
  },
  {
    name: "13. Dashboards",
    content: `**SALES DASHBOARD SETUP**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n**Dashboard Layout:**\n• Top Row: Opportunity Status, Value, Conversion Rate\n• Second Row: Sales Funnel\n• Third Row: Lead Source Report\n• Fourth Row: GBP\n• Fifth Row: Facebook + PPC Reporting\n• Sixth Row: Sales Efficiency\n\n📚 Resources:\n• How to Edit a dashboard\n• Edit widgets on the dashboard\n\n📊 Critical for performance tracking`,
    assigneeId: "88411787"
  },
  {
    name: "14. Custom Reports",
    content: `**CUSTOM REPORTING**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• Create and schedule reports\n\n📚 Resource: How to create and schedule reports\n\n📈 Data-driven decision making`,
    assigneeId: "88411787"
  },
  {
    name: "15. Domain Setup",
    content: `**DOMAIN CONFIGURATION**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n**Options:**\n• Connect existing domain\n• Buy new domain\n\n📚 Resources:\n• How to use the Domain Connect feature\n• How to Purchase Domain Step by Step\n\n🌐 Professional web presence`,
    assigneeId: "88411787"
  },
  {
    name: "16. Email System",
    content: `**EMAIL INFRASTRUCTURE**\n\nClient: ${$('Webhook').item.json.body.first_name} | ${$('Webhook').item.json.body.company_name}\n\n• G Suite Setup\n• Dedicated Subdomain Setup\n\n📚 Resource: How to Set Up a Dedicated Sending Domain\n\n📧 Professional email delivery`,
    assigneeId: "88411787"
  }
];

return tasks.map(task => ({ json: { ...task, clientData } }));