codeunit 6014486 "IC - Map ICR Barcodes"
{
    // NPR5.46/JDH /2011101 CASE 324997 Codeunit to get the item cross reference and send it to the IC Partner
    // #361679/BHR /20190718 CASE 361679 Change publisher on subscriber OnICOutboxTransactionCreated from ICOutboxTransactionCreated to OnInsertICOutboxSalesDocTransaction


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnInsertICOutboxSalesDocTransaction', '', false, false)]
    local procedure OnICOutboxTransactionCreated(var ICOutboxTransaction: Record "IC Outbox Transaction")
    begin
        case ICOutboxTransaction."Source Type" of
            ICOutboxTransaction."Source Type"::"Journal Line":
                begin
                    exit; //doesnt have anything to do with Items (no ICR support)
                end;
            ICOutboxTransaction."Source Type"::"Purchase Document":
                begin
                    FindTransactionLinesPurchase(ICOutboxTransaction);
                end;
            ICOutboxTransaction."Source Type"::"Sales Document":
                begin
                    FindTransactionLinesSale(ICOutboxTransaction);
                end;
        end;
    end;

    local procedure FindTransactionLinesSale(ICOutboxTransaction: Record "IC Outbox Transaction")
    var
        ICOutboxSalesLine: Record "IC Outbox Sales Line";
    begin
        ICOutboxSalesLine.SetRange("IC Transaction No.", ICOutboxTransaction."Transaction No.");
        ICOutboxSalesLine.SetRange("IC Partner Code", ICOutboxTransaction."IC Partner Code");
        ICOutboxSalesLine.SetRange("Transaction Source", ICOutboxTransaction."Transaction Source");
        if ICOutboxSalesLine.FindSet then
            repeat
                AddICRSale(ICOutboxSalesLine);
            until ICOutboxSalesLine.Next = 0;
    end;

    local procedure FindTransactionLinesPurchase(ICOutboxTransaction: Record "IC Outbox Transaction")
    var
        ICOutboxPurchaseLine: Record "IC Outbox Purchase Line";
    begin
        ICOutboxPurchaseLine.SetRange("IC Transaction No.", ICOutboxTransaction."Transaction No.");
        ICOutboxPurchaseLine.SetRange("IC Partner Code", ICOutboxTransaction."IC Partner Code");
        ICOutboxPurchaseLine.SetRange("Transaction Source", ICOutboxTransaction."Transaction Source");
        if ICOutboxPurchaseLine.FindSet then
            repeat
                AddICRPurchase(ICOutboxPurchaseLine);
            until ICOutboxPurchaseLine.Next = 0;
    end;

    local procedure AddICRSale(ICOutboxSalesLine: Record "IC Outbox Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        if ICOutboxSalesLine."IC Partner Ref. Type" <> ICOutboxSalesLine."IC Partner Ref. Type"::"Cross reference" then
            exit;

        case ICOutboxSalesLine."Document Type" of
            ICOutboxSalesLine."Document Type"::Order:
                if not SalesLine.Get(SalesLine."Document Type"::Order, ICOutboxSalesLine."Document No.", ICOutboxSalesLine."Line No.") then
                    exit;
            ICOutboxSalesLine."Document Type"::Invoice:
                if not SalesLine.Get(SalesLine."Document Type"::Invoice, ICOutboxSalesLine."Document No.", ICOutboxSalesLine."Line No.") then
                    exit;
            ICOutboxSalesLine."Document Type"::"Credit Memo":
                if not SalesLine.Get(SalesLine."Document Type"::"Credit Memo", ICOutboxSalesLine."Document No.", ICOutboxSalesLine."Line No.") then
                    exit;
            ICOutboxSalesLine."Document Type"::"Return Order":
                if not SalesLine.Get(SalesLine."Document Type"::"Return Order", ICOutboxSalesLine."Document No.", ICOutboxSalesLine."Line No.") then
                    exit;
        end;

        if (ICOutboxSalesLine."IC Partner Reference" <> '') and (ICOutboxSalesLine."IC Partner Reference" <> SalesLine."No.") then
            exit;

        ICOutboxSalesLine."IC Partner Reference" := GetICR(SalesLine."No.", SalesLine."Variant Code");
        if ICOutboxSalesLine."IC Partner Reference" <> '' then
            ICOutboxSalesLine.Modify;
    end;

    local procedure AddICRPurchase(ICOutboxPurchaseLine: Record "IC Outbox Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if ICOutboxPurchaseLine."IC Partner Ref. Type" <> ICOutboxPurchaseLine."IC Partner Ref. Type"::"Cross reference" then
            exit;

        case ICOutboxPurchaseLine."Document Type" of
            ICOutboxPurchaseLine."Document Type"::Order:
                if not PurchaseLine.Get(PurchaseLine."Document Type"::Order, ICOutboxPurchaseLine."Document No.", ICOutboxPurchaseLine."Line No.") then
                    exit;
            ICOutboxPurchaseLine."Document Type"::Invoice:
                if not PurchaseLine.Get(PurchaseLine."Document Type"::Invoice, ICOutboxPurchaseLine."Document No.", ICOutboxPurchaseLine."Line No.") then
                    exit;
            ICOutboxPurchaseLine."Document Type"::"Credit Memo":
                if not PurchaseLine.Get(PurchaseLine."Document Type"::"Credit Memo", ICOutboxPurchaseLine."Document No.", ICOutboxPurchaseLine."Line No.") then
                    exit;
            ICOutboxPurchaseLine."Document Type"::"Return Order":
                if not PurchaseLine.Get(PurchaseLine."Document Type"::"Return Order", ICOutboxPurchaseLine."Document No.", ICOutboxPurchaseLine."Line No.") then
                    exit;
        end;

        if (ICOutboxPurchaseLine."IC Partner Reference" <> '') and (ICOutboxPurchaseLine."IC Partner Reference" <> PurchaseLine."No.") then
            exit;

        ICOutboxPurchaseLine."IC Partner Reference" := GetICR(PurchaseLine."No.", PurchaseLine."Variant Code");
        if ICOutboxPurchaseLine."IC Partner Reference" <> '' then
            ICOutboxPurchaseLine.Modify;
    end;

    local procedure GetICR(ItemNo: Code[20]; VariantCode: Code[10]): Code[20]
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ItemCrossReference.SetRange("Item No.", ItemNo);
        ItemCrossReference.SetRange("Variant Code", VariantCode);
        ItemCrossReference.SetRange("Discontinue Bar Code", false);
        if ItemCrossReference.FindFirst then
            exit(ItemCrossReference."Cross-Reference No.");

        ItemCrossReference.SetRange("Discontinue Bar Code");
        if ItemCrossReference.FindFirst then
            exit(ItemCrossReference."Cross-Reference No.");
    end;
}

