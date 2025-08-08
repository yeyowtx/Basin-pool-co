/**
 * GoHighLevel → n8n → ClickUp Automation System Configuration
 * Production-ready client sub-account onboarding automation
 */

const AUTOMATION_CONFIG = {
  // ClickUp Configuration
  clickup: {
    apiToken: 'pk_88411788_EYD4H795IBNIK6JW88Z1HK93W9HMTNL6',
    spaceId: '90140073497',
    userId: '88411788', // Assign all tasks initially
    baseUrl: 'https://api.clickup.com/api/v2'
  },

  // n8n Cloud Configuration  
  n8n: {
    url: 'https://yeyo.app.n8n.cloud',
    apiKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkOTc5NmJlZi02ZTliLTRkN2EtODZkNC1hNzU0ODRkZTBjZTgiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzU0NjgxNjk0fQ.LVE0NWx77CSmWNno2ooG4j4JyszXJi1lglcNOmK-pLM'
  },

  // GoHighLevel Integration Points
  ghl: {
    webhookEndpoints: {
      newClient: '/ghl/new-client',
      clientUpdate: '/ghl/client-update',
      projectComplete: '/ghl/project-complete'
    }
  },

  // Project Template Structure (Following PDF Order)
  projectTemplate: {
    name: 'GHL Sub-Account Onboarding - {{clientName}}',
    description: 'Complete GoHighLevel sub-account setup following the 16-step onboarding process',
    color: '#7B68EE',
    priority: 'high',
    status: 'active'
  },

  // 16-Step Process Configuration (Exact PDF Order)
  processSteps: {
    '01_integrations': {
      name: '1️⃣ INTEGRATIONS',
      description: 'Set up all required integrations',
      priority: 'high',
      estimatedDays: 2,
      subtasks: [
        'Google Business Profile Integration',
        'Facebook Ads Integration', 
        'Google Ads Integration',
        'QuickBooks Integration',
        'Payment Process Setup',
        '3rd Party Apps Integration'
      ]
    },

    '02_website': {
      name: '2️⃣ WEBSITE',
      description: 'Build website foundation',
      priority: 'high', 
      estimatedDays: 3,
      subtasks: [
        'Landing page creation',
        'Standard terms and conditions',
        'Standard privacy policy',
        'Domain setup (Domain Connect feature)'
      ]
    },

    '03_phone_system': {
      name: '3️⃣ PHONE SYSTEM',
      description: 'Configure phone system with A2P registration',
      priority: 'high',
      estimatedDays: 3,
      subtasks: [
        'A2P registration (CRITICAL: Need EIN + support email)',
        'Reference A2P 10DLC Brand Approval Best Practices'
      ],
      criticalRequirements: ['EIN', 'support_email']
    },

    '04_pipelines': {
      name: '4️⃣ PIPELINES', 
      description: 'PRESENT EXACT PIPELINES AND SEE WHAT DIFFERENCES THE CLIENT LIKES',
      priority: 'high',
      estimatedDays: 2,
      pipelines: {
        sales: 'New Lead → Pending Designer Acceptance → Assigned Lead → On-Site Estimate Scheduled → Need To Send Proposal → Proposal Sent → Proposal Accepted → Deposit Paid',
        masterPlan: 'Build/Edit Master Plan → Designer Review → Ready For Shakedown → PSD Revisions Needed → Master Plan Completed → Drop/Cancelled Project',
        activeJob: 'Book Pre-CW → Pre-CW Booked → Change Order Needed → Active Job → Book Post-CW → Post-CW Booked → Address Punch List → Awaiting Final Payment → Job Closed → Dropped/Cancelled Project',
        changeOrder: 'New Change Order Request → Change Order Sent → Change Order Paid + Closed → Change Order Cancelled',
        review: 'Review Requested → Left Review → Stale Review Request → DO NOT ASK FOR REVIEW',
        referral: 'Referral Requested → Referral Shared → Stale Referral Request → DO NOT ASK FOR REFERRAL'
      }
    },

    '05_custom_field_folders': {
      name: '5️⃣ CUSTOM FIELD FOLDERS',
      description: 'Create all required custom field folders',
      priority: 'medium',
      estimatedDays: 1,
      folders: [
        'New Project Questionnaire (Intake)',
        'Qualification Questionnaire',
        'On-Site Consultation Questionnaire', 
        'Design Questionnaire',
        'Pre-CW Questionnaire',
        'Post-CW Questionnaire'
      ]
    },

    '06_custom_value_folders': {
      name: '6️⃣ CUSTOM VALUE FOLDERS',
      description: 'Set up custom value organization',
      priority: 'medium',
      estimatedDays: 1,
      folders: [
        'Calendar Links',
        'Form/Survey Links'
      ]
    },

    '07_forms_surveys': {
      name: '7️⃣ FORMS/SURVEYS',
      description: 'Create all forms and surveys',
      priority: 'medium',
      estimatedDays: 2,
      forms: [
        'Calendar forms',
        'Qualification forms (**based on client\'s specific qualification process**)',
        'On-Site Consultation (1st Appointment Form)',
        'Shakedown/Project Prep Meeting',
        'Pre-Construction Walkthrough',
        'Post-Construction Walkthrough',
        'Project Photoshoot Checklist'
      ]
    },

    '08_custom_values_trigger_links': {
      name: '8️⃣ CUSTOM VALUES + TRIGGER LINKS',
      description: 'Save surveys as custom values with trigger links',
      priority: 'medium',
      estimatedDays: 1,
      format: '?contact_id={{contact.id}}',
      example: '{{custom_values.landscaping_job_outcome_survey}}?contact_id={{contact.id}}'
    },

    '09_add_users': {
      name: '9️⃣ ADD USERS',
      description: 'Add all users to sub-account BEFORE creating calendars',
      priority: 'high',
      estimatedDays: 1,
      requirements: [
        'Add owner',
        'Add all users to sub-account BEFORE creating calendars',
        'COLLECT ALL CONTACTS + PHONE + EMAIL'
      ]
    },

    '10_calendars': {
      name: '🔟 CALENDARS',
      description: 'Set up SERVICE CALENDARS with different colors',
      priority: 'high',
      estimatedDays: 2,
      calendarGroups: [
        'Consultation Calendar Group',
        'Construction Calendars Group'
      ],
      calendars: {
        'On-Site Consultation': 'Light Blue',
        'On-Site Project Presentation': 'Dark Green',
        'Pre-Construction Walkthrough': 'Dark Red',
        'Post-Construction Walkthrough': 'Purple',
        'Project Photoshoot': 'Dark Blue'
      }
    },

    '11_estimate_invoice_settings': {
      name: '1️⃣1️⃣ ESTIMATE & INVOICE SETTINGS',
      description: 'Configure payment processing',
      priority: 'medium',
      estimatedDays: 1,
      tasks: [
        'Setup Stripe account if needed',
        'Connect payment processor',
        'Turn auto invoice on'
      ]
    },

    '12_automations_tags': {
      name: '1️⃣2️⃣ AUTOMATIONS + TAG SETUP',
      description: 'Build all automation workflows',
      priority: 'high',
      estimatedDays: 3,
      automations: [
        'Sales automations',
        'Job management',
        'Project stacking',
        'Review management',
        'Schedule Review Post in Social Planner'
      ]
    },

    '13_dashboards': {
      name: '1️⃣3️⃣ DASHBOARDS',
      description: 'Create Sales Dashboard with specific layout',
      priority: 'medium',
      estimatedDays: 2,
      layout: {
        row1: 'Opportunity Status, Value, Conversion Rate',
        row2: 'Sales Funnel',
        row3: 'Lead Source Report',
        row4: 'GBP',
        row5: 'Facebook + PPC reporting',
        row6: 'Sales Efficiency'
      }
    },

    '14_custom_reports': {
      name: '1️⃣4️⃣ CUSTOM REPORTS',
      description: 'Set up custom reporting system',
      priority: 'low',
      estimatedDays: 1,
      reference: 'How to create and schedule reports'
    },

    '15_domain_setup': {
      name: '1️⃣5️⃣ DOMAIN SETUP',
      description: 'Connect or purchase domain',
      priority: 'medium',
      estimatedDays: 1,
      options: [
        'Connect existing domain',
        'Buy new domain'
      ],
      reference: 'Domain Connect feature guide'
    },

    '16_email_system': {
      name: '1️⃣6️⃣ EMAIL SYSTEM',
      description: 'Configure email infrastructure',
      priority: 'high',
      estimatedDays: 2,
      components: [
        'G Suite Setup',
        'Dedicated subdomain setup'
      ],
      reference: 'How to Set Up a Dedicated Sending Domain'
    }
  },

  // Task Templates with Detailed Content
  taskTemplates: {
    defaultTask: {
      status: 'to do',
      priority: 'normal',
      assignee: '88411788',
      tags: ['ghl-onboarding', 'automation']
    }
  },

  // Critical Requirements Tracking
  criticalRequirements: {
    a2p_registration: {
      required: ['EIN', 'support_email'],
      step: '03_phone_system'
    },
    user_management: {
      requirement: 'Users MUST be added before creating calendars',
      order: ['09_add_users', '10_calendars']
    },
    client_feedback: {
      requirement: 'Present exact pipelines to client and get feedback',
      step: '04_pipelines'
    },
    qualification_customization: {
      requirement: 'Qualification forms must be based on client\'s specific process',
      step: '07_forms_surveys'
    }
  }
};

// Helper Functions
const AutomationHelpers = {
  
  // Generate project timeline
  calculateProjectTimeline: (customDays = null) => {
    const steps = AUTOMATION_CONFIG.processSteps;
    let timeline = [];
    let cumulativeDays = 0;

    Object.entries(steps).forEach(([stepId, stepConfig]) => {
      const duration = customDays?.[stepId] || stepConfig.estimatedDays;
      const startDate = new Date();
      startDate.setDate(startDate.getDate() + cumulativeDays);
      
      const dueDate = new Date(startDate);
      dueDate.setDate(dueDate.getDate() + duration);

      timeline.push({
        stepId,
        name: stepConfig.name,
        startDate: startDate.toISOString(),
        dueDate: dueDate.toISOString(),
        duration,
        priority: stepConfig.priority
      });

      cumulativeDays += duration;
    });

    return timeline;
  },

  // Create ClickUp task payload
  createTaskPayload: (stepId, clientData) => {
    const step = AUTOMATION_CONFIG.processSteps[stepId];
    const template = AUTOMATION_CONFIG.taskTemplates.defaultTask;

    return {
      name: step.name,
      description: AutomationHelpers.buildTaskDescription(stepId, step, clientData),
      status: template.status,
      priority: step.priority || template.priority,
      assignees: [template.assignee],
      tags: [...template.tags, stepId, clientData.projectType || 'standard'],
      custom_fields: AutomationHelpers.buildCustomFields(stepId, clientData)
    };
  },

  // Build detailed task description with checkboxes
  buildTaskDescription: (stepId, step, clientData) => {
    let description = `${step.description}\n\n`;
    
    // Add client information
    description += `**Client:** ${clientData.clientName}\n`;
    description += `**Project Type:** ${clientData.projectType || 'Standard Onboarding'}\n`;
    description += `**Estimated Duration:** ${step.estimatedDays} days\n\n`;

    // Add subtasks with checkboxes
    if (step.subtasks) {
      description += `**Tasks to Complete:**\n`;
      step.subtasks.forEach(subtask => {
        description += `- [ ] ${subtask}\n`;
      });
      description += '\n';
    }

    // Add specific configurations
    if (step.pipelines) {
      description += `**Pipeline Configurations:**\n`;
      Object.entries(step.pipelines).forEach(([name, pipeline]) => {
        description += `- [ ] **${name.charAt(0).toUpperCase() + name.slice(1)} Pipeline:** ${pipeline}\n`;
      });
      description += '\n';
    }

    if (step.calendars) {
      description += `**Calendar Setup:**\n`;
      Object.entries(step.calendars).forEach(([name, color]) => {
        description += `- [ ] ${name} (${color})\n`;
      });
      description += '\n';
    }

    // Add critical requirements
    if (step.criticalRequirements) {
      description += `**⚠️ CRITICAL REQUIREMENTS:**\n`;
      step.criticalRequirements.forEach(req => {
        description += `- [ ] ${req}\n`;
      });
      description += '\n';
    }

    // Add references
    if (step.reference) {
      description += `**📚 Reference:** ${step.reference}\n\n`;
    }

    // Add "When in doubt, map it out" reminder
    description += `**💡 Remember:** "When in doubt, map it out. If you go in the order of this document, you will have the fewest amount of interruptions (if any)."\n\n`;

    return description;
  },

  // Build custom fields for ClickUp
  buildCustomFields: (stepId, clientData) => {
    return [
      {
        id: 'client_name',
        value: clientData.clientName
      },
      {
        id: 'step_id', 
        value: stepId
      },
      {
        id: 'project_type',
        value: clientData.projectType || 'standard'
      },
      {
        id: 'ghl_sub_account_id',
        value: clientData.subAccountId
      }
    ];
  },

  // Validate critical dependencies
  validateStepDependencies: (stepId) => {
    const criticals = AUTOMATION_CONFIG.criticalRequirements;
    
    // Check if users must be added before calendars
    if (stepId === '10_calendars') {
      return {
        dependency: '09_add_users',
        message: 'Users MUST be added before creating calendars'
      };
    }

    return null;
  }
};

module.exports = {
  AUTOMATION_CONFIG,
  AutomationHelpers
};