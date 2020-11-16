codeunit 6059974 "NPR Variety Check"
{
    // VRT1.20/JDH/20160914 CASE 252200 changed filter to correctly look for open entries
    // NPR5.31/TJ  /20170425 CASE 271060 Commented out standard table checks in function CheckItemVariantDeleteAllowed as they are part of OnDelete trigger in table Item Variant
    // NPR5.32/JDH /20170510 CASE 274170 Variable Cleanup
    // NPR5.32/JDH /20170523 CASE 277206 If its an Physical inventory line, Variant checks wont be executed
    // NPR5.33/JDH /20170629 CASE 282177 Possible to change Variety table if the values exists in the new table as well
    // NPR5.42/JDH /20180511 CASE 314721 If its an item charge line, no checks about variant code should be done
    // NPR5.44/JDH /20180725 CASE 323081 When Master variety lines was deleted, the matrix was not working


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'There is open %1 for %2 %3.\These entries must be closed before you can change the Variations';
        Text002: Label 'There is %1 for %2 %3.\These entries must be deleted before you can change the Variations';
        Text003: Label 'There is %1 for %2 %3.';
        Text004: Label 'Warning: You are trying to change the setup on an item, that already has variants.\If you continue, all existing variants will be blocked, and new will be created.\Do you wish to continue?';

    procedure ChangeItemVariety(Item: Record Item; XRecItem: Record Item)
    var
        ItemVar: Record "Item Variant";
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        AuditRoll: Record "NPR Audit Roll";
    begin
        //no variants created. Do what you want
        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.IsEmpty then
            exit;

        //No change in table setup. Do what you want
        if (Item."NPR Variety 1" = XRecItem."NPR Variety 1") and
           (Item."NPR Variety 2" = XRecItem."NPR Variety 2") and
           (Item."NPR Variety 3" = XRecItem."NPR Variety 3") and
           (Item."NPR Variety 4" = XRecItem."NPR Variety 4") and
           (Item."NPR Variety 1 Table" = XRecItem."NPR Variety 1 Table") and
           (Item."NPR Variety 2 Table" = XRecItem."NPR Variety 2 Table") and
           (Item."NPR Variety 3 Table" = XRecItem."NPR Variety 3 Table") and
           (Item."NPR Variety 4 Table" = XRecItem."NPR Variety 4 Table") then
            exit;

        //if we are here, an update of the variants is required.
        if CheckModifyAlloved(Item, XRecItem) then begin
            UpdateVariants(Item, XRecItem);
            exit;
        end;


        //if we are here, there is variants, and a structure change is requested.
        if not Confirm(Text004) then
            Error('');
        //check if there is inventory on any of the variants
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code");
        SalesLine.SetCurrentKey(Type, "No.", "Variant Code");
        PurchLine.SetCurrentKey(Type, "No.", "Variant Code");
        ItemJnlLine.SetCurrentKey("Item No.");
        AuditRoll.SetCurrentKey("Sale Type", Type, "No.", Posted);

        if ItemVar.FindSet then
            repeat
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("No.", ItemVar."Item No.");
                SalesLine.SetRange("Variant Code", ItemVar.Code);
                if not SalesLine.IsEmpty then
                    Error(Text002, SalesLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                PurchLine.SetRange(Type, PurchLine.Type::Item);
                PurchLine.SetRange("No.", ItemVar."Item No.");
                PurchLine.SetRange("Variant Code", ItemVar.Code);
                if not PurchLine.IsEmpty then
                    Error(Text002, PurchLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                ItemJnlLine.SetRange("Item No.", ItemVar."Item No.");
                ItemJnlLine.SetRange("Variant Code", ItemVar.Code);
                if not ItemJnlLine.IsEmpty then
                    Error(Text002, ItemJnlLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                ItemLedgEntry.SetRange("Item No.", ItemVar."Item No.");
                //-VRT1.20 [252200]
                //ItemLedgEntry.SETRANGE(Open, FALSE);
                ItemLedgEntry.SetRange(Open, true);
                //+VRT1.20 [252200]
                ItemLedgEntry.SetRange("Variant Code", ItemVar.Code);
                if not ItemLedgEntry.IsEmpty then
                    Error(Text001, ItemLedgEntry.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
                AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                AuditRoll.SetRange("No.", ItemVar."Item No.");
                AuditRoll.SetRange("Variant Code", ItemVar.Code);
                AuditRoll.SetRange(Posted, false);
                if AuditRoll.FindFirst then
                    Error(Text001, AuditRoll.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                ItemVar."NPR Blocked" := true;
                ItemVar.Modify;
            until ItemVar.Next = 0;
    end;

    procedure CheckItemVariantDeleteAllowed(ItemVar: Record "Item Variant")
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //-NPR5.31 [271060]
        /*
        SalesLine.SETCURRENTKEY(Type, "No.", "Variant Code");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETRANGE("No.", ItemVar."Item No.");
        SalesLine.SETRANGE("Variant Code", ItemVar.Code);
        IF NOT SalesLine.ISEMPTY THEN
          ERROR(Text003, SalesLine.TABLECAPTION, ItemVar.TABLECAPTION, ItemVar.Code);
        
        PurchLine.SETCURRENTKEY(Type, "No.", "Variant Code");
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETRANGE("No.", ItemVar."Item No.");
        PurchLine.SETRANGE("Variant Code", ItemVar.Code);
        IF NOT PurchLine.ISEMPTY THEN
          ERROR(Text003, PurchLine.TABLECAPTION, ItemVar.TABLECAPTION, ItemVar.Code);
        
        ItemJnlLine.SETCURRENTKEY("Item No.");
        ItemJnlLine.SETRANGE("Item No.", ItemVar."Item No.");
        ItemJnlLine.SETRANGE("Variant Code", ItemVar.Code);
        IF NOT ItemJnlLine.ISEMPTY THEN
          ERROR(Text003, ItemJnlLine.TABLECAPTION, ItemVar.TABLECAPTION, ItemVar.Code);
        
        ItemLedgEntry.SETCURRENTKEY("Item No.", Open, "Variant Code");
        ItemLedgEntry.SETRANGE("Item No.", ItemVar."Item No.");
        ItemLedgEntry.SETRANGE("Variant Code", ItemVar.Code);
        IF NOT ItemLedgEntry.ISEMPTY THEN
          ERROR(Text003, ItemLedgEntry.TABLECAPTION, ItemVar.TABLECAPTION, ItemVar.Code);
        */
        //+NPR5.31 [271060]

        AuditRoll.SetCurrentKey("Sale Type", Type, "No.", Posted);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("No.", ItemVar."Item No.");
        AuditRoll.SetRange("Variant Code", ItemVar.Code);
        if AuditRoll.FindFirst then
            Error(Text003, AuditRoll.TableCaption, ItemVar.TableCaption, ItemVar.Code);

    end;

    procedure PostingCheck(ItemJnlLine: Record "Item Journal Line")
    var
        VRTSetup: Record "NPR Variety Setup";
        ItemVar: Record "Item Variant";
    begin
        if not VRTSetup.Get then
            exit;

        //-NPR5.32 [277206]
        if ItemJnlLine."Phys. Inventory" then
            exit;
        //+NPR5.32 [277206]

        //-NPR5.42 [314721]
        if ItemJnlLine."Item Charge No." <> '' then
            exit;
        //+NPR5.42 [314721]


        with ItemJnlLine do begin
            case VRTSetup."Item Journal Blocking" of
                VRTSetup."Item Journal Blocking"::TotalBlockItemIfVariants:
                    begin
                        //-VRT1.20 [252200]
                        //Item.GET("Item No.");
                        //Item.CALCFIELDS("Has Variants");
                        //IF Item."Has Variants" THEN
                        ItemVar.SetRange("Item No.", "Item No.");
                        ItemVar.SetRange("NPR Blocked", false);
                        if not ItemVar.IsEmpty then
                            //+VRT1.20 [252200]
                            TestField("Variant Code");
                    end;
                VRTSetup."Item Journal Blocking"::SaleBlockItemIfVariants:
                    begin
                        if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::Sale] then begin
                            //-VRT1.20 [252200]
                            //Item.GET("Item No.");
                            //Item.CALCFIELDS("Has Variants");
                            //IF Item."Has Variants" THEN
                            ItemVar.SetRange("Item No.", "Item No.");
                            ItemVar.SetRange("NPR Blocked", false);
                            if not ItemVar.IsEmpty then
                                //+VRT1.20 [252200]
                                TestField("Variant Code");
                        end;
                    end;
            end;

            if "Variant Code" <> '' then begin
                ItemVar.Get("Item No.", "Variant Code");
                ItemVar.TestField("NPR Blocked", false);
            end;
        end;
    end;

    procedure CheckDeleteVarietyValue(VRTValue: Record "NPR Variety Value")
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("NPR Variety 1", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 1 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 1 Value", VRTValue.Value);
        if ItemVariant.FindSet then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next = 0;

        ItemVariant.SetRange("NPR Variety 2", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 2 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 2 Value", VRTValue.Value);
        if ItemVariant.FindSet then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next = 0;

        ItemVariant.SetRange("NPR Variety 3", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 3 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 3 Value", VRTValue.Value);
        if ItemVariant.FindSet then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next = 0;

        ItemVariant.SetRange("NPR Variety 4", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 4 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 4 Value", VRTValue.Value);
        if ItemVariant.FindSet then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next = 0;
    end;

    local procedure CheckModifyAlloved(Item: Record Item; XRecItem: Record Item) ModifyAllowed: Boolean
    var
        ItemVar: Record "Item Variant";
        Variety: Record "NPR Variety";
        VarietyTable: Record "NPR Variety Table";
        VarietyValue: Record "NPR Variety Value";
    begin
        //-NPR5.33 [282177]
        //check that its the same number of dimensions
        if (Item."NPR Variety 1" <> '') and (XRecItem."NPR Variety 1" = '') then
            exit(false);
        if (Item."NPR Variety 2" <> '') and (XRecItem."NPR Variety 2" = '') then
            exit(false);
        if (Item."NPR Variety 3" <> '') and (XRecItem."NPR Variety 3" = '') then
            exit(false);
        if (Item."NPR Variety 4" <> '') and (XRecItem."NPR Variety 4" = '') then
            exit(false);

        if (Item."NPR Variety 1" = '') and (XRecItem."NPR Variety 1" <> '') then
            exit(false);
        if (Item."NPR Variety 2" = '') and (XRecItem."NPR Variety 2" <> '') then
            exit(false);
        if (Item."NPR Variety 3" = '') and (XRecItem."NPR Variety 3" <> '') then
            exit(false);
        if (Item."NPR Variety 4" = '') and (XRecItem."NPR Variety 4" <> '') then
            exit(false);

        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.FindSet then
            repeat
                if (Item."NPR Variety 1" <> XRecItem."NPR Variety 1") or (Item."NPR Variety 1 Table" <> XRecItem."NPR Variety 1 Table") then begin
                    if not Variety.Get(Item."NPR Variety 1") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table", ItemVar."NPR Variety 1 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 2" <> XRecItem."NPR Variety 2") or (Item."NPR Variety 2 Table" <> XRecItem."NPR Variety 2 Table") then begin
                    if not Variety.Get(Item."NPR Variety 2") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table", ItemVar."NPR Variety 2 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 3" <> XRecItem."NPR Variety 3") or (Item."NPR Variety 3 Table" <> XRecItem."NPR Variety 3 Table") then begin
                    if not Variety.Get(Item."NPR Variety 3") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table", ItemVar."NPR Variety 3 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 4" <> XRecItem."NPR Variety 4") or (Item."NPR Variety 4 Table" <> XRecItem."NPR Variety 4 Table") then begin
                    if not Variety.Get(Item."NPR Variety 4") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table", ItemVar."NPR Variety 4 Value") then
                        exit(false);
                end;
            until ItemVar.Next = 0;
        exit(true);
        //+NPR5.33 [282177]
    end;

    local procedure UpdateVariants(Item: Record Item; XRecItem: Record Item)
    var
        ItemVar: Record "Item Variant";
        VarValue: Record "NPR Variety Value";
    begin
        //-NPR5.33 [282177]
        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.FindSet then
            repeat
                if ItemVar."NPR Variety 1" <> Item."NPR Variety 1" then
                    ItemVar."NPR Variety 1" := Item."NPR Variety 1";
                if ItemVar."NPR Variety 1 Table" <> Item."NPR Variety 1 Table" then
                    ItemVar."NPR Variety 1 Table" := Item."NPR Variety 1 Table";
                if ItemVar."NPR Variety 1" <> '' then
                    VarValue.Get(ItemVar."NPR Variety 1", ItemVar."NPR Variety 1 Table", ItemVar."NPR Variety 1 Value");

                if ItemVar."NPR Variety 2" <> Item."NPR Variety 2" then
                    ItemVar."NPR Variety 2" := Item."NPR Variety 2";
                if ItemVar."NPR Variety 2 Table" <> Item."NPR Variety 2 Table" then
                    ItemVar."NPR Variety 2 Table" := Item."NPR Variety 2 Table";
                if ItemVar."NPR Variety 2" <> '' then
                    VarValue.Get(ItemVar."NPR Variety 2", ItemVar."NPR Variety 2 Table", ItemVar."NPR Variety 2 Value");

                if ItemVar."NPR Variety 3" <> Item."NPR Variety 3" then
                    ItemVar."NPR Variety 3" := Item."NPR Variety 3";
                if ItemVar."NPR Variety 3 Table" <> Item."NPR Variety 3 Table" then
                    ItemVar."NPR Variety 3 Table" := Item."NPR Variety 3 Table";
                if ItemVar."NPR Variety 3" <> '' then
                    VarValue.Get(ItemVar."NPR Variety 3", ItemVar."NPR Variety 3 Table", ItemVar."NPR Variety 3 Value");

                if ItemVar."NPR Variety 4" <> Item."NPR Variety 4" then
                    ItemVar."NPR Variety 4" := Item."NPR Variety 4";
                if ItemVar."NPR Variety 4 Table" <> Item."NPR Variety 4 Table" then
                    ItemVar."NPR Variety 4 Table" := Item."NPR Variety 4 Table";
                if ItemVar."NPR Variety 4" <> '' then
                    VarValue.Get(ItemVar."NPR Variety 4", ItemVar."NPR Variety 4 Table", ItemVar."NPR Variety 4 Value");
                ItemVar.Modify(true);
            until ItemVar.Next = 0;
        //+NPR5.33 [282177]
    end;

    local procedure SetNewMasterLineT37(OldMasterLine: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        with SalesLine do begin
            SetRange("Document Type", OldMasterLine."Document Type");
            SetRange("Document No.", OldMasterLine."Document No.");
            SetRange("NPR Master Line No.", OldMasterLine."NPR Master Line No.");
            SetRange("NPR Is Master", false);

            if IsEmpty then
                exit;

            FindFirst;
            ModifyAll("NPR Master Line No.", "Line No.", true);
            Get("Document Type", "Document No.", "Line No.");
            "NPR Is Master" := true;
            Modify;
        end;
        //+NPR5.44 [323081]
    end;

    local procedure SetNewMasterLineT39(OldMasterLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        //-NPR5.44 [323081]
        with PurchaseLine do begin
            SetRange("Document Type", OldMasterLine."Document Type");
            SetRange("Document No.", OldMasterLine."Document No.");
            SetRange("NPR Master Line No.", OldMasterLine."NPR Master Line No.");
            SetRange("NPR Is Master", false);

            if IsEmpty then
                exit;

            FindFirst;
            ModifyAll("NPR Master Line No.", "Line No.", true);
            Get("Document Type", "Document No.", "Line No.");
            "NPR Is Master" := true;
            Modify;
        end;
        //+NPR5.44 [323081]
    end;

    local procedure SetNewMasterLineT83(OldMasterLine: Record "Item Journal Line")
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        //-NPR5.44 [323081]
        with ItemJournalLine do begin
            SetRange("Journal Template Name", OldMasterLine."Journal Template Name");
            SetRange("Journal Batch Name", OldMasterLine."Journal Batch Name");
            SetRange("NPR Master Line No.", OldMasterLine."NPR Master Line No.");
            SetRange("NPR Is Master", false);

            if IsEmpty then
                exit;

            FindFirst;
            ModifyAll("NPR Master Line No.", "Line No.", true);
            Get("Journal Template Name", "Journal Batch Name", "Line No.");
            "NPR Is Master" := true;
            Modify;
        end;
        //+NPR5.44 [323081]
    end;

    local procedure SetNewMasterLineT5741(OldMasterLine: Record "Transfer Line")
    var
        TransferLine: Record "Transfer Line";
    begin
        //-NPR5.44 [323081]
        with TransferLine do begin
            SetRange("Document No.", OldMasterLine."Document No.");
            SetRange("NPR Master Line No.", OldMasterLine."NPR Master Line No.");
            SetRange("NPR Is Master", false);

            if IsEmpty then
                exit;

            FindFirst;
            ModifyAll("NPR Master Line No.", "Line No.", true);
            Get("Document No.", "Line No.");
            "NPR Is Master" := true;
            Modify;
        end;
        //+NPR5.44 [323081]
    end;

    local procedure SetNewMasterLineT6014422(OldMasterLine: Record "NPR Retail Journal Line")
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.44 [323081]
        with RetailJournalLine do begin
            SetRange("No.", OldMasterLine."No.");
            SetRange("Master Line No.", OldMasterLine."Master Line No.");
            SetRange("Is Master", false);

            if IsEmpty then
                exit;

            FindFirst;
            ModifyAll("Master Line No.", "Line No.", true);
            Get("No.", "Line No.");
            "Is Master" := true;
            Modify;
        end;
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT37(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT37(Rec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT37(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        SetNewMasterLineT37(xRec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT39(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT39(Rec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT39(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        SetNewMasterLineT39(xRec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT83(var Rec: Record "Item Journal Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT83(Rec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT83(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT83(xRec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT5741(var Rec: Record "Transfer Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT5741(Rec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT5741(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT5741(xRec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 6014422, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT6014422(var Rec: Record "NPR Retail Journal Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not Rec."Is Master" then
            exit;

        SetNewMasterLineT6014422(Rec);
        //+NPR5.44 [323081]
    end;

    [EventSubscriber(ObjectType::Table, 6014422, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT6014422(var Rec: Record "NPR Retail Journal Line"; var xRec: Record "NPR Retail Journal Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.44 [323081]
        if Rec.IsTemporary then
            exit;

        if not xRec."Is Master" then
            exit;

        if Rec."Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT6014422(xRec);
        //+NPR5.44 [323081]
    end;
}

