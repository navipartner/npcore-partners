table 6150676 "NPR License Pool"
{
    Access = Internal;
    DataPerCompany = false;
    Caption = 'NPR License Pool';
    DataClassification = SystemMetadata;
    LookupPageId = "NPR License Pools";
    DrillDownPageId = "NPR License Pools";

    fields
    {
        field(1; "Pool Id"; Guid)
        {
            Caption = 'Pool Id';
            ToolTip = 'Specifies the unique identifier for the license pool.';
        }
        field(2; Module; Enum "NPR License Module")
        {
            Caption = 'Module';
            ToolTip = 'Specifies the module this pool licenses.';
        }
        field(3; "License Term"; Enum "NPR License Term")
        {
            Caption = 'License Term';
            ToolTip = 'Specifies the license term (e.g. 1 month, 1 year).';
        }
        field(4; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the descriptive name of the license pool.';
        }
        field(5; "Total Licenses"; Integer)
        {
            Caption = 'Total Licenses';
            ToolTip = 'Specifies the total number of licenses in this pool.';
        }
        field(6; "Tenant Id"; Guid)
        {
            Caption = 'Tenant Id';
            ToolTip = 'Specifies the tenant this pool belongs to.';
        }
        field(7; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the environment this pool is for.';
        }
        field(8; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the company this pool is for.';
        }
        field(9; Status; Enum "NPR License Pool Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the pool.';
        }
        field(10; "Renewal Month"; Integer)
        {
            Caption = 'Renewal Month';
            ToolTip = 'Specifies the renewal month.';
        }
        field(11; "Renewal Day"; Integer)
        {
            Caption = 'Renewal Day';
            ToolTip = 'Specifies the renewal day.';
        }
        field(12; "Period Months"; Integer)
        {
            Caption = 'Period Months';
            ToolTip = 'Specifies the license period length in months.';
        }
        field(13; "Valid Since Date"; Date)
        {
            Caption = 'Valid Since Date';
            ToolTip = 'Specifies the date from which the pool is valid.';
        }
        field(14; "Valid Until Date"; Date)
        {
            Caption = 'Valid Until Date';
            ToolTip = 'Specifies the date until which the pool is valid.';
        }
        field(15; "Created At"; DateTime)
        {
            Caption = 'Created At';
            ToolTip = 'Specifies when the pool was created.';
        }
        field(16; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            ToolTip = 'Specifies when the pool was last updated.';
        }
        field(17; "Status (API)"; Text[20])
        {
            Caption = 'Status (API)';
            ToolTip = 'Specifies the raw status string returned by the portal API. Kept for diagnostics/transition; not shown on pages.';
        }
    }

    keys
    {
        key(PK; "Pool Id", Module, "License Term")
        {
            Clustered = true;
        }
    }
}
