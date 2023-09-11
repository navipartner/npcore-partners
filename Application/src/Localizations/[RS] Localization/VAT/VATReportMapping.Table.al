table 6060017 "NPR VAT Report Mapping"
{
    Access = Internal;
    Caption = 'VAT Report Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR VAT Report Mappings";
    DrillDownPageId = "NPR VAT Report Mappings";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Purchase Payment Base"; Integer)
        {
            Caption = 'Purchase Payment Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(21; "Purchase Payment Amount"; Integer)
        {
            Caption = 'Purchase Payment Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(22; "Purchase Invoice Base"; Integer)
        {
            Caption = 'Purchase Invoice Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(23; "Purchase Invoice Amount"; Integer)
        {
            Caption = 'Purchase Invoice Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(24; "Purchase Cr. Memo Base"; Integer)
        {
            Caption = 'Purchase Cr. Memo Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(25; "Purchase Cr. Memo Amount"; Integer)
        {
            Caption = 'Purchase Cr. Memo Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(30; "Sales Payment Base"; Integer)
        {
            Caption = 'Sales Payment Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(31; "Sales Payment Amount"; Integer)
        {
            Caption = 'Sales Payment Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(32; "Sales Invoice Base"; Integer)
        {
            Caption = 'Sales Invoice Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(33; "Sales Invoice Amount"; Integer)
        {
            Caption = 'Sales Invoice Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(34; "Sales Cr. Memo Base"; Integer)
        {
            Caption = 'Sales Cr. Memo Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(35; "Sales Cr. Memo Amount"; Integer)
        {
            Caption = 'Sales Cr. Memo Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(36; "Book of Inc. Inv. Base"; Enum "NPR Book Of I/O Inv. Mapping")
        {
            Caption = 'Book of Incoming Invoices Base';
            DataClassification = CustomerContent;
        }
        field(37; "Book of Inc. Inv. Amount"; Enum "NPR Book Of I/O Inv. Mapping")
        {
            Caption = 'Book of Incoming Invoices Amount';
            DataClassification = CustomerContent;
        }
        field(38; "Book of Out. Inv. Base"; Enum "NPR Book Of I/O Inv. Mapping")
        {
            Caption = 'Book of Outgoing Invoices Base';
            DataClassification = CustomerContent;
        }
        field(39; "Book of Out. Inv. Amount"; Enum "NPR Book Of I/O Inv. Mapping")
        {
            Caption = 'Book of Outgoing Invoices Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Non-Deductable Base"; Integer)
        {
            Caption = 'Non-Deductable Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(41; "Non-Deductable Amount"; Integer)
        {
            Caption = 'Non-Deductable Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(42; "Deductable Amount"; Integer)
        {
            Caption = 'Deductable Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(43; "Prep. Purchase Invoice Base"; Integer)
        {
            Caption = 'Prepayment Purchase Invoice Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(44; "Prep. Purchase Invoice Amount"; Integer)
        {
            Caption = 'Prepayment Purchase Invoice Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(45; "Prep. Sales Invoice Base"; Integer)
        {
            Caption = 'Prepayment Sales Invoice Base';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(46; "Prep. Sales Invoice Amount"; Integer)
        {
            Caption = 'Prepayment Sales Invoice Amount';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
        field(6014401; "VAT Base Full VAT"; Integer)
        {
            Caption = 'VAT Base Full VAT';
            DataClassification = CustomerContent;
#if BC17 or BC18 or BC19 or BC20 or BC21
            TableRelation = field."No." where(TableNo = const(6060018), Type = const(Decimal));
#else
            TableRelation = field."No." where(TableNo = const(Database::"NPR VAT EV Entry"), Type = const(Decimal));
#endif
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        RSVATEntry: Record "NPR RS VAT Entry";
        CannotBeDeletedErr: Label 'Report Mapping cannot be deleted because RS VAT Entries exist for this Report Mapping';
    begin
        RSVATEntry.SetRange("VAT Report Mapping", Code);
        if RSVATEntry.IsEmpty() then
            exit;
        Error(CannotBeDeletedErr);
    end;
}