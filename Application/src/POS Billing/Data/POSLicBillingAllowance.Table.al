#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151278 "NPR POS Lic. Billing Allowance"
{
    Access = Internal;
    Caption = 'NPR POS License Billing Allowance';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Pool Id"; Guid)
        {
            Caption = 'Pool Id';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the license pool.';
        }
        field(2; "License Type"; Enum "NPR POS Lic. Billing Lic. Type")
        {
            Caption = 'License Type';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the type of the license, for example, for 3 months or 12 months.';
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the license pool.';
        }
        field(4; "Total Licenses"; Integer)
        {
            Caption = 'Total Licenses';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the total number of available licenses in this pool.';
        }
        field(5; "Tenant Id"; Guid)
        {
            Caption = 'Tenant Id';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the ID of the tenant this license pool belongs to.';
        }
        field(6; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the environment this license pool is for.';
        }
        field(7; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the company this license pool is for.';
        }
        field(8; Status; Code[20])
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the status of the license pool (e.g., active, inactive).';
        }
        field(9; "Renewal Month"; Integer)
        {
            Caption = 'Renewal Month';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the month of the year when the license is due for renewal.';
        }
        field(10; "Renewal Day"; Integer)
        {
            Caption = 'Renewal Day';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the day of the month when the license is due for renewal.';
        }
        field(11; "Period Months"; Integer)
        {
            Caption = 'Period Months';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the duration of the license period in months.';
        }
        field(12; "Valid Since"; DateTime)
        {
            Caption = 'Valid Since';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time from which the license pool is valid.';
        }
        field(13; "Valid Until"; DateTime)
        {
            Caption = 'Valid Until';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time until which the license pool is valid.';
        }
        field(14; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when the license pool was created.';
        }
        field(15; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when the license pool was last updated.';
        }
    }

    keys
    {
        key(PK; "Pool Id", "License Type")
        {
            Clustered = true;
        }
        key(Key1; "Tenant Id", "Environment Name", "Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}
#endif