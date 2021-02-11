table 6150902 "NPR HC Register"
{
    Caption = 'HC Register';
    DataClassification = CustomerContent;
    LookupPageID = "NPR HC Register List";
    Permissions =;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            DataClassification = CustomerContent;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(11; Account; Code[20])
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
        }
        field(12; "Gift Voucher Account"; Code[20])
        {
            Caption = 'Gift Voucher Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(13; "Credit Voucher Account"; Code[20])
        {
            Caption = 'Credit Voucher Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(14; "Difference Account"; Code[20])
        {
            Caption = 'Difference Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(15; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            DataClassification = CustomerContent;
            TableRelation = IF ("Balanced Type" = CONST(Finans)) "G/L Account"
            ELSE
            IF ("Balanced Type" = CONST(Bank)) "Bank Account";
        }
        field(16; "Difference Account - Neg."; Code[20])
        {
            Caption = 'Difference Account - Neg.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(17; "Gift Voucher Discount Account"; Code[20])
        {
            Caption = 'Gift Voucher Discount Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(25; Rounding; Code[20])
        {
            Caption = 'Rounding';
            DataClassification = CustomerContent;
            Description = 'Kontonummer til ¢reafrunding.';
            TableRelation = "G/L Account"."No." WHERE(Blocked = CONST(false));
        }
        field(26; "Register Change Account"; Code[20])
        {
            Caption = 'Change G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(90; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(91; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(92; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(329; "Balanced Type"; Option)
        {
            Caption = 'Balanced Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Finance,Bank';
            OptionMembers = Finans,Bank;

            trigger OnValidate()
            begin
                if "Balanced Type" <> xRec."Balanced Type" then
                    "Balance Account" := '';
            end;
        }
        field(411; "Sales Ticket Filter"; Code[20])
        {
            Caption = 'Sales Ticket Filter';
            FieldClass = FlowFilter;
        }
        field(412; "Sales Person Filter"; Code[20])
        {
            Caption = 'Sales Person Filter';
            FieldClass = FlowFilter;
        }
        field(414; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
            SumIndexFields = "Opening Cash";
        }
    }

    trigger OnRename()
    begin
        Error(Text1060003, xRec."Register No.");
    end;

    var
        Text1060003: Label 'Register %1 cannot be renamed!';
        DimMgt: Codeunit DimensionManagement;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR HC Register", "Register No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;
}

