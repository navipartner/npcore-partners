codeunit 6059974 "NPR Variety Check"
{
    Access = Internal;

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
        POSSalesLine: Record "NPR POS Entry Sales Line";
        p: Record "NPR POS Entry";
        ConfirmMgt: Codeunit "Confirm Management";
        POSVariantLineCheck: Query "NPR POS Entry Line Variant";
    begin
        p."Amount Incl. Tax" := 1;
        //no variants created. Do what you want
        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.IsEmpty then
            exit;

        //No change in table setup. Do what you want
        if (Item."NPR Variety 1" = xRecItem."NPR Variety 1") and
           (Item."NPR Variety 2" = xRecItem."NPR Variety 2") and
           (Item."NPR Variety 3" = xRecItem."NPR Variety 3") and
           (Item."NPR Variety 4" = xRecItem."NPR Variety 4") and
           (Item."NPR Variety 1 Table" = xRecItem."NPR Variety 1 Table") and
           (Item."NPR Variety 2 Table" = XRecItem."NPR Variety 2 Table") and
           (Item."NPR Variety 3 Table" = XRecItem."NPR Variety 3 Table") and
           (Item."NPR Variety 4 Table" = XRecItem."NPR Variety 4 Table") then
            exit;

        //if we are here, an update of the variants is required.
        if CheckModifyAlloved(Item, XRecItem) then begin
            UpdateVariants(Item);
            exit;
        end;


        //if we are here, there is variants, and a structure change is requested.
        if not ConfirmMgt.GetResponseOrDefault(Text004, true) then
            Error('');
        //check if there is inventory on any of the variants
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code");
        SalesLine.SetCurrentKey(Type, "No.", "Variant Code");
        PurchLine.SetCurrentKey(Type, "No.", "Variant Code");
        ItemJnlLine.SetCurrentKey("Item No.");

        if ItemVar.FindSet() then
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

                POSVariantLineCheck.Setrange(Type, POSVariantLineCheck.Type::Item);
                POSVariantLineCheck.Setrange(No_, ItemVar."Item No.");
                POSVariantLineCheck.SetRange(Variant_Code, ItemVar.Code);
                POSVariantLineCheck.SetRange(Item_Entry_No_, 0);
                if POSVariantLineCheck.Open() then begin
                    if POSVariantLineCheck.Read() then
                        Error(Text001, POSSalesLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);
                end;

#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ItemVar."NPR Blocked" := true;
#ELSE
                ItemVar.Blocked := true;
#ENDIF
                ItemVar.Modify();
            until ItemVar.Next() = 0;
    end;

    procedure CheckItemVariantDeleteAllowed(ItemVar: Record "Item Variant")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.", ItemVar."Item No.");
        POSSalesLine.SetRange("Variant Code", ItemVar.Code);
        if not POSSalesLine.IsEmpty() then
            Error(Text003, POSSalesLine.TableCaption, ItemVar.TableCaption, ItemVar.Code);
    end;

    procedure PostingCheck(ItemJnlLine: Record "Item Journal Line")
    var
        VRTSetup: Record "NPR Variety Setup";
        ItemVar: Record "Item Variant";
    begin
        if ItemJnlLine."Phys. Inventory" or
           ItemJnlLine.Adjustment or
           (ItemJnlLine."Item Charge No." <> '')
        then
            exit;

        if not VRTSetup.Get() then
            exit;

#IF (BC17 or BC18 or BC19 or BC20)
        case VRTSetup."Item Journal Blocking" of
            VRTSetup."Item Journal Blocking"::TotalBlockItemIfVariants:
                begin
                    ItemVar.SetRange("Item No.", ItemJnlLine."Item No.");
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                    ItemVar.SetRange("NPR Blocked", false);
#ELSE
                    ItemVar.SetRange(Blocked, false);
#ENDIF
                    if not ItemVar.IsEmpty then
                        ItemJnlLine.TestField(ItemJnlLine."Variant Code");
                end;
            VRTSetup."Item Journal Blocking"::SaleBlockItemIfVariants:
                if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::Sale] then begin
                    ItemVar.SetRange("Item No.", ItemJnlLine."Item No.");
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                    ItemVar.SetRange("NPR Blocked", false);
#ELSE
                    ItemVar.SetRange(Blocked, false);
#ENDIF
                    if not ItemVar.IsEmpty then
                        ItemJnlLine.TestField(ItemJnlLine."Variant Code");
                end;
        end;
#ENDIF

        if ItemJnlLine."Variant Code" <> '' then begin
            ItemVar.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code");
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            ItemVar.TestField("NPR Blocked", false);
#ELSE
            ItemVar.TestField(Blocked, false);
#ENDIF
        end;

    end;

    procedure CheckDeleteVarietyValue(VRTValue: Record "NPR Variety Value")
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("NPR Variety 1", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 1 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 1 Value", VRTValue.Value);
        if ItemVariant.FindSet() then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next() = 0;

        ItemVariant.SetRange("NPR Variety 2", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 2 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 2 Value", VRTValue.Value);
        if ItemVariant.FindSet() then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next() = 0;

        ItemVariant.SetRange("NPR Variety 3", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 3 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 3 Value", VRTValue.Value);
        if ItemVariant.FindSet() then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next() = 0;

        ItemVariant.SetRange("NPR Variety 4", VRTValue.Type);
        ItemVariant.SetRange("NPR Variety 4 Table", VRTValue.Table);
        ItemVariant.SetRange("NPR Variety 4 Value", VRTValue.Value);
        if ItemVariant.FindSet() then
            repeat
                CheckItemVariantDeleteAllowed(ItemVariant);
            until ItemVariant.Next() = 0;
    end;

    local procedure CheckModifyAlloved(Item: Record Item; XRecItem: Record Item): Boolean
    var
        ItemVar: Record "Item Variant";
        Variety: Record "NPR Variety";
        VarietyTable: Record "NPR Variety Table";
        VarietyValue: Record "NPR Variety Value";
    begin
        if (Item."NPR Variety 1" <> '') and (xRecItem."NPR Variety 1" = '') then
            exit(false);
        if (Item."NPR Variety 2" <> '') and (xRecItem."NPR Variety 2" = '') then
            exit(false);
        if (Item."NPR Variety 3" <> '') and (xRecItem."NPR Variety 3" = '') then
            exit(false);
        if (Item."NPR Variety 4" <> '') and (xRecItem."NPR Variety 4" = '') then
            exit(false);

        if (Item."NPR Variety 1" = '') and (xRecItem."NPR Variety 1" <> '') then
            exit(false);
        if (Item."NPR Variety 2" = '') and (xRecItem."NPR Variety 2" <> '') then
            exit(false);
        if (Item."NPR Variety 3" = '') and (xRecItem."NPR Variety 3" <> '') then
            exit(false);
        if (Item."NPR Variety 4" = '') and (xRecItem."NPR Variety 4" <> '') then
            exit(false);

        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.FindSet() then
            repeat
                if (Item."NPR Variety 1" <> xRecItem."NPR Variety 1") or (Item."NPR Variety 1 Table" <> xRecItem."NPR Variety 1 Table") then begin
                    if not Variety.Get(Item."NPR Variety 1") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table", ItemVar."NPR Variety 1 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 2" <> xRecItem."NPR Variety 2") or (Item."NPR Variety 2 Table" <> xRecItem."NPR Variety 2 Table") then begin
                    if not Variety.Get(Item."NPR Variety 2") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table", ItemVar."NPR Variety 2 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 3" <> xRecItem."NPR Variety 3") or (Item."NPR Variety 3 Table" <> xRecItem."NPR Variety 3 Table") then begin
                    if not Variety.Get(Item."NPR Variety 3") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table", ItemVar."NPR Variety 3 Value") then
                        exit(false);
                end;

                if (Item."NPR Variety 4" <> xRecItem."NPR Variety 4") or (Item."NPR Variety 4 Table" <> xRecItem."NPR Variety 4 Table") then begin
                    if not Variety.Get(Item."NPR Variety 4") then
                        exit(false);
                    if not VarietyTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then
                        exit(false);
                    if not VarietyValue.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table", ItemVar."NPR Variety 4 Value") then
                        exit(false);
                end;
            until ItemVar.Next() = 0;
        exit(true);
    end;

    local procedure UpdateVariants(Item: Record Item)
    var
        ItemVar: Record "Item Variant";
        VarValue: Record "NPR Variety Value";
    begin
        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.FindSet() then
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
            until ItemVar.Next() = 0;
    end;

    local procedure SetNewMasterLineT37(OldMasterLine: Record "Sales Line")
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        MasterLineMapMgt.TransferOwnershipToNextInLine(Database::"Sales Line", OldMasterLine.SystemId);
    end;

    local procedure SetNewMasterLineT39(OldMasterLine: Record "Purchase Line")
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        MasterLineMapMgt.TransferOwnershipToNextInLine(Database::"Purchase Line", OldMasterLine.SystemId);
    end;

    local procedure SetNewMasterLineT83(OldMasterLine: Record "Item Journal Line")
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        MasterLineMapMgt.TransferOwnershipToNextInLine(Database::"Item Journal Line", OldMasterLine.SystemId);
    end;

    local procedure SetNewMasterLineT5741(OldMasterLine: Record "Transfer Line")
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        MasterLineMapMgt.TransferOwnershipToNextInLine(Database::"Transfer Line", OldMasterLine.SystemId);
    end;

    local procedure SetNewMasterLineT6014422(OldMasterLine: Record "NPR Retail Journal Line")
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        MasterLineMapMgt.TransferOwnershipToNextInLine(Database::"NPR Retail Journal Line", OldMasterLine.SystemId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT37(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        SetNewMasterLineT37(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT37(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        if MasterLineMapMgt.IsMaster(Database::"Sales Line", Rec.SystemId) then
            exit;

        SetNewMasterLineT37(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT39(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        SetNewMasterLineT39(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateItemNoT39(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."No." = xRec."No." then
            exit;

        if MasterLineMapMgt.IsMaster(Database::"Purchase Line", Rec.SystemId) then
            exit;

        SetNewMasterLineT39(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT83(var Rec: Record "Item Journal Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        SetNewMasterLineT83(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT83(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        if Rec.IsTemporary then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        if MasterLineMapMgt.IsMaster(Database::"Item Journal Line", Rec.SystemId) then
            exit;

        SetNewMasterLineT83(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT5741(var Rec: Record "Transfer Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        SetNewMasterLineT5741(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT5741(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        if MasterLineMapMgt.IsMaster(Database::"Transfer Line", Rec.SystemId) then
            exit;

        SetNewMasterLineT5741(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Journal Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteMasterVarietyLineT6014422(var Rec: Record "NPR Retail Journal Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        SetNewMasterLineT6014422(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Journal Line", 'OnAfterValidateEvent', 'Item No.', true, false)]
    local procedure OnAfterValidateItemNoT6014422(var Rec: Record "NPR Retail Journal Line"; var xRec: Record "NPR Retail Journal Line"; CurrFieldNo: Integer)
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Item No." = xRec."Item No." then
            exit;

        if MasterLineMapMgt.IsMaster(Database::"NPR Retail Journal Line", Rec.SystemId) then
            exit;

        SetNewMasterLineT6014422(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Variant Code', true, false)]
    local procedure OnAfterValidateVariantCodeSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        ItemVariant: record "Item Variant";
    begin
        if Rec."Variant Code" <> '' then
            if ItemVariant.Get(Rec."No.", Rec."Variant Code") then
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ItemVariant.TestField("NPR Blocked", false);
#ELSE
                ItemVariant.TestField(Blocked, false);
#ENDIF
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Variant Code', true, false)]
    local procedure OnAfterValidateVariantCodePurchaseLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        ItemVariant: record "Item Variant";
    begin
        if Rec."Variant Code" <> '' then
            if ItemVariant.Get(Rec."No.", Rec."Variant Code") then
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ItemVariant.TestField("NPR Blocked", false);
#ELSE
                ItemVariant.TestField(Blocked, false);
#ENDIF
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Variant Code', true, false)]
    local procedure OnAfterValidateVariantCodeTransferLine(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        ItemVariant: record "Item Variant";
    begin
        if Rec."Variant Code" <> '' then
            if ItemVariant.Get(Rec."Item No.", Rec."Variant Code") then
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ItemVariant.TestField("NPR Blocked", false);
#ELSE
                ItemVariant.TestField(Blocked, false);
#ENDIF
    end;

}
