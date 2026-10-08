table 6059922 "NPR Spfy Legacy Return Queue"
{
    Access = Internal;
    Caption = 'Shopify Legacy Return Queue (Obsolete)';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-10-06';
    ObsoleteReason = 'Replaced by NPR Spfy NC Return Queue, keyed by an entry number so a return and a refund may carry the same Shopify id (CORE-2301).';

    fields
    {
        field(10; "Shopify Store Code"; Code[20]) { Caption = 'Shopify Store Code'; TableRelation = "NPR Spfy Store"; NotBlank = true; DataClassification = CustomerContent; }
        field(20; "Return Id"; Text[30]) { Caption = 'Shopify Return Id'; NotBlank = true; DataClassification = CustomerContent; }
        field(30; "Return Name"; Text[50]) { Caption = 'Shopify Return Name'; DataClassification = CustomerContent; }
        field(40; "Order Id"; Text[30]) { Caption = 'Shopify Order Id'; DataClassification = CustomerContent; }
        field(50; "Order No."; Text[50]) { Caption = 'Shopify Order No.'; DataClassification = CustomerContent; }
        field(60; Status; Enum "NPR Spfy Legacy Return Status") { Caption = 'Status'; DataClassification = CustomerContent; }
        field(70; "Detected At"; DateTime) { Caption = 'Detected At'; DataClassification = CustomerContent; Editable = false; }
        field(80; "Processed At"; DateTime) { Caption = 'Processed At'; DataClassification = CustomerContent; Editable = false; }
        field(90; "Retry Count"; Integer) { Caption = 'Retry Count'; MinValue = 0; DataClassification = CustomerContent; Editable = false; }
        field(100; "Last Error"; Text[2048]) { Caption = 'Last Error'; DataClassification = CustomerContent; Editable = false; }
        field(110; "Sales Header Doc. No."; Code[20]) { Caption = 'Sales Return Order No.'; DataClassification = CustomerContent; Editable = false; }
        field(120; "Posted Doc. No."; Code[20]) { Caption = 'Posted Document No.'; DataClassification = CustomerContent; Editable = false; }
        field(130; "Location Fallback Used"; Boolean) { Caption = 'Location Fallback Used'; DataClassification = CustomerContent; Editable = false; }
        field(140; "Not Restocked"; Boolean) { Caption = 'Not Restocked'; DataClassification = CustomerContent; Editable = false; }
        field(150; "Gift Card Refund"; Boolean) { Caption = 'Gift Card Refund'; DataClassification = CustomerContent; Editable = false; }
        field(160; "Voucher No."; Code[20]) { Caption = 'Voucher'; TableRelation = "NPR NpRv Voucher"; DataClassification = CustomerContent; Editable = false; }
        field(170; "Gift Card Refund Amount"; Decimal) { Caption = 'Gift Card Refund Amount'; DataClassification = CustomerContent; Editable = false; }
        // Rows of a pre-release build may be refunds, keyed by "Refund/" and the refund id; the upgrade reads the kind from here.
        field(180; "Source Type"; Enum "NPR Spfy Legacy Return Source") { Caption = 'Source Type'; DataClassification = CustomerContent; Editable = false; }
        field(210; "Outcome Note"; Text[2048]) { Caption = 'Outcome Note'; DataClassification = CustomerContent; Editable = false; }
    }

    keys
    {
        key(PK; "Shopify Store Code", "Return Id") { Clustered = true; }
        key(StatusKey; Status) { }
        key(SalesHeaderKey; "Sales Header Doc. No.") { }
    }

    trigger OnInsert()
    begin
        if "Detected At" = 0DT then
            "Detected At" := CurrentDateTime();
    end;
}
