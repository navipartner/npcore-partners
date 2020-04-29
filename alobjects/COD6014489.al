codeunit 6014489 "Vendor Return Reason"
{
    // Vendor Return Reason specific Codeunit
    //   Work started by Jerome Cader 17-02-2010.
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // CreatePurchOrder(AuditRoll : Record "Audit Roll") : Boolean
    //   Creates a Purchase Order based on a an Audit roll line of type Item
    // 
    // CreatePurchHeader(VAR PurchaseHeader : Record "Purchase Header";AuditRoll : Record "Audit Roll")
    //   Creates a Purchase Order for a single Sales Ticket and single Vendor found in Return Reason
    // 
    // CreatePurchLines(PurchaseHeader : Record "Purchase Header";AuditRoll : Record "Audit Roll")
    //   Creates the Purchase lines for a single Sales Ticket and single Vendor and uses all
    //   the audit roll lines that matches Sales Ticket and Vendor in order to create a single
    //   Purchase Order for a specific vendor.
    // 
    // TvungenRetur(Err : Boolean;VAR "Return Reason" : Record "Return Reason") : Boolean
    //   Form to choose a Return Reason code. Moved from F6014403 Sale POS - Sales Lines
    // 
    // NPR5.38/MHA /20180105  CASE 301053 Deleted deprecated function TvungenRetur()


    trigger OnRun()
    begin
    end;

    procedure CreateRetPurchOrder(AuditRoll: Record "Audit Roll Posting"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ReturnReason: Record "Return Reason";
    begin
        if (AuditRoll.Vendor = '') or (AuditRoll.Type <> AuditRoll.Type::Item) or
           (AuditRoll.Quantity > 0) then
          exit(false);
        
        if AuditRoll."Return Reason Code" = '' then
          exit(false);
        
        /*
        ReturnReason.SETRANGE(Vendor, AuditRoll.Vendor);
        IF ReturnReason.COUNT = 0 THEN
          EXIT(FALSE);
        */
        
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SetRange("Order Date", Today);
        PurchaseHeader.SetRange("Your Reference", AuditRoll."Sales Ticket No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", AuditRoll.Vendor);
        if PurchaseHeader.Count > 0 then begin
          //MESSAGE('Return order exists on this Sales Ticket');
          exit(false);
        end;
        
        CreateRetPurchHeader(PurchaseHeader, AuditRoll);
        CreateRetPurchLines(PurchaseHeader, AuditRoll);
        exit(true);

    end;

    procedure CreateRetPurchHeader(var PurchaseHeader: Record "Purchase Header";AuditRoll: Record "Audit Roll Posting")
    begin
        PurchaseHeader.Init;
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader.Validate("Buy-from Vendor No.", AuditRoll.Vendor);
        PurchaseHeader.Validate("Posting Date", Today);
        PurchaseHeader.Validate("Order Date", Today);
        PurchaseHeader."Your Reference" := AuditRoll."Sales Ticket No.";
        PurchaseHeader."Purchaser Code" := AuditRoll."Salesperson Code";

        PurchaseHeader.Insert(true);
    end;

    procedure CreateRetPurchLines(PurchaseHeader: Record "Purchase Header";AuditRoll: Record "Audit Roll Posting")
    var
        PurchaseLine: Record "Purchase Line";
        AuditRollTemp: Record "Audit Roll";
    begin
        AuditRollTemp.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollTemp.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRollTemp.SetRange("Sale Date", AuditRoll."Sale Date" );
        AuditRollTemp.SetRange(Type, AuditRollTemp.Type::Item);
        AuditRollTemp.SetRange(Vendor, AuditRoll.Vendor);
        AuditRollTemp.SetFilter(Quantity, '<0');

        if AuditRollTemp.Find('-') then repeat

          PurchaseLine.Init;
          PurchaseLine."Document Type" := PurchaseHeader."Document Type";
          PurchaseLine."Document No." := PurchaseHeader."No.";
          PurchaseLine."Line No."     := AuditRollTemp."Line No.";
          PurchaseLine.Type := PurchaseLine.Type::Item;
          PurchaseLine.Color := AuditRollTemp.Color;
          PurchaseLine.Size  := AuditRollTemp.Size;
          PurchaseLine.Validate("No.", AuditRollTemp."No.");
          PurchaseLine.Validate(Quantity, -AuditRollTemp.Quantity);
          PurchaseLine."Return Reason Code" := AuditRollTemp."Return Reason Code";

          PurchaseLine.Insert(true);

        until AuditRollTemp.Next = 0;
    end;
}

