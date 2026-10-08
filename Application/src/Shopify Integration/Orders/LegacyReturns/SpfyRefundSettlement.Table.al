table 6059994 "NPR Spfy Refund Settlement"
{
    Access = Internal;
    Caption = 'Shopify Refund Settlement';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Shopify Store Code"; Code[20]) { Caption = 'Shopify Store Code'; TableRelation = "NPR Spfy Store"; NotBlank = true; DataClassification = CustomerContent; }
        field(20; "Shopify Id"; Text[30]) { Caption = 'Shopify Id'; NotBlank = true; DataClassification = CustomerContent; }
        field(30; "Display Name"; Text[50]) { Caption = 'Display Name'; DataClassification = CustomerContent; }
        field(40; "Order Id"; Text[30]) { Caption = 'Shopify Order Id'; DataClassification = CustomerContent; }
        field(50; "Gift Card Refund Amount"; Decimal) { Caption = 'Gift Card Refund Amount'; DataClassification = CustomerContent; }
        field(2; "Voucher Refund Amount"; Decimal) { Caption = 'Voucher Refund Amount'; DataClassification = CustomerContent; }
        field(3; "Voucher Refund Amount (LCY)"; Decimal) { Caption = 'Voucher Refund Amount (LCY)'; DataClassification = CustomerContent; }
        field(60; "Voucher No."; Code[20]) { Caption = 'Voucher'; TableRelation = "NPR NpRv Voucher"; ValidateTableRelation = false; DataClassification = CustomerContent; }
        field(70; "Applied Amount"; Decimal) { Caption = 'Applied Amount'; DataClassification = CustomerContent; }
        field(80; "Return Order No."; Code[20]) { Caption = 'Return Order No.'; DataClassification = CustomerContent; }
        field(90; "Source Doc. Type"; Enum "NPR Spfy Legacy Return Source") { Caption = 'Source Doc. Type'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Shopify Store Code", "Source Doc. Type", "Shopify Id") { Clustered = true; }
    }

    /// <summary>
    /// The settlement row of a Return Order, found by the Shopify id and Store Code it is stamped with and confirmed by its number: another document stamped with the same ids is not settled by it.
    /// </summary>
    internal procedure FindForSalesHeader(SalesHeader: Record "Sales Header"): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SourceDocType: Enum "NPR Spfy Legacy Return Source";
        ShopifyId: Text[30];
        StoreCode: Text[30];
    begin
        if (SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order") or (SalesHeader."No." = '') then
            exit(false);
        if not SpfyLegacyReturnMgt.GetSourceDocStamp(SalesHeader.RecordId(), SourceDocType, ShopifyId) then
            exit(false);
        StoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
        if StoreCode = '' then
            exit(false);
        if not Get(CopyStr(StoreCode, 1, MaxStrLen("Shopify Store Code")), SourceDocType, ShopifyId) then
            exit(false);
        exit("Return Order No." = SalesHeader."No.");
    end;
}
