table 6060014 "NPR RS VAT Entry"
{
    Access = Internal;
    Caption = 'VAT Entry';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Editable = false;
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(3; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; Type; Enum "General Posting Type")
        {
            Caption = 'Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; Base; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
            Editable = false;
            TableRelation = IF (Type = CONST(Purchase)) Vendor
            ELSE
            IF (Type = CONST(Sale)) Customer;
            DataClassification = CustomerContent;
        }
        field(17; "Closed by Entry No."; Integer)
        {
            Caption = 'Closed by Entry No.';
            Editable = false;
            TableRelation = "NPR RS VAT Entry";
            DataClassification = CustomerContent;
        }
        field(18; Closed; Boolean)
        {
            Caption = 'Closed';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(19; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(22; "Unrealized Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unrealized Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Unrealized Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unrealized Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(24; "Remaining Unrealized Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Unrealized Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(25; "Remaining Unrealized Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Unrealized Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(26; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(38; "Unrealized VAT Entry No."; Integer)
        {
            Caption = 'Unrealized VAT Entry No.';
            Editable = false;
            TableRelation = "NPR RS VAT Entry";
            DataClassification = CustomerContent;
        }
        field(39; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Editable = false;
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(40; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Editable = false;
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(54; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(55; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(56; Reversed; Boolean)
        {
            Caption = 'Reversed';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(57; "Reversed by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Reversed by Entry No.';
            Editable = false;
            TableRelation = "NPR RS VAT Entry";
            DataClassification = CustomerContent;
        }
        field(58; "Reversed Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Reversed Entry No.';
            Editable = false;
            TableRelation = "NPR RS VAT Entry";
            DataClassification = CustomerContent;
        }
        field(81; "Realized Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Realized Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(82; "Realized Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Realized Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(86; "VAT Reporting Date"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6201; "Non-Deductible VAT Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Non-Deductible VAT Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6202; "Non-Deductible VAT Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Non-Deductible VAT Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6014400; "VAT Report Mapping"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Report Mapping';
            Editable = false;
            TableRelation = "NPR VAT Report Mapping";
        }
        field(6014401; "VAT Base Full VAT"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Base Full VAT';
            Editable = false;
        }
        field(6014402; "Prepayment"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Prepayment';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Posting Date", "Document Type", "Document No.", "Posting Date")
        {
        }
    }

    trigger OnInsert()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
            exit;
        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Full VAT" then
            if (VATPostingSetup."NPR Base % For Full VAT" > 0) then begin
                if "Unrealized Amount" <> 0 then
                    "VAT Base Full VAT" := "Unrealized Amount" * 100 / VATPostingSetup."NPR Base % For Full VAT";
                if (Amount <> 0) then
                    "VAT Base Full VAT" := Amount * 100 / VATPostingSetup."NPR Base % For Full VAT";
            end;
        "VAT Report Mapping" := VATPostingSetup."NPR VAT Report Mapping";
    end;
}
