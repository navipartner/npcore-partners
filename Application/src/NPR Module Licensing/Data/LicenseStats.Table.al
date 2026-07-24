table 6150686 "NPR License Stats"
{
    Access = Internal;
    Caption = 'NPR License Stats';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
        }
        field(2; Module; Enum "NPR License Module")
        {
            Caption = 'Module';
            ToolTip = 'Specifies the module.';
        }
        field(3; "License Term"; Enum "NPR License Term")
        {
            Caption = 'License Term';
            ToolTip = 'Specifies the license term.';
        }
        field(4; "Total Licenses"; Integer)
        {
            Caption = 'Total Licenses';
            ToolTip = 'Specifies the total licenses available.';
        }
        field(5; "Used Licenses"; Integer)
        {
            Caption = 'Used Licenses';
            ToolTip = 'Specifies the active assigned licenses.';
        }
        field(6; Remaining; Integer)
        {
            Caption = 'Remaining';
            ToolTip = 'Specifies the remaining licenses.';
        }
        field(7; "Usage %"; Decimal)
        {
            Caption = 'Usage %';
            ToolTip = 'Specifies the usage percentage.';
            DecimalPlaces = 0 : 1;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ModuleKey; Module, "License Term")
        {
        }
    }
}
