table 6060004 "NPR Spfy NC Return Queue"
{
    Access = Internal;
    Caption = 'Shopify Legacy Return Queue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger) { Caption = 'Entry No.'; AutoIncrement = true; DataClassification = SystemMetadata; Editable = false; }
        field(10; "Shopify Store Code"; Code[20]) { Caption = 'Shopify Store Code'; TableRelation = "NPR Spfy Store"; NotBlank = true; DataClassification = CustomerContent; }
        field(20; "Source Doc. ID"; Text[30]) { Caption = 'Source Doc. ID'; NotBlank = true; DataClassification = CustomerContent; }
        field(30; "Source Doc. Name"; Text[50]) { Caption = 'Source Doc. Name'; DataClassification = CustomerContent; }
        field(40; "Order Id"; Text[30]) { Caption = 'Shopify Order Id'; DataClassification = CustomerContent; }
        field(50; "Order No."; Text[50]) { Caption = 'Shopify Order No.'; DataClassification = CustomerContent; }
        field(60; Status; Enum "NPR Spfy Legacy Return Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // The note explains a waiting row or a refund with nothing to credit only; any other status makes it stale.
                if not (Status in [Status::Waiting, Status::"Nothing to Credit"]) then
                    "Outcome Note" := '';
            end;
        }
        field(70; "Detected At"; DateTime) { Caption = 'Detected At'; DataClassification = CustomerContent; Editable = false; }
        field(80; "Processed At"; DateTime) { Caption = 'Processed At'; DataClassification = CustomerContent; Editable = false; }
        field(90; "Retry Count"; Integer) { Caption = 'Retry Count'; MinValue = 0; DataClassification = CustomerContent; Editable = false; }
        field(100; "Last Error"; Text[2048]) { Caption = 'Last Error'; DataClassification = CustomerContent; Editable = false; }
        field(110; "Sales Header Doc. No."; Code[20]) { Caption = 'Sales Return Order No.'; DataClassification = CustomerContent; Editable = false; }
        field(120; "Posted Doc. No."; Code[20]) { Caption = 'Posted Document No.'; DataClassification = CustomerContent; Editable = false; }
        field(130; "Location Fallback Used"; Boolean) { Caption = 'Location Fallback Used'; DataClassification = CustomerContent; Editable = false; }
        field(140; "Not Restocked"; Boolean) { Caption = 'Not Restocked'; DataClassification = CustomerContent; Editable = false; }
        field(180; "Source Doc. Type"; Enum "NPR Spfy Legacy Return Source") { Caption = 'Source Doc. Type'; DataClassification = CustomerContent; Editable = false; }
        field(190; "Refund Gift Card Amount"; Decimal)
        {
            Caption = 'Gift Card Refund Amount';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Refund Settlement"."Gift Card Refund Amount" where("Shopify Store Code" = field("Shopify Store Code"), "Source Doc. Type" = field("Source Doc. Type"), "Shopify Id" = field("Source Doc. ID")));
            Editable = false;
        }
        field(200; "Refund Voucher No."; Code[20])
        {
            Caption = 'Voucher';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Refund Settlement"."Voucher No." where("Shopify Store Code" = field("Shopify Store Code"), "Source Doc. Type" = field("Source Doc. Type"), "Shopify Id" = field("Source Doc. ID")));
            TableRelation = "NPR NpRv Voucher";
            Editable = false;
        }
        field(210; "Outcome Note"; Text[2048]) { Caption = 'Outcome Note'; DataClassification = CustomerContent; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(SourceDocKey; "Shopify Store Code", "Source Doc. Type", "Source Doc. ID") { Unique = true; }
        key(StatusKey; Status) { }
        key(SalesHeaderKey; "Sales Header Doc. No.") { }
    }

    trigger OnInsert()
    begin
        if "Detected At" = 0DT then
            "Detected At" := CurrentDateTime();
    end;

    trigger OnDelete()
    var
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
    begin
        SpfyLegacyReturnMgt.OnDeleteQueueRow(Rec);
    end;

    /// <summary>
    /// The row of a Shopify return or refund, read like a Get: no filters are left behind. A return and a refund may carry the same number, so the type is part of the identity.
    /// </summary>
    internal procedure FindSourceDoc(ShopifyStoreCode: Code[20]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; SourceDocId: Text[30]) Found: Boolean
    begin
        Reset();
        SetCurrentKey("Shopify Store Code", "Source Doc. Type", "Source Doc. ID");
        SetRange("Shopify Store Code", ShopifyStoreCode);
        SetRange("Source Doc. Type", SourceDocType);
        SetRange("Source Doc. ID", SourceDocId);
        Found := FindFirst();
        Reset();
    end;
}
