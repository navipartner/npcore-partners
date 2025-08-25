#if not BC17
table 6150989 "NPR Spfy Event Log Entry"
{
    Access = Internal;
    Caption = 'Shopify Event Log';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Event Log Entries";
    LookupPageId = "NPR Spfy Event Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; Type; Enum "NPR Spfy Event Log Entry Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(20; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(30; "Shopify ID"; Text[30])
        {
            Caption = 'Shopify ID';
            DataClassification = CustomerContent;
        }
        field(40; "Event Date-Time"; DateTime)
        {
            Caption = 'Event Date-Time';
            DataClassification = CustomerContent;
        }
        field(100; "Amount (PCY)"; Decimal)
        {
            Caption = 'Amount (PCY)';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Presentment Currency Code";
        }
        field(110; "Presentment Currency Code"; Code[10])
        {
            Caption = 'Presentment Currency Code';
            DataClassification = CustomerContent;
        }
        field(120; "Amount (SCY)"; Decimal)
        {
            Caption = 'Amount (SCY)';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Store Currency Code";
        }
        field(130; "Store Currency Code"; Code[10])
        {
            Caption = 'Store Currency Code';
            DataClassification = CustomerContent;
        }
        field(140; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(PK; "Entry No.") { }
        key(Key2; "Type", "Store Code", "Shopify ID")
        {
            Clustered = true;
        }
        key(Key3; "Store Code", "Event Date-Time", Type) { }
    }

    local procedure FilterShopifyEventLogs(EventType: Enum "NPR Spfy Event Log Entry Type"; ShopifyStoreCode: Code[20]; ShopifyID: Text[30]; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry.SetCurrentKey("Type", "Store Code", "Shopify ID");
        SpfyEventLogEntry.SetRange(Type, EventType);
        SpfyEventLogEntry.SetRange("Store Code", ShopifyStoreCode);
        SpfyEventLogEntry.SetRange("Shopify ID", ShopifyID);
    end;

    internal procedure ShopifyEventLogExists(EventType: Enum "NPR Spfy Event Log Entry Type"; ShopifyStoreCode: Code[20]; ShopifyID: Text[30]): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        FilterShopifyEventLogs(EventType, ShopifyStoreCode, ShopifyID, SpfyEventLogEntry);
        exit(not SpfyEventLogEntry.IsEmpty());
    end;

    internal procedure RegisterShopifyEvent(SpfyEventLogEntryParam: Record "NPR Spfy Event Log Entry")
#if not (BC18 or BC19 or BC20 or BC21 or BC22)
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
#endif
    begin
        if ShopifyEventLogExists(SpfyEventLogEntryParam.Type, SpfyEventLogEntryParam."Store Code", SpfyEventLogEntryParam."Shopify ID") then
            exit;

        Rec := SpfyEventLogEntryParam;
        Rec."Entry No." := 0;
        Rec.Insert(true);

#if not (BC18 or BC19 or BC20 or BC21 or BC22)
        EventBillingClient.RegisterEvent(Rec.SystemId, Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_COUNT, 1);
#endif
    end;

    internal procedure ShowRelatedEntities()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SalesHeader: Record "Sales Header";
        TempSpfyRelatedDocument: Record "NPR Spfy Related Document" temporary;
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        NoRelatedDocsFoundErr: Label 'No related documents found for the line.';
    begin
        case Type of
            Type::"Incoming Sales Order":
                begin
                    if OrderMgt.FindSalesOrder("Store Code", "Shopify ID", SalesHeader) then
                        TempSpfyRelatedDocument.AddSalesHeader(SalesHeader);

                    if OrderMgt.FindSalesInvoices("Store Code", "Shopify ID", TempSalesInvHeader) then
                        if TempSalesInvHeader.FindSet() then
                            repeat
                                TempSpfyRelatedDocument."Document Type" := TempSpfyRelatedDocument."Document Type"::"Posted Sales Invoice";
                                TempSpfyRelatedDocument."Document No." := TempSalesInvHeader."No.";
                                if not TempSpfyRelatedDocument.Find() then
                                    TempSpfyRelatedDocument.Insert();
                            until TempSalesInvHeader.Next() = 0;

                    if TempSpfyRelatedDocument.IsEmpty() then
                        Error(NoRelatedDocsFoundErr);
                    Page.RunModal(0, TempSpfyRelatedDocument);
                end;
        end;
    end;
}
#endif