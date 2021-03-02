codeunit 6059974 "NPR Variety Check"
{
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
        POSSalesLine: Record "NPR POS Sales Line";
        p: Record "NPR POS Entry";
    begin
        p."Amount Incl. Tax" := 1;
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
                ItemLedgEntry.SetRange(Open, true);
                ItemLedgEntry.SetRange("Variant Code", ItemVar.Code);
                if not ItemLedgEntry.IsEmpty then
                    Error(Text001, ItemLedgEntry.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
                POSSalesLine.SetRange("No.", ItemVar."Item No.");
                POSSalesLine.SetRange("Variant Code", ItemVar.Code);
                POSSalesLine.SetRange("Item Entry No.", 0);
                if POSSalesLine.FindFirst() then
                    Error(Text001, POSSalesLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);

                ItemVar."NPR Blocked" := true;
                ItemVar.Modify;
            until ItemVar.Next = 0;
    end;

    procedure CheckItemVariantDeleteAllowed(ItemVar: Record "Item Variant")
    var
        POSSalesLine: Record "NPR POS Sales Line";
    begin
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.", ItemVar."Item No.");
        POSSalesLine.SetRange("Variant Code", ItemVar.Code);
        if POSSalesLine.FindFirst() then
            Error(Text003, POSSalesLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);
    end;

    procedure PostingCheck(ItemJnlLine: Record "Item Journal Line")
    var
        VRTSetup: Record "NPR Variety Setup";
        ItemVar: Record "Item Variant";
    begin
        if not VRTSetup.Get then
            exit;

        if ItemJnlLine."Phys. Inventory" then
            exit;

        if ItemJnlLine."Item Charge No." <> '' then
            exit;

        with ItemJnlLine do begin
            case VRTSetup."Item Journal Blocking" of
                VRTSetup."Item Journal Blocking"::TotalBlockItemIfVariants:
                    begin
                        ItemVar.SetRange("Item No.", "Item No.");
                        ItemVar.SetRange("NPR Blocked", false);
                        if not ItemVar.IsEmpty then
                            TestField("Variant Code");
                    end;
                VRTSetup."Item Journal Blocking"::SaleBlockItemIfVariants:
                    begin
                        if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::Sale] then begin
                            ItemVar.SetRange("Item No.", "Item No.");
                            ItemVar.SetRange("NPR Blocked", false);
                            if not ItemVar.IsEmpty then
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
    end;

    local procedure UpdateVariants(Item: Record Item; XRecItem: Record Item)
    var
        ItemVar: Record "Item Variant";
        VarValue: Record "NPR Variety Value";
    begin
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
    end;

    local procedure SetNewMasterLineT37(OldMasterLine: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
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
    end;

    local procedure SetNewMasterLineT39(OldMasterLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
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
    end;

    local procedure SetNewMasterLineT83(OldMasterLine: Record "Item Journal Line")
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
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
    end;

    local procedure SetNewMasterLineT5741(OldMasterLine: Record "Transfer Line")
    var
        TransferLine: Record "Transfer Line";
    begin
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
    end;

    local procedure SetNewMasterLineT6014422(OldMasterLine: Record "NPR Retail Journal Line")
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
    begin
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
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT37(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT37(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT37(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        SetNewMasterLineT37(xRec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT39(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT39(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT39(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        SetNewMasterLineT39(xRec);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT83(var Rec: Record "Item Journal Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT83(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT83(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT83(xRec);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT5741(var Rec: Record "Transfer Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        if not Rec."NPR Is Master" then
            exit;

        SetNewMasterLineT5741(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT5741(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        if not xRec."NPR Is Master" then
            exit;

        if Rec."NPR Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT5741(xRec);
    end;

    [EventSubscriber(ObjectType::Table, 6014422, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT6014422(var Rec: Record "NPR Retail Journal Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        if not Rec."Is Master" then
            exit;

        SetNewMasterLineT6014422(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6014422, 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT6014422(var Rec: Record "NPR Retail Journal Line"; var xRec: Record "NPR Retail Journal Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        if not xRec."Is Master" then
            exit;

        if Rec."Is Master" then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        SetNewMasterLineT6014422(xRec);
    end;
}

