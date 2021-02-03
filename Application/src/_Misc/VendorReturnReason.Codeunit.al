codeunit 6014489 "NPR Vendor Return Reason"
{
    procedure CreateRetPurchOrder(AuditRoll: Record "NPR Audit Roll Posting"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ReturnReason: Record "Return Reason";
    begin
        if (AuditRoll.Vendor = '') or (AuditRoll.Type <> AuditRoll.Type::Item) or
           (AuditRoll.Quantity > 0) then
            exit(false);

        if AuditRoll."Return Reason Code" = '' then
            exit(false);

        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SetRange("Order Date", Today);
        PurchaseHeader.SetRange("Your Reference", AuditRoll."Sales Ticket No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", AuditRoll.Vendor);
        if PurchaseHeader.Count > 0 then
            exit(false);

        CreateRetPurchHeader(PurchaseHeader, AuditRoll);
        CreateRetPurchLines(PurchaseHeader, AuditRoll);
        exit(true);
    end;

    procedure CreateRetPurchHeader(var PurchaseHeader: Record "Purchase Header"; AuditRoll: Record "NPR Audit Roll Posting")
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader.Validate("Buy-from Vendor No.", AuditRoll.Vendor);
        PurchaseHeader.Validate("Posting Date", Today);
        PurchaseHeader.Validate("Order Date", Today);
        PurchaseHeader."Your Reference" := AuditRoll."Sales Ticket No.";
        PurchaseHeader."Purchaser Code" := AuditRoll."Salesperson Code";
        PurchaseHeader.Insert(true);
    end;

    procedure CreateRetPurchLines(PurchaseHeader: Record "Purchase Header"; AuditRoll: Record "NPR Audit Roll Posting")
    var
        AuditRollTemp: Record "NPR Audit Roll";
        PurchaseLine: Record "Purchase Line";
    begin
        AuditRollTemp.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollTemp.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRollTemp.SetRange("Sale Date", AuditRoll."Sale Date");
        AuditRollTemp.SetRange(Type, AuditRollTemp.Type::Item);
        AuditRollTemp.SetRange(Vendor, AuditRoll.Vendor);
        AuditRollTemp.SetFilter(Quantity, '<0');
        if AuditRollTemp.Find('-') then
            repeat
                PurchaseLine.Init();
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := AuditRollTemp."Line No.";
                PurchaseLine.Type := PurchaseLine.Type::Item;
                PurchaseLine."NPR Color" := AuditRollTemp.Color;
                PurchaseLine."NPR Size" := AuditRollTemp.Size;
                PurchaseLine.Validate("No.", AuditRollTemp."No.");
                PurchaseLine.Validate(Quantity, -AuditRollTemp.Quantity);
                PurchaseLine."Return Reason Code" := AuditRollTemp."Return Reason Code";
                PurchaseLine.Insert(true);
            until AuditRollTemp.Next() = 0;
    end;
}

