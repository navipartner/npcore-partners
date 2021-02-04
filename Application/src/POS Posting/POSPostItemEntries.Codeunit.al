codeunit 6150616 "NPR POS Post Item Entries"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    var
        POSStore: Record "NPR POS Store";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        TempItemToAdjust: Record Item temporary;
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        AdjustCostItemEntries: Report "Adjust Cost - Item Entries";
        PostInventoryCosttoGL: Report "Post Inventory Cost to G/L";
        FileManagement: Codeunit "File Management";
    begin
        OnBeforePostPOSEntry(Rec);

        POSEntry := Rec;
        with POSEntry do begin
            if not PostToEntries(POSEntry) then
                exit;

            if PostingDateExists and (ReplacePostingDate or ("Posting Date" = 0D)) then begin
                "Posting Date" := PostingDate;
                Validate("Currency Code");
            end;

            if PostingDateExists and (ReplaceDocumentDate or ("Document Date" = 0D)) then
                Validate("Document Date", PostingDate);

            if GenJnlCheckLine.DateNotAllowed("Posting Date") then
                FieldError("Posting Date", TextDateNotAllowed);
            if "Post Item Entry Status" = "Post Entry Status"::Posted then
                Error(StrSubstNo(TextAllreadyPosted, "Entry No."));

            CheckPostingrestrictions(POSEntry);

            POSSalesLine.Reset;
            POSSalesLine.SetRange("POS Entry No.", "Entry No.");
            POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
            POSSalesLine.SetFilter(Quantity, '<>0');
            POSSalesLine.SetRange("Exclude from Posting", false);
            if POSSalesLine.FindSet then
                repeat
                    POSSalesLine."Item Entry No." := PostItemJnlLine(POSEntry, POSSalesLine);
                    POSSalesLine.Modify;

                    CheckAndCreateServiceItemPos(POSEntry, POSSalesLine);

                    if (POSSalesLine."Retail Serial No." <> '') then
                        HandleRetailSerialNo(POSSalesLine);
                until POSSalesLine.Next = 0;
        end;

        OnAfterPostPOSEntry(Rec);
    end;

    var
        PostingDate: Date;
        PostingDateExists: Boolean;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;
        TextCustomerBlocked: Label 'Customer is blocked.';
        TextDateNotAllowed: Label 'is not within your range of allowed posting dates.';
        TextAllreadyPosted: Label 'Item Ledger Entries allready posted for POS Entry %1.';

    procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        PostingDateExists := true;
        ReplacePostingDate := NewReplacePostingDate;
        ReplaceDocumentDate := NewReplaceDocumentDate;
        PostingDate := NewPostingDate;
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

    local procedure PostItemJnlLine(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line"): Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        NPRetailSetup: Record "NPR NP Retail Setup";
        ItemJnlLine: Record "Item Journal Line";
        MoveToLocation: Record Location;
        Item: Record Item;
        POSPeriodRegister: Record "NPR POS Period Register";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        VendorReturnReason: Codeunit "NPR Vendor Return Reason";
        WMSManagement: Codeunit "WMS Management";
    begin
        OnBeforePostPOSSalesLineItemJnl(POSSalesLine);

        if POSSalesLine."Withhold Item" and (POSSalesLine."Move to Location" = '') then
            exit;

        POSPeriodRegister.Get(POSEntry."POS Period Register No.");

        NPRetailSetup.Get;
        with POSSalesLine do begin
            ItemJnlLine.Init;
            ItemJnlLine."Posting Date" := POSEntry."Posting Date";
            ItemJnlLine."Document Date" := POSEntry."Document Date";
            ItemJnlLine."Document No." := POSPeriodRegister."Document No.";
            if (ItemJnlLine."Document No." = '') then
                ItemJnlLine."Document No." := POSEntry."Document No.";
            ItemJnlLine."Source Posting Group" := POSEntry."Customer Posting Group";
            ItemJnlLine."Salespers./Purch. Code" := POSEntry."Salesperson Code";
            ItemJnlLine."Country/Region Code" := POSEntry."Country/Region Code";
            if "Reason Code" <> '' then
                ItemJnlLine."Reason Code" := "Reason Code"
            else
                ItemJnlLine."Reason Code" := POSEntry."Reason Code";
            ItemJnlLine."Item No." := "No.";
            ItemJnlLine.Description := CopyStr(Description, 1, MaxStrLen(ItemJnlLine.Description));
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";
            if "Location Code" = '' then
                "Location Code" := GetPOSUnitLocation(POSEntry."POS Unit No.");
            if "Location Code" = '' then begin
                POSStore.Get(POSEntry."POS Store Code");
                "Location Code" := POSStore."Location Code";
            end;
            ItemJnlLine."Location Code" := "Location Code";
            ItemJnlLine."Bin Code" := "Bin Code";
            ItemJnlLine."Variant Code" := "Variant Code";
            ItemJnlLine."Inventory Posting Group" := "Posting Group";
            ItemJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            ItemJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            ItemJnlLine."Applies-to Entry" := "Appl.-to Item Entry";
            ItemJnlLine."Transaction Type" := POSEntry."Transaction Type";
            ItemJnlLine."Transport Method" := POSEntry."Transport Method";
            ItemJnlLine."Entry/Exit Point" := POSEntry."Exit Point";
            ItemJnlLine.Area := POSEntry.Area;
            ItemJnlLine."Transaction Specification" := POSEntry."Transaction Specification";
            if "Withhold Item" then begin
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                MoveToLocation.Get("Move to Location");
                ItemJnlLine."New Location Code" := MoveToLocation.Code;
                if MoveToLocation."Bin Mandatory" and not MoveToLocation."Directed Put-away and Pick" then
                    WMSManagement.GetDefaultBin(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."New Location Code", ItemJnlLine."New Bin Code");
            end else
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Sale;
            ItemJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            ItemJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            ItemJnlLine."Cross-Reference No." := "Cross-Reference No.";
            ItemJnlLine."Originally Ordered No." := "Originally Ordered No.";
            ItemJnlLine."Originally Ordered Var. Code" := "Originally Ordered Var. Code";
            ItemJnlLine."Out-of-Stock Substitution" := "Out-of-Stock Substitution";
            ItemJnlLine."Item Category Code" := "Item Category Code";
            ItemJnlLine.Nonstock := Nonstock;
            ItemJnlLine."Purchasing Code" := "Product Group Code";
            ItemJnlLine."Return Reason Code" := "Return Reason Code";
            ItemJnlLine."Planned Delivery Date" := "Planned Delivery Date";
            ItemJnlLine."Order Date" := POSEntry."Entry Date";
            ItemJnlLine."NPR Document Time" := POSEntry."Ending Time";
            ItemJnlLine."Serial No." := "Serial No.";
            ItemJnlLine."Lot No." := "Lot No.";
            ItemJnlLine."Document Line No." := "Line No.";
            ItemJnlLine.Quantity := Quantity;
            ItemJnlLine."Quantity (Base)" := "Quantity (Base)";
            ItemJnlLine."Invoiced Quantity" := Quantity;
            ItemJnlLine."Invoiced Qty. (Base)" := "Quantity (Base)";
            ItemJnlLine."Unit Cost" := "Unit Cost (LCY)";
            ItemJnlLine."Source Currency Code" := POSEntry."Currency Code";
            ItemJnlLine."Unit Cost (ACY)" := "Unit Cost";
            ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
            ItemJnlLine.Amount := ("Amount Excl. VAT");
            if POSEntry."Prices Including VAT" then
                ItemJnlLine."Discount Amount" :=
                  (("Line Discount Amount Incl. VAT") / (1 + "VAT %" / 100))
            else
                ItemJnlLine."Discount Amount" :=
                  ("Line Discount Amount Incl. VAT");
            ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
            ItemJnlLine."Source No." := "Customer No.";
            ItemJnlLine."Invoice-to Source No." := "Customer No.";
            ItemJnlLine."Source Code" := NPRetailSetup."Source Code";
            InsertTrackingLine(ItemJnlLine);
            ItemJnlLine."Serial No." := '';
            ItemJnlLine."Lot No." := '';
            ItemJnlLine."NPR Discount Type" := "Discount Type";
            ItemJnlLine."NPR Discount Code" := "Discount Code";
            if Item.Get("No.") then begin
                ItemJnlLine."NPR Item Group No." := Item."NPR Item Group";
                ItemJnlLine."NPR Vendor No." := Item."Vendor No.";
            end;
        end;

        OnAfterCreateItemJournalLine(POSEntry, POSSalesLine, ItemJnlLine);

        if (ItemJnlLine."Journal Template Name" = '') and (ItemJnlLine."Journal Batch Name" = '') then
            ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        exit(ItemJnlLine."Item Shpt. Entry No.");
    end;

    local procedure InsertTrackingLine(var ItemJournalLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        with ItemJournalLine do begin
            if ("Serial No." = '') and ("Lot No." = '') then
                exit;
            Item.Get("Item No.");
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            ReservationEntry.Init;
            ReservationEntry."Entry No." := 0;
            ReservationEntry.Positive := false;
            ReservationEntry."Item No." := "Item No.";
            ReservationEntry."Variant Code" := "Variant Code";
            ReservationEntry."Location Code" := "Location Code";
            ReservationEntry."Quantity (Base)" := -Quantity;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            if ItemTrackingCode."SN Specific Tracking" then begin
                if (Quantity <= 0) then begin
                    //Return Sale
                    ReservationEntry."Creation Date" := Today;
                end else begin
                    //Normal Sale
                    ItemLedgerEntry.Reset;
                    ItemLedgerEntry.SetRange(Open, true);
                    ItemLedgerEntry.SetRange(Positive, true);
                    ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                    ItemLedgerEntry.SetRange("Item No.", "Item No.");
                    ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
                    ItemLedgerEntry.FindFirst;
                    ReservationEntry."Creation Date" := ItemLedgerEntry."Posting Date";
                end;
            end else begin
                if Quantity <= 0 then begin
                    ReservationEntry."Creation Date" := Today;
                end;
            end;
            ReservationEntry."Source Type" := DATABASE::"Item Journal Line";
            ReservationEntry."Source Subtype" := "Entry Type".AsInteger();
            ReservationEntry."Source ID" := "Journal Template Name";
            ReservationEntry."Source Batch Name" := "Journal Batch Name";
            ReservationEntry."Source Ref. No." := "Line No.";
            ReservationEntry."Expected Receipt Date" := Today;
            ReservationEntry."Serial No." := "Serial No.";
            ReservationEntry."Lot No." := "Lot No.";
            ReservationEntry."Created By" := UserId;
            ReservationEntry."Qty. per Unit of Measure" := Quantity;
            ReservationEntry.Quantity := -Quantity;
            ReservationEntry."Qty. to Handle (Base)" := -Quantity;
            ReservationEntry."Qty. to Invoice (Base)" := -Quantity;
            ReservationEntry.Insert;
        end;
    end;

    local procedure PostToEntries(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSStore: Record "NPR POS Store";
    begin
        POSStore.Get(POSEntry."POS Store Code");
        if POSStore."Item Posting" in [POSStore."Item Posting"::"Post on Close Register", POSStore."Item Posting"::"Post On Finalize Sale"] then
            exit(true);
        exit(false);
    end;

    local procedure CheckAndCreateAssemblyOrder(FailOnError: Boolean; POSEntry: Record "NPR POS Entry"; POSSalesLine: Record "NPR POS Sales Line"): Boolean
    var
        Item: Record Item;
        AssemblyHeader: Record "Assembly Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        AssemblySetup: Record "Assembly Setup";
        AssemblyPost: Codeunit "Assembly-Post";
        CreateAssembly: Boolean;
        CreateAssemblyLink: Boolean;
    begin
        if (POSSalesLine.Type <> POSSalesLine.Type::Item) then
            exit(true);

        if (POSSalesLine.Quantity <= 0) then
            exit(true);

        Item.Get(POSSalesLine."No.");
        if (Item."Replenishment System" <> Item."Replenishment System"::Assembly) then
            exit(true);

        if (Item."Assembly Policy" <> Item."Assembly Policy"::"Assemble-to-Order") then
            exit(true);

        CreateAssembly := true;
        CreateAssemblyLink := true;

        POSEntrySalesDocLink.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Type", '=%1', POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetFilter("POS Entry Reference Line No.", '=%1', POSSalesLine."Line No.");
        POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::ASSEMBLY_ORDER);
        if (POSEntrySalesDocLink.FindFirst()) then begin
            CreateAssemblyLink := false;
            CreateAssembly := (not AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No"));

        end else begin
            POSEntrySalesDocLink.SetFilter("Sales Document Type", '=%1', POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER);
            if (not POSEntrySalesDocLink.IsEmpty()) then
                exit(true); // assembly was already posted for this line
        end;

        if (CreateAssembly) then begin
            AssemblyHeader.Init;
            AssemblyHeader.Validate("Document Type", AssemblyHeader."Document Type"::Order);
            AssemblyHeader.Insert(true);
            Commit;

            AssemblyHeader.Validate("Posting Date", POSEntry."Posting Date");
            AssemblyHeader.Validate("Item No.", POSSalesLine."No.");
            AssemblyHeader.Validate("Variant Code", POSSalesLine."Variant Code");
            AssemblyHeader.Validate("Location Code", POSSalesLine."Location Code");
            AssemblyHeader.Validate(Quantity, POSSalesLine.Quantity);
            AssemblyHeader."Description 2" := StrSubstNo('%1: %2 - %3', POSEntry."Entry No.", POSEntry."Document No.", POSSalesLine."Line No.");
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

        // Commit the item posting for POS Sale, before attempting to post assembly order - note: there are commits in the AssemblyPost.RUN ();
        Commit;

        if (AssemblyPost.Run(AssemblyHeader)) then begin
            POSEntrySalesDocLink.Delete();
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER;
            if (AssemblyHeader."Posting No." <> '') then
                POSEntrySalesDocLink."Sales Document No" := AssemblyHeader."Posting No.";
            if (not POSEntrySalesDocLink.Insert()) then;
            Commit;
            exit(true);
        end;

        if (FailOnError) then
            Error(GetLastErrorText);

        exit(false);
    end;

    local procedure CheckAndCreateServiceItemPos(POSEntry: Record "NPR POS Entry"; POSSalesLine: Record "NPR POS Sales Line")
    var
        ServItem: Record "Service Item";
        ServMgtSetup: Record "Service Mgt. Setup";
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ServItemGr: Record "Service Item Group";
        ServItemComponent: Record "Service Item Component";
        BOMComp: Record "BOM Component";
        BOMComp2: Record "BOM Component";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        ServLogMgt: Codeunit ServLogManagement;
        TrackingLinesExist: Boolean;
        ServItemWithSerialNoExist: Boolean;
        x: Integer;
        y: Integer;
        NextLineNo: Integer;
    begin
        // Check if create service item
        if (POSSalesLine.Type <> POSSalesLine.Type::Item) then
            exit;

        if (POSSalesLine.Quantity <= 0) then
            exit;

        Item.Get(POSSalesLine."No.");
        if (Item."Service Item Group" = '') then
            exit;

        if (not ServItemGr.Get(Item."Service Item Group")) then
            exit;

        if (not ServItemGr."Create Service Item") then
            exit;

        if (POSSalesLine.Quantity <> Round(POSSalesLine.Quantity, 1)) then
            exit;

        if (not ItemTrackingCode.Get(Item."Item Tracking Code")) then
            ItemTrackingCode.Init;

        // Create service item
        ServMgtSetup.Get;
        GLSetup.Get;
        TrackingLinesExist := (POSSalesLine."Serial No." <> '');

        for x := 1 to POSSalesLine.Quantity do begin
            Clear(ServItem);

            ServItemWithSerialNoExist := false;
            if (TrackingLinesExist) then begin
                ServItem.SetRange("Item No.", POSSalesLine."No.");
                ServItem.SetRange("Serial No.", POSSalesLine."Serial No.");
                ServItemWithSerialNoExist := ServItem.FindFirst();
            end;

            if ((not TrackingLinesExist) or (not ServItemWithSerialNoExist)) then begin
                ServItem.Init;
                ServMgtSetup.TestField("Service Item Nos.");
                NoSeriesMgt.InitSeries(ServMgtSetup."Service Item Nos.", ServItem."No. Series", 0D, ServItem."No.", ServItem."No. Series");
                ServItem.Insert;
            end;

            POSEntrySalesDocLink."POS Entry No." := POSEntry."Entry No.";
            POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
            POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::SERVICE_ITEM;
            POSEntrySalesDocLink."Sales Document No" := ServItem."No.";
            if (not POSEntrySalesDocLink.Insert()) then;

            ServItem."Shipment Type" := ServItem."Shipment Type"::Sales;

            ServItem.Validate(Description, CopyStr(POSSalesLine.Description, 1, MaxStrLen(ServItem.Description)));
            ServItem."Description 2" := CopyStr(StrSubstNo('%1 / %2 / %3', POSSalesLine."POS Store Code", POSSalesLine."POS Unit No.", POSSalesLine."Document No."), 1, MaxStrLen(ServItem."Description 2"));

            ServItem.Validate("Customer No.", POSEntry."Customer No.");

            ServItem.OmitAssignResSkills(true);
            ServItem.Validate("Item No.", Item."No.");
            ServItem.OmitAssignResSkills(false);

            if (TrackingLinesExist) then
                ServItem."Serial No." := POSSalesLine."Serial No.";

            ServItem."Variant Code" := POSSalesLine."Variant Code";
            ItemUnitOfMeasure.Get(Item."No.", POSSalesLine."Unit of Measure Code");
            ServItem.Validate("Sales Unit Cost", Round(POSSalesLine."Unit Cost (LCY)" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            if (POSEntry."Currency Code" <> '') then
                ServItem.Validate(
                  "Sales Unit Price",
                  AmountToLCY(
                    Round(POSSalesLine."Unit Price" /
                      ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"),
                    POSEntry."Currency Factor",
                    POSEntry."Currency Code",
                    POSEntry."Posting Date"))
            else
                ServItem.Validate("Sales Unit Price", Round(POSSalesLine."Unit Price" /
                    ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            ServItem."Vendor No." := Item."Vendor No.";
            ServItem."Vendor Item No." := Item."Vendor Item No.";
            ServItem."Unit of Measure Code" := Item."Base Unit of Measure";
            ServItem."Sales Date" := POSEntry."Posting Date";
            ServItem."Installation Date" := POSEntry."Posting Date";
            ServItem."Warranty % (Parts)" := ServMgtSetup."Warranty Disc. % (Parts)";
            ServItem."Warranty % (Labor)" := ServMgtSetup."Warranty Disc. % (Labor)";
            ServItem."Warranty Starting Date (Parts)" := POSEntry."Posting Date";

            if (Format(ItemTrackingCode."Warranty Date Formula") <> '') then
                ServItem."Warranty Ending Date (Parts)" :=
                  CalcDate(ItemTrackingCode."Warranty Date Formula", POSEntry."Posting Date")
            else
                ServItem."Warranty Ending Date (Parts)" :=
                  CalcDate(
                    ServMgtSetup."Default Warranty Duration",
                    POSEntry."Posting Date");

            ServItem."Warranty Starting Date (Labor)" := POSEntry."Posting Date";
            ServItem."Warranty Ending Date (Labor)" :=
              CalcDate(
                ServMgtSetup."Default Warranty Duration",
                POSEntry."Posting Date");
            ServItem.Modify;

            ResSkillMgt.AssignServItemResSkills(ServItem);

            if (POSSalesLine."BOM Item No." <> '') then begin
                Clear(BOMComp);
                BOMComp.SetRange("Parent Item No.", POSSalesLine."BOM Item No.");
                BOMComp.SetRange(Type, BOMComp.Type::Item);
                BOMComp.SetRange("No.", POSSalesLine."No.");
                BOMComp.SetRange("Installed in Line No.", 0);
                if (BOMComp.FindSet()) then
                    repeat
                        Clear(BOMComp2);
                        BOMComp2.SetRange("Parent Item No.", POSSalesLine."BOM Item No.");
                        BOMComp2.SetRange("Installed in Line No.", BOMComp."Line No.");
                        NextLineNo := 0;
                        if (BOMComp2.FindSet()) then
                            repeat
                                for y := 1 to Round(BOMComp2."Quantity per", 1) do begin
                                    NextLineNo := NextLineNo + 10000;
                                    ServItemComponent.Init;
                                    ServItemComponent.Active := true;
                                    ServItemComponent."Parent Service Item No." := ServItem."No.";
                                    ServItemComponent."Line No." := NextLineNo;
                                    ServItemComponent.Type := ServItemComponent.Type::Item;
                                    ServItemComponent."No." := BOMComp2."No.";
                                    ServItemComponent."Date Installed" := POSEntry."Posting Date";
                                    ServItemComponent.Description := BOMComp2.Description;
                                    ServItemComponent."Serial No." := '';
                                    ServItemComponent."Variant Code" := BOMComp2."Variant Code";
                                    ServItemComponent.Insert;
                                end;
                            until BOMComp2.Next = 0;
                    until BOMComp.Next = 0;
            end;
            Clear(ServLogMgt);
            ServLogMgt.ServItemAutoCreated(ServItem);
        end;
    end;

    local procedure AmountToLCY(FCAmount: Decimal; CurrencyFactor: Decimal; CurrencyCode: Code[10]; CurrencyDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        Currency.TestField("Unit-Amount Rounding Precision");
        exit(
          Round(
            CurrExchRate.ExchangeAmtFCYToLCY(
              CurrencyDate, CurrencyCode,
              FCAmount, CurrencyFactor),
            Currency."Unit-Amount Rounding Precision"));
    end;

    local procedure HandleRetailSerialNo(POSSalesLine: Record "NPR POS Sales Line")
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if (POSSalesLine."Retail Serial No." = '') then
            exit;

        ItemCrossReference.SetCurrentKey("Cross-Reference No.");
        ItemCrossReference.SetFilter("Cross-Reference No.", '=%1', POSSalesLine."Retail Serial No.");
        ItemCrossReference.SetFilter("NPR Is Retail Serial No.", '=%1', true);
        ItemCrossReference.SetFilter("Discontinue Bar Code", '=%1', false);
        if (ItemCrossReference.FindFirst()) then begin
            ItemCrossReference."Discontinue Bar Code" := true;
            ItemCrossReference.Modify();
        end;
    end;

    procedure PostAssemblyOrders(POSEntry: Record "NPR POS Entry"; FailOnError: Boolean): Boolean
    var
        POSSalesLine: Record "NPR POS Sales Line";
    begin
        if not PostToEntries(POSEntry) then
            exit;

        POSSalesLine.Reset;
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetFilter(Quantity, '>%1', 0);
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet then
            repeat
                // Assembly posting does alot of commits in posting codeunit 900
                if (not CheckAndCreateAssemblyOrder(FailOnError, POSEntry, POSSalesLine)) then
                    exit(false);
            until (POSSalesLine.Next() = 0);

        exit(true);
    end;

    local procedure GetPOSUnitLocation(POSUnitCode: Code[10]): Code[10]
    var
        CashRegister: Record "NPR Register";
    begin
        if CashRegister.Get(POSUnitCode) then
            exit(CashRegister."Location Code");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSSalesLineItemJnl(var POSSalesLine: Record "NPR POS Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemJournalLine(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line"; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;
}