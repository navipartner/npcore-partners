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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        field(160; "Closed Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Closed Date-Time';
        }
        field(170; "Cancelled Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Cancelled Date';
        }
        field(1130; "Last Error Message"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Message';
        }
        field(1140; "Last Error Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Date';
        }
        field(1160; "Processing Status"; Enum "NPR SpfyEventLogProcessStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Status';
        }
        field(1170; "Document Type"; Enum "NPR SpfyEventLogDocType")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(4020; "Document Status"; Enum "NPR SpfyAPIDocumentStatus")
        {
            Caption = 'Document Status';
            DataClassification = CustomerContent;
        }
        field(4050; "Process Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Process Retry Count';
            BlankZero = true;
        }
        field(4060; "Not Before Date-Time"; DateTime)
        {
            Caption = 'Not Before Date-Time';
            DataClassification = CustomerContent;
        }
        field(4070; Postponed; Boolean)
        {
            Caption = 'Postponed';
            DataClassification = CustomerContent;
        }
        field(4090; "Created Sales Doc No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Created Doc No." where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Created Document No.';
        }
        field(5010; "Virtual Items Process Status"; Enum "NPR EcomVirtualItemDocStatus")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Virtual Items Process Status" where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Virtual Items Processing Status';

        }
        field(5020; "Voucher Processing Status"; Enum "NPR EcomVoucherStatus")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Voucher Processing Status" where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Voucher Processing Status';
        }

        field(5030; "Capture Processing Status"; Enum "NPR Ecom Capture Status")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Capture Processing Status" where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Capture Processing Status';
        }
        field(5040; "Posting Status"; Enum "NPR EcomSalesDocPostStatus")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Posting Status" where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Posting Status';
        }
        field(5050; "Creation Status"; Enum "NPR EcomSalesDocCrtStatus")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Ecom Sales Header"."Creation Status" where("External No." = field("Shopify ID")));
            Editable = false;
            Caption = 'Creation Status';
        }
        field(5060; "Document Name"; Text[50])
        {
            Caption = 'Document Name';
            DataClassification = CustomerContent;
        }
        field(5070; "Bucket Id"; Integer)
        {
            Caption = 'Bucket Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5080; "Order Data"; Blob)
        {
            Caption = 'Order Data';
            DataClassification = CustomerContent;
        }
#endif
    }

    keys
    {
        key(PK; "Entry No.") { }
        key(Key2; "Type", "Store Code", "Shopify ID")
        {
            Clustered = true;
        }
        key(Key3; "Store Code", "Event Date-Time", Type) { }
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        key(Key4; "Document Status", "Processing Status", "Process Retry Count") { }
        key(Key5; "Shopify ID", "Document Status") { }
        key(Key6; "Processing Status", "Process Retry Count", "Not Before Date-Time", "Document Type", "Bucket Id") { }
#endif
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

    begin
        if ShopifyEventLogExists(SpfyEventLogEntryParam.Type, SpfyEventLogEntryParam."Store Code", SpfyEventLogEntryParam."Shopify ID") then
            exit;

        Rec := SpfyEventLogEntryParam;
        Rec."Entry No." := 0;
        Rec.Insert(true);

#if not (BC18 or BC19 or BC20 or BC21 or BC22)
        RegisterEvent(Rec);
#endif
    end;
#if not (BC18 or BC19 or BC20 or BC21 or BC22)
    internal procedure RegisterEvent(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
        MetadataJson: JsonObject;
    begin
        MetadataJson.Add('shopify_store_code', Rec."Store Code");
        EventBillingClient.RegisterEvent(Rec.SystemId, Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_COUNT, 1, MetadataJson.AsToken());
    end;
#endif
    internal procedure ShowRelatedEntities()
    var
        SalesHeader: Record "Sales Header";
        TempSpfyRelatedDocument: Record "NPR Spfy Related Document" temporary;
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
#endif
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                    if SpfyEcomSalesDocPrcssr.FindIncomingEcommerceDocument(Rec) then begin
                        case true of
                            Rec."Document Type" = "Document Type"::Order:
                                TempSpfyRelatedDocument."Document Type" := TempSpfyRelatedDocument."Document Type"::"Incoming Ecommerce Order";
                            Rec."Document Type" = "Document Type"::"Return Order":
                                TempSpfyRelatedDocument."Document Type" := TempSpfyRelatedDocument."Document Type"::"Incoming Ecommerce Return Order";
                        end;
#pragma warning disable AA0139
                        TempSpfyRelatedDocument."Document No." := Rec."Shopify ID";
#pragma warning restore AA0139
                        if not TempSpfyRelatedDocument.Find() then
                            TempSpfyRelatedDocument.Insert();
                    end;
#endif
                    if TempSpfyRelatedDocument.IsEmpty() then
                        Error(NoRelatedDocsFoundErr);
                    Page.RunModal(0, TempSpfyRelatedDocument);
                end;
        end;
    end;
}
#endif