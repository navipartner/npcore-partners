codeunit 6150616 "NPR POS Post Item Entries"
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        ItemJournalLine: Record "Item Journal Line";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        OnBeforePostPOSEntry(Rec);

        POSEntry := Rec;

        UpdateDates(POSEntry);
        if GenJnlCheckLine.DateNotAllowed(POSEntry."Posting Date") then
            POSEntry.FieldError("Posting Date", TextDateNotAllowed);
        if POSEntry."Post Item Entry Status" = POSEntry."Post Entry Status"::Posted then
            Error(TextAllreadyPosted, POSEntry."Entry No.");

        CheckPostingrestrictions(POSEntry);

        POSSalesLine.Reset();
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetFilter(Quantity, '<>0');
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet() then
            repeat
                PostItemJnlLine(POSEntry, POSSalesLine, ItemJournalLine);
                POSSalesLine."Item Entry No." := ItemJournalLine."Item Shpt. Entry No.";
                POSSalesLine."Vendor No." := ItemJournalLine."NPR Vendor No.";
                POSSalesLine.Modify();

                CreateDeleteServiceItem(POSEntry, POSSalesLine);
            until POSSalesLine.Next() = 0;

        OnAfterPostPOSEntry(Rec);
    end;

    var
        Location: Record Location;
        _PostingDate: Date;
        _ReplaceDates: Boolean;
        _ReplacePostingDate: Boolean;
        _ReplaceDocumentDate: Boolean;
        TextCustomerBlocked: Label 'Customer is blocked.';
        TextDateNotAllowed: Label 'is not within your range of allowed posting dates.';
        TextAllreadyPosted: Label 'Item Ledger Entries allready posted for POS Entry %1.';

    procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        _ReplaceDates := true;
        _ReplacePostingDate := NewReplacePostingDate;
        _ReplaceDocumentDate := NewReplaceDocumentDate;
        _PostingDate := NewPostingDate;
    end;

    local procedure CheckPostingrestrictions(POSEntryToCheck: Record "NPR POS Entry")
    var
        Customer: Record Customer;
    begin
        OnCheckPostingRestrictions(POSEntryToCheck);
        if POSEntryToCheck."Customer No." <> '' then begin
            Customer.Get(POSEntryToCheck."Customer No.");
            if Customer.Blocked = Customer.Blocked::All then
                Error(TextCustomerBlocked);
        end;
    end;

    local procedure PostItemJnlLine(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line"; var ItemJnlLine: Record "Item Journal Line")
    var
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Item: Record Item;
        POSPeriodRegister: Record "NPR POS Period Register";
        TempWhseJnlLine: Record "Warehouse Journal Line" temporary;
        TempWhseTrackingSpecification: Record "Tracking Specification" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WMSManagement: Codeunit "WMS Management";
        POSPostILEPublicAccess: Codeunit "NPR POS Post ILE Public Access";
        PostWhseJnlLine: Boolean;
    begin
        Clear(ItemJnlLine);
        OnBeforePostPOSSalesLineItemJnl(POSSalesLine);

        if POSSalesLine."Withhold Item" and (POSSalesLine."Move to Location" = '') then
            exit;

        POSPeriodRegister.Get(POSEntry."POS Period Register No.");

        POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);
        ItemJnlLine.Init();
        ItemJnlLine."Posting Date" := POSEntry."Posting Date";
        ItemJnlLine."Document Date" := POSEntry."Document Date";
        if (POSPostingProfile."Item Ledger Document No." = POSPostingProfile."Item Ledger Document No."::"POS Period Register") and
           (POSPeriodRegister."Document No." <> '')
        then
            ItemJnlLine."Document No." := POSPeriodRegister."Document No."
        else
            ItemJnlLine."Document No." := POSEntry."Document No.";
        ItemJnlLine."Source Posting Group" := POSEntry."Customer Posting Group";
        ItemJnlLine."Salespers./Purch. Code" := POSEntry."Salesperson Code";
        ItemJnlLine."Country/Region Code" := POSEntry."Country/Region Code";
        if POSSalesLine."Reason Code" <> '' then
            ItemJnlLine."Reason Code" := POSSalesLine."Reason Code"
        else
            ItemJnlLine."Reason Code" := POSEntry."Reason Code";
        ItemJnlLine."Item No." := POSSalesLine."No.";
        ItemJnlLine.Description := CopyStr(POSSalesLine.Description, 1, MaxStrLen(ItemJnlLine.Description));
        ItemJnlLine."Shortcut Dimension 1 Code" := POSSalesLine."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := POSSalesLine."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := POSSalesLine."Dimension Set ID";
        if POSSalesLine."Location Code" = '' then
            POSSalesLine."Location Code" := POSStore."Location Code";
        ItemJnlLine."Location Code" := POSSalesLine."Location Code";
        if POSSalesLine."Bin Code" = '' then begin
            GetLocation(POSSalesLine."Location Code");
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                WMSManagement.GetDefaultBin(POSSalesLine."No.", POSSalesLine."Variant Code", POSSalesLine."Location Code", POSSalesLine."Bin Code");
        end;
        ItemJnlLine."Bin Code" := POSSalesLine."Bin Code";
        ItemJnlLine."Variant Code" := POSSalesLine."Variant Code";
        ItemJnlLine."Inventory Posting Group" := POSSalesLine."Posting Group";
        ItemJnlLine."Gen. Bus. Posting Group" := POSSalesLine."Gen. Bus. Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := POSSalesLine."Gen. Prod. Posting Group";
        ItemJnlLine."Applies-to Entry" := POSSalesLine."Appl.-to Item Entry";
        ItemJnlLine."Transaction Type" := POSEntry."Transaction Type";
        ItemJnlLine."Transport Method" := POSEntry."Transport Method";
        ItemJnlLine."Entry/Exit Point" := POSEntry."Exit Point";
        ItemJnlLine.Area := POSEntry.Area;
        ItemJnlLine."Transaction Specification" := POSEntry."Transaction Specification";
        if POSSalesLine."Withhold Item" then begin
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
            GetLocation(POSSalesLine."Move to Location");
            ItemJnlLine."New Location Code" := Location.Code;
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                WMSManagement.GetDefaultBin(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."New Location Code", ItemJnlLine."New Bin Code");
        end else
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Sale;
        ItemJnlLine."Unit of Measure Code" := POSSalesLine."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := POSSalesLine."Qty. per Unit of Measure";
        ItemJnlLine."Item Reference No." := POSSalesLine."Cross-Reference No.";
        ItemJnlLine."Originally Ordered No." := POSSalesLine."Originally Ordered No.";
        ItemJnlLine."Originally Ordered Var. Code" := POSSalesLine."Originally Ordered Var. Code";
        ItemJnlLine."Out-of-Stock Substitution" := POSSalesLine."Out-of-Stock Substitution";
        ItemJnlLine."Item Category Code" := POSSalesLine."Item Category Code";
        ItemJnlLine.Nonstock := POSSalesLine.Nonstock;
        ItemJnlLine."Return Reason Code" := POSSalesLine."Return Reason Code";
        ItemJnlLine."Planned Delivery Date" := POSSalesLine."Planned Delivery Date";
        ItemJnlLine."Order Date" := POSEntry."Entry Date";
        ItemJnlLine."NPR Document Time" := POSEntry."Ending Time";
        ItemJnlLine."Serial No." := POSSalesLine."Serial No.";
        ItemJnlLine."Lot No." := POSSalesLine."Lot No.";
        ItemJnlLine."Document Line No." := POSSalesLine."Line No.";
        ItemJnlLine.Quantity := POSSalesLine.Quantity;
        ItemJnlLine."Quantity (Base)" := POSSalesLine."Quantity (Base)";
        ItemJnlLine."Invoiced Quantity" := POSSalesLine.Quantity;
        ItemJnlLine."Invoiced Qty. (Base)" := POSSalesLine."Quantity (Base)";
        ItemJnlLine."Unit Cost" := POSSalesLine."Unit Cost (LCY)";
        ItemJnlLine."Source Currency Code" := POSEntry."Currency Code";
        ItemJnlLine."Unit Cost (ACY)" := POSSalesLine."Unit Cost";
        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
        ItemJnlLine.Amount := POSSalesLine."Amount Excl. VAT";
        if POSEntry."Prices Including VAT" then
            ItemJnlLine."Discount Amount" :=
              POSSalesLine."Line Discount Amount Incl. VAT" / (1 + POSSalesLine."VAT %" / 100)
        else
            ItemJnlLine."Discount Amount" := POSSalesLine."Line Discount Amount Excl. VAT";
        ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
        ItemJnlLine."Source No." := POSSalesLine."Customer No.";
        ItemJnlLine."Invoice-to Source No." := POSSalesLine."Customer No.";
        ItemJnlLine."Source Code" := POSPostingProfile."Source Code";
        InsertTrackingLine(ItemJnlLine);
        ItemJnlLine."Serial No." := '';
        ItemJnlLine."Lot No." := '';
        ItemJnlLine."NPR Discount Type" := POSSalesLine."Discount Type";
#pragma warning disable AA0139 
        ItemJnlLine."NPR Discount Code" := POSSalesLine."Discount Code";
#pragma warning restore AA0139
        ItemJnlLine."NPR Register Number" := POSEntry."POS Unit No.";
        if Item.Get(POSSalesLine."No.") then
            ItemJnlLine."NPR Vendor No." := Item."Vendor No.";

        if (POSSalesLine."Location Code" <> '') and (POSSalesLine.Type = POSSalesLine.Type::Item) and (ItemJnlLine.Quantity <> 0) then
            if ShouldPostWhseJnlLine(POSSalesLine) then begin
                CreateWhseJnlLine(ItemJnlLine, POSSalesLine, TempWhseJnlLine);
                PostWhseJnlLine := true;
            end;

        POSPostILEPublicAccess.OnAfterCreateItemJournalLine(POSEntry, POSSalesLine, ItemJnlLine);

        if not ((ItemJnlLine."Journal Template Name" = '') and (ItemJnlLine."Journal Batch Name" = '')) then
            exit;

        if not ItemJnlPostLine.RunWithCheck(ItemJnlLine) then
            ItemJnlPostLine.CheckItemTracking();
        if PostWhseJnlLine then begin
            CollectWhseJnlLineTracking(ItemJnlPostLine, TempWhseJnlLine, TempWhseTrackingSpecification);
            POSPostWhseJnlLine(TempWhseJnlLine, TempWhseTrackingSpecification);
        end;
    end;

    local procedure InsertTrackingLine(var ItemJournalLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if (ItemJournalLine."Serial No." = '') and (ItemJournalLine."Lot No." = '') then
            exit;
        Item.Get(ItemJournalLine."Item No.");
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        ReservationEntry.Init();
        ReservationEntry."Entry No." := 0;
        ReservationEntry.Positive := false;
        ReservationEntry."Item No." := ItemJournalLine."Item No.";
        ReservationEntry."Variant Code" := ItemJournalLine."Variant Code";
        ReservationEntry."Location Code" := ItemJournalLine."Location Code";
        ReservationEntry."Quantity (Base)" := -ItemJournalLine.Quantity;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        if ItemTrackingCode."SN Specific Tracking" then begin
            if (ItemJournalLine.Quantity <= 0) then begin
                //Return Sale
                ReservationEntry."Creation Date" := Today();
            end else begin
                //Normal Sale
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.");
                ItemLedgerEntry.SetRange("Item No.", ItemJournalLine."Item No.");
                ItemLedgerEntry.SetRange(Open, true);
                ItemLedgerEntry.SetRange("Variant Code", ItemJournalLine."Variant Code");
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.SetRange("Serial No.", ItemJournalLine."Serial No.");
                ItemLedgerEntry.FindFirst();
                ReservationEntry."Creation Date" := ItemLedgerEntry."Posting Date";
            end;
        end else begin
            if ItemJournalLine.Quantity <= 0 then begin
                ReservationEntry."Creation Date" := Today();
            end;
        end;
        ReservationEntry."Source Type" := DATABASE::"Item Journal Line";
        ReservationEntry."Source Subtype" := ItemJournalLine."Entry Type".AsInteger();
        ReservationEntry."Source ID" := ItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJournalLine."Line No.";
        ReservationEntry."Expected Receipt Date" := Today();
        ReservationEntry."Serial No." := ItemJournalLine."Serial No.";
        ReservationEntry."Lot No." := ItemJournalLine."Lot No.";
        ReservationEntry."Created By" := CopyStr(UserId, 1, MaxStrLen(ReservationEntry."Created By"));
        ReservationEntry."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := -ItemJournalLine.Quantity;
        ReservationEntry."Qty. to Handle (Base)" := -ItemJournalLine.Quantity;
        ReservationEntry."Qty. to Invoice (Base)" := -ItemJournalLine.Quantity;
        ReservationEntry.Insert();
    end;

    local procedure ShouldPostWhseJnlLine(POSSalesLine: Record "NPR POS Entry Sales Line") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeShouldPostWhseJnlLine(POSSalesLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if POSSalesLine.IsInventoriableItem() then begin
            GetLocation(POSSalesLine."Location Code");
            exit(not Location."NPR No Whse. Entr. for POS" and (Location."Directed Put-away and Pick" or Location."Bin Mandatory"));
        end;
        exit(false);
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.GetLocationSetup(LocationCode, Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure CreateWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; POSSalesLine: Record "NPR POS Entry Sales Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    var
        WhseMgt: Codeunit "Whse. Management";
        WMSMgt: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateWhseJnlLine(POSSalesLine, ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        GetLocation(POSSalesLine."Location Code");
        WMSMgt.CheckAdjmtBin(Location, ItemJnlLine.Quantity, true);
        WMSMgt.CreateWhseJnlLine(ItemJnlLine, 0, TempWhseJnlLine, false);
        TempWhseJnlLine."Source Type" := DATABASE::"NPR POS Entry Sales Line";
        TempWhseJnlLine."Source Subtype" := 0;
        TempWhseJnlLine."Source Code" := ItemJnlLine."Source Code";
        TempWhseJnlLine."Source Document" := WhseMgt.GetWhseJnlSourceDocument(TempWhseJnlLine."Source Type", TempWhseJnlLine."Source Subtype");
        TempWhseJnlLine."Source No." := Format(POSSalesLine."POS Entry No.");
        TempWhseJnlLine."Source Line No." := POSSalesLine."Line No.";
        TempWhseJnlLine."Reference Document" := TempWhseJnlLine."Reference Document"::" ";
        TempWhseJnlLine."Reference No." := POSSalesLine."Document No.";

        OnAfterCreateWhseJnlLine(POSSalesLine, TempWhseJnlLine);
    end;

    local procedure CollectWhseJnlLineTracking(ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; WhseJnlLine: Record "Warehouse Journal Line"; var WhseTrackingSpecification: Record "Tracking Specification")
    var
        TempTrackingSpec: Record "Tracking Specification" temporary;
    begin
        if ItemJnlPostLine.CollectTrackingSpecification(TempTrackingSpec) then
            if TempTrackingSpec.FindSet() then
                repeat
                    WhseTrackingSpecification := TempTrackingSpec;
                    WhseTrackingSpecification.SetSource(WhseJnlLine."Source Type", -1, WhseJnlLine."Source No.", WhseJnlLine."Source Line No.", '', 0);
                    if WhseTrackingSpecification.Insert() then;
                until TempTrackingSpec.Next() = 0;
    end;

    local procedure POSPostWhseJnlLine(WhseJnlLine: Record "Warehouse Journal Line"; var WhseTrackingSpecification: Record "Tracking Specification")
    var
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, WhseTrackingSpecification, false);
        if TempWhseJnlLine2.FindSet() then
            repeat
                WhseJnlPostLine.Run(TempWhseJnlLine2);
            until TempWhseJnlLine2.Next() = 0;
        WhseTrackingSpecification.DeleteAll();
    end;

    local procedure CreateAssemblyOrder(POSEntry: Record "NPR POS Entry"; POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        AssemblyHeader: Record "Assembly Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        CreateAssembly: Boolean;
        CreateAssemblyLink: Boolean;
        AssemblyHeaderLbl: Label '%1: %2 - %3', Locked = true;
    begin
        if not IsAsmToOrderRequired(POSSalesLine) then
            exit;

        CreateAssembly := true;
        CreateAssemblyLink := true;

        POSEntrySalesDocLink.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Type", '=%1', POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Line No.", '=%1', POSSalesLine."Line No.");
        POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER);
        if (not POSEntrySalesDocLink.IsEmpty()) then
            exit; // assembly was already posted for this line

        POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::ASSEMBLY_ORDER);
        if (POSEntrySalesDocLink.FindFirst()) then begin
            CreateAssemblyLink := false;
            CreateAssembly := (not AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No"));
        end;

        if (CreateAssembly) then begin
            AssemblyHeader.Init();
            AssemblyHeader.Validate("Document Type", AssemblyHeader."Document Type"::Order);
            AssemblyHeader.Insert(true);

            AssemblyHeader.Validate("Posting Date", POSEntry."Posting Date");
            AssemblyHeader.Validate("Item No.", POSSalesLine."No.");
            AssemblyHeader.Validate("Variant Code", POSSalesLine."Variant Code");
            AssemblyHeader.Validate("Location Code", POSSalesLine."Location Code");
            AssemblyHeader.Validate(Quantity, POSSalesLine.Quantity);
            AssemblyHeader."Description 2" := StrSubstNo(AssemblyHeaderLbl, POSEntry."Entry No.", POSEntry."Document No.", POSSalesLine."Line No.");
            AssemblyHeader."Posting No." := AssemblyHeader."No.";
            AssemblyHeader.Modify(true);
        end;

        if (CreateAssemblyLink) then begin
            POSEntrySalesDocLink."POS Entry No." := POSEntry."Entry No.";
            POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
            POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::ASSEMBLY_ORDER;
            POSEntrySalesDocLink."Sales Document No" := AssemblyHeader."No.";
            POSEntrySalesDocLink.Insert();
        end;

        if ((not CreateAssemblyLink) and (CreateAssembly)) then begin
            if (POSEntrySalesDocLink."Sales Document No" <> AssemblyHeader."No.") then begin
                POSEntrySalesDocLink.Delete();
                POSEntrySalesDocLink."Sales Document No" := AssemblyHeader."No.";
                POSEntrySalesDocLink.Insert();
            end;
        end;
        Commit();
    end;

    local procedure PostAssemblyOrder(POSEntry: Record "NPR POS Entry"; POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        AssemblyHeader: Record "Assembly Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        AssemblyPost: Codeunit "Assembly-Post";
    begin
        if not IsAsmToOrderRequired(POSSalesLine) then
            exit;

        POSEntrySalesDocLink.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Type", '=%1', POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Line No.", '=%1', POSSalesLine."Line No.");
        POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER);
        if (not POSEntrySalesDocLink.IsEmpty()) then
            exit; // assembly was already posted for this line

        POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::ASSEMBLY_ORDER);
        POSEntrySalesDocLink.FindFirst();
        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");

        AssemblyPost.SetSuppressCommit(true);
        AssemblyPost.Run(AssemblyHeader);

        POSEntrySalesDocLink.Delete();
        POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER;
        if (AssemblyHeader."Posting No." <> '') then
            POSEntrySalesDocLink."Sales Document No" := AssemblyHeader."Posting No.";
        if (not POSEntrySalesDocLink.Insert()) then;
    end;

    local procedure CreateDeleteServiceItem(POSEntry: Record "NPR POS Entry"; POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        CreateServiceItem: codeunit "NPR Create Service Item";
    begin
        CreateServiceItem.CreateDeleteServiceItem(POSEntry, POSSalesLine);
    end;

    procedure CreateAssemblyOrders(POSEntry: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        Asm_FilterPOSSalesLine(POSEntry, POSSalesLine);
        if POSSalesLine.FindSet() then
            repeat
                // Assembly order creation is committed
                CreateAssemblyOrder(POSEntry, POSSalesLine);
            until (POSSalesLine.Next() = 0);
    end;

    procedure PostAssemblyOrders(POSEntry: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        Asm_FilterPOSSalesLine(POSEntry, POSSalesLine);
        if POSSalesLine.FindSet() then
            repeat
                PostAssemblyOrder(POSEntry, POSSalesLine);
            until (POSSalesLine.Next() = 0);
    end;

    local procedure Asm_FilterPOSSalesLine(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
        UpdateDates(POSEntry);

        POSSalesLine.Reset();
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetFilter(Quantity, '>%1', 0);
        POSSalesLine.SetRange("Exclude from Posting", false);
    end;

    local procedure IsAsmToOrderRequired(POSSalesLine: Record "NPR POS Entry Sales Line"): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsAsmToOrderRequired(POSSalesLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if (POSSalesLine.Type <> POSSalesLine.Type::Item) or
           (POSSalesLine."No." = '') or
           (POSSalesLine.Quantity <= 0)
        then
            exit(false);

        exit(IsAsmToOrderRequired(POSSalesLine."No.", POSSalesLine."Variant Code", POSSalesLine."Location Code"));
    end;

    procedure IsAsmToOrderRequired(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]): Boolean
    var
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if StockkeepingUnit.Get(LocationCode, ItemNo, VariantCode) then
            exit(
                (StockkeepingUnit."Replenishment System" = StockkeepingUnit."Replenishment System"::Assembly) and
                (StockkeepingUnit."Assembly Policy" = StockkeepingUnit."Assembly Policy"::"Assemble-to-Order"));

        Item.Get(ItemNo);
        exit(
            (Item."Replenishment System" = Item."Replenishment System"::Assembly) and
            (Item."Assembly Policy" = Item."Assembly Policy"::"Assemble-to-Order"));
    end;

    local procedure UpdateDates(var POSEntry: Record "NPR POS Entry")
    begin
        if not _ReplaceDates or (_PostingDate = 0D) then
            exit;
        if _ReplacePostingDate or (POSEntry."Posting Date" = 0D) then begin
            POSEntry."Posting Date" := _PostingDate;
            POSEntry.Validate("Currency Code");
        end;
        if _ReplaceDocumentDate or (POSEntry."Document Date" = 0D) then
            POSEntry.Validate("Document Date", _PostingDate);
    end;

#IF NOT (BC17 or BC18 or BC19 or BC20)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Management", 'OnAfterGetSourceDocumentType', '', false, false)]
    local procedure GetPOSRelatedSourceDocumentType(SourceType: Integer; SourceSubtype: Integer; var SourceDocument: Enum "Warehouse Journal Source Document"; var IsHandled: Boolean)
    begin
        if IsHandled or
           not (SourceType in [Database::"NPR POS Entry Sales Line"])
        then
            exit;

        IsHandled := true;

        case SourceType of
            Database::"NPR POS Entry Sales Line":
                SourceDocument := "Warehouse Journal Source Document"::"NPR POS Entry";
        end;
    end;
#ENDIF
#IF (BC17 or BC18 or BC19 or BC20)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Management", 'OnAfterGetSourceDocument', '', false, false)]
    local procedure GetPOSRelatedSourceDocument(SourceType: Integer; SourceSubtype: Integer; var SourceDocument: Option; var IsHandled: Boolean)
    begin
        if IsHandled or
           not (SourceType in [Database::"NPR POS Entry Sales Line"])
        then
            exit;

        IsHandled := true;

        case SourceType of
            Database::"NPR POS Entry Sales Line":
                SourceDocument := "Warehouse Journal Source Document"::"NPR POS Entry".AsInteger();
        end;
    end;
#ENDIF

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSSalesLineItemJnl(var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsAsmToOrderRequired(POSSalesLine: Record "NPR POS Entry Sales Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShouldPostWhseJnlLine(POSSalesLine: Record "NPR POS Entry Sales Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseJnlLine(POSSalesLine: Record "NPR POS Entry Sales Line"; ItemJnlLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWhseJnlLine(var POSSalesLine: Record "NPR POS Entry Sales Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    begin
    end;
}
