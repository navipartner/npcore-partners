table 6014641 "NPR Tax Free POS Unit"
{
    Access = Internal;

    Caption = 'POS Tax Free Profile';
    LookupPageID = "NPR POS Tax Free Profiles";
    DrillDownPageId = "NPR POS Tax Free Profiles";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Handler ID"; Text[30])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with "Enum Handler ID Enum"';
            Caption = 'Handler ID';
            DataClassification = CustomerContent;
        }
        field(3; "Handler Parameters"; BLOB)
        {
            Caption = 'Handler Parameters';
            DataClassification = CustomerContent;
        }
        field(4; Mode; Option)
        {
            Caption = 'Mode';
            OptionCaption = 'PROD,TEST';
            OptionMembers = PROD,TEST;
            DataClassification = CustomerContent;
        }
        field(5; "Log Level"; Option)
        {
            Caption = 'Log Level';
            OptionCaption = 'ERROR,FULL,NONE';
            OptionMembers = ERROR,FULL,"NONE";
            DataClassification = CustomerContent;
        }
        field(6; "Check POS Terminal IIN"; Boolean)
        {
            Caption = 'Check POS Terminal IIN';
            DataClassification = CustomerContent;
        }
        field(7; "Min. Sales Amount Incl. VAT"; Decimal)
        {
            Caption = 'Min. Sales Amount Incl. VAT';
            Description = 'DEPRECATED';
            DataClassification = CustomerContent;
        }
        field(9; "Request Timeout (ms)"; Integer)
        {
            Caption = 'Request Timeout (ms)';
            DataClassification = CustomerContent;
        }
        field(10; "Store Voucher Prints"; Boolean)
        {
            Caption = 'Store Voucher Prints';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; "Handler ID Enum"; Enum "NPR Tax Free Handler ID")
        {
            Caption = 'Handler ID';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if ("Handler ID Enum" <> xRec."Handler ID Enum") then
                    if "Handler Parameters".HasValue() then
                        if not Confirm(Confirm_ClearParameter, false, xRec."Handler ID Enum") then
                            Error('');

                Clear("Handler Parameters");
            end;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("POS Unit No.");
    end;

    trigger OnModify()
    begin
        TestField("POS Unit No.");
    end;

    var
        Confirm_ClearParameter: Label 'This will delete any parameters set for handler %1.\Are you sure you want to Continue?';
}

