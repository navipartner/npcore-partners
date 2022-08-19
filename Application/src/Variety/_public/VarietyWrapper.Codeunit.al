codeunit 6059970 "NPR Variety Wrapper"
{
    internal procedure ShowVarietyMatrix(var ItemParm: Record Item; ShowFieldNo: Integer)
    var
        RecRef: RecordRef;
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        ItemVar: Record "Item Variant";
    begin
        //test variant item
        TestItemIsVariety(ItemParm);
        ItemVar.SetRange("Item No.", ItemParm."No.");
        RecRef.GetTable(ItemVar);
        VRTShowTable.ShowVarietyMatrix(RecRef, ItemParm, ShowFieldNo);

    end;

    internal procedure ShowMaintainItemMatrix(var ItemParm: Record Item; ShowFieldNo: Integer)
    var
        RecRef: RecordRef;
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        ItemVar: Record "Item Variant";
    begin
        //test variant item
        TestItemIsVariety(ItemParm);
        ItemVar.SetRange("Item No.", ItemParm."No.");
        ItemParm.SetFilter("Date Filter", GetCalculationDate(WorkDate()));
        RecRef.GetTable(ItemVar);
        VRTShowTable.ShowBooleanMatrix(RecRef, ItemParm, ShowFieldNo);
    end;

    internal procedure SalesLineShowVariety(SalesLine: Record "Sales Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        SalesLine.TestField(SalesLine.Type, SalesLine.Type::Item);
        SalesLine.TestField("No.");
        Item.Get(SalesLine."No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Sales Line", SalesLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line
                MasterLineMapMgt.CreateMap(Database::"Sales Line", SalesLine.SystemId, SalesLine.SystemId);
                Commit();
            end else
                //existing Variety
                SalesLine.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(SalesLine);
        Item.SetFilter("Location Filter", SalesLine."Location Code");
        Item.SetFilter("Date Filter", GetCalculationDate(SalesLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", SalesLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", SalesLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", SalesLine."Bin Code");
        Item.SetFilter("Drop Shipment Filter", '%1', SalesLine."Drop Shipment");

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure PurchLineShowVariety(PurchLine: Record "Purchase Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        PurchLine.TestField(PurchLine.Type, PurchLine.Type::Item);
        PurchLine.TestField("No.");
        Item.Get(PurchLine."No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Purchase Line", PurchLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line
                MasterLineMapMgt.CreateMap(Database::"Purchase Line", PurchLine.SystemId, PurchLine.SystemId);
                Commit();
            end else
                //existing Variety
                PurchLine.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(PurchLine);
        Item.SetFilter("Location Filter", PurchLine."Location Code");
        Item.SetFilter("Date Filter", GetCalculationDate(PurchLine."Expected Receipt Date"));
        Item.SetFilter("Global Dimension 1 Filter", PurchLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", PurchLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", PurchLine."Bin Code");
        Item.SetFilter("Drop Shipment Filter", '%1', PurchLine."Drop Shipment");

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure PriceShowVariety(PriceListLine: Record "Price List Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(PriceListLine."Asset No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Price List Line", PriceListLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line - can only be done on blank Variant Code
                PriceListLine.TestField("Variant Code", '');
                MasterLineMapMgt.CreateMap(Database::"Price List Line", PriceListLine.SystemId, PriceListLine.SystemId);
                Commit();
            end else
                //existing Variety
                PriceListLine.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(PriceListLine);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure RetailJournalLineShowVariety(RetailJournalLine: Record "NPR Retail Journal Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(RetailJournalLine."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"NPR Retail Journal Line", RetailJournalLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line
                MasterLineMapMgt.CreateMap(Database::"NPR Retail Journal Line", RetailJournalLine.SystemId, RetailJournalLine.SystemId);
                Commit();
            end else
                //existing Variety
                RetailJournalLine.GetBySystemId(MasterLineMap."Master Id");

        RecRef.GetTable(RetailJournalLine);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure ItemReplenishmentShowVariety(ItemReplenishByStore: Record "NPR Item Repl. by Store"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(ItemReplenishByStore."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"NPR Item Repl. by Store", ItemReplenishByStore.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line - can only be done on blank Variant Code
                ItemReplenishByStore.TestField(ItemReplenishByStore."Variant Code", '');
                MasterLineMapMgt.CreateMap(Database::"NPR Item Repl. by Store", ItemReplenishByStore.SystemId, ItemReplenishByStore.SystemId);
                Commit();
            end else
                //existing Variety
                ItemReplenishByStore.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(ItemReplenishByStore);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure ItemJnlLineShowVariety(ItemJnlLine: Record "Item Journal Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(ItemJnlLine."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Item Journal Line", ItemJnlLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line
                MasterLineMapMgt.CreateMap(Database::"Item Journal Line", ItemJnlLine.SystemId, ItemJnlLine.SystemId);
                Commit();
            end else
                //existing Variety
                ItemJnlLine.GetBySystemId(MasterLineMap."Master Id");

        //transfer the filter to the matrix, so inventory can be shown for this location
        if ItemJnlLine."Location Code" <> '' then
            Item.SetRange("Location Filter", ItemJnlLine."Location Code");

        RecRef.GetTable(ItemJnlLine);
        Item.SetFilter("Location Filter", ItemJnlLine."Location Code");
        Item.SetFilter("Date Filter", GetCalculationDate(ItemJnlLine."Posting Date"));
        Item.SetFilter("Global Dimension 1 Filter", ItemJnlLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", ItemJnlLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", ItemJnlLine."Bin Code");
        Item.SetFilter("Drop Shipment Filter", '%1', ItemJnlLine."Drop Shipment");

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    internal procedure TestItemIsVariety(Item: Record Item)
    begin
        // forgotten check? todo?
    end;

    internal procedure TransferLineShowVariety(TransferLine: Record "Transfer Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(TransferLine."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Transfer Line", TransferLine.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line
                MasterLineMapMgt.CreateMap(Database::"Transfer Line", TransferLine.SystemId, TransferLine.SystemId);
                Commit();
            end else
                //existing Variety
                TransferLine.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(TransferLine);
        Item.SetFilter("Location Filter", TransferLine."Transfer-from Code");
        Item.SetFilter("Date Filter", GetCalculationDate(TransferLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", TransferLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", TransferLine."Shortcut Dimension 2 Code");

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Page::"Item Variants", 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemVariantsOnAfterInsertEvent(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if RunTrigger then
            VRTCloneData.InsertDefaultBarcode(Rec."Item No.", Rec.Code, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Description', false, false)]
    local procedure ItemsOnAfterValidateDescription(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateItemRefDescriptions(Rec, Rec.FieldNo(Description));
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Description 2', false, false)]
    local procedure ItemsOnAfterValidateDescription2(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateItemRefDescriptions(Rec, Rec.FieldNo("Description 2"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterValidateEvent', 'Description', false, false)]
    local procedure ItemVariantsOnAfterValidateDescription(var Rec: Record "Item Variant")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateItemRefDescriptions(Rec, Rec.FieldNo(Description));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterValidateEvent', 'Description 2', false, false)]
    local procedure ItemVariantsOnAfterValidateDescription2(var Rec: Record "Item Variant")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateItemRefDescriptions(Rec, Rec.FieldNo("Description 2"));
    end;

    local procedure UpdateItemRefDescriptions(Item: Record Item; ChangedFieldNo: Integer)
    var
        ItemReference: Record "Item Reference";
        ItemReference2: Record "Item Reference";
        VRTSetup: Record "NPR Variety Setup";
        Handled: Boolean;
    begin
        if not (VRTSetup.Get() and VRTSetup."Create Item Cross Ref. auto.") then
            exit;
        if not (
            ((ChangedFieldNo = Item.FieldNo(Description)) and
             ((VRTSetup."Item Cross Ref. Description(I)" = VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1) or
              (VRTSetup."Item Ref. Description 2 (I)" = VRTSetup."Item Ref. Description 2 (I)"::ItemDescription1) or
              (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1) or
              (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::ItemDescription1)))
            or
            ((ChangedFieldNo = Item.FieldNo("Description 2")) and
             ((VRTSetup."Item Cross Ref. Description(I)" = VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2) or
              (VRTSetup."Item Ref. Description 2 (I)" = VRTSetup."Item Ref. Description 2 (I)"::ItemDescription2) or
              (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2) or
              (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::ItemDescription2))))
        then
            exit;

        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetFilter("Unit of Measure", '%1|%2', '', Item."Base Unit of Measure");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        OnBeforeUpdateItemReferenceDescriptions(ItemReference, Item, ChangedFieldNo, Handled);
        if Handled then
            exit;
        if not ItemReference.FindSet(true) then
            exit;
        repeat
            ItemReference2 := ItemReference;
            if ItemReference2."Variant Code" = '' then begin
                case true of
                    (ChangedFieldNo = Item.FieldNo(Description)) and
                    (VRTSetup."Item Cross Ref. Description(I)" = VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1):
                        ItemReference2.Description := Item.Description;

                    (ChangedFieldNo = Item.FieldNo("Description 2")) and
                    (VRTSetup."Item Cross Ref. Description(I)" = VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2):
                        ItemReference2.Description := Item."Description 2";

                    (ChangedFieldNo = Item.FieldNo(Description)) and
                    (VRTSetup."Item Ref. Description 2 (I)" = VRTSetup."Item Ref. Description 2 (I)"::ItemDescription1):
                        ItemReference2."Description 2" := CopyStr(Item.Description, 1, MaxStrLen(ItemReference2."Description 2"));

                    (ChangedFieldNo = Item.FieldNo("Description 2")) and
                    (VRTSetup."Item Ref. Description 2 (I)" = VRTSetup."Item Ref. Description 2 (I)"::ItemDescription2):
                        ItemReference2."Description 2" := Item."Description 2";
                end;
            end else begin
                case true of
                    (ChangedFieldNo = Item.FieldNo(Description)) and
                    (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1):
                        ItemReference2.Description := Item.Description;

                    (ChangedFieldNo = Item.FieldNo("Description 2")) and
                    (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2):
                        ItemReference2.Description := Item."Description 2";

                    (ChangedFieldNo = Item.FieldNo(Description)) and
                    (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::ItemDescription1):
                        ItemReference2."Description 2" := CopyStr(Item.Description, 1, MaxStrLen(ItemReference2."Description 2"));

                    (ChangedFieldNo = Item.FieldNo("Description 2")) and
                    (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::ItemDescription2):
                        ItemReference2."Description 2" := Item."Description 2";
                end;
            end;
            if Format(ItemReference) <> Format(ItemReference2) then
                ItemReference2.Modify();
        until ItemReference.Next() = 0;
    end;

    local procedure UpdateItemRefDescriptions(ItemVariant: Record "Item Variant"; ChangedFieldNo: Integer)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        VRTSetup: Record "NPR Variety Setup";
        Handled: Boolean;
    begin
        if not Item.Get(ItemVariant."Item No.") then
            exit;
        if not (VRTSetup.Get() and VRTSetup."Create Item Cross Ref. auto.") then
            exit;
        if not (
            ((ChangedFieldNo = ItemVariant.FieldNo(Description)) and
             ((VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1) or
              (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::VariantDescription1)))
            or
            ((ChangedFieldNo = ItemVariant.FieldNo("Description 2")) and
             ((VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2) or
              (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::VariantDescription2))))
        then
            exit;

        ItemReference.SetRange("Item No.", ItemVariant."Item No.");
        ItemReference.SetRange("Variant Code", ItemVariant.Code);
        ItemReference.SetFilter("Unit of Measure", '%1|%2', '', Item."Base Unit of Measure");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        OnBeforeUpdateItemVariantReferenceDescriptions(ItemReference, Item, ItemVariant, ChangedFieldNo, Handled);
        if Handled then
            exit;
        if ItemReference.IsEmpty() then
            exit;

        case true of
            (ChangedFieldNo = ItemVariant.FieldNo(Description)) and
            (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1):
                ItemReference.ModifyAll(Description, ItemVariant.Description);

            (ChangedFieldNo = ItemVariant.FieldNo("Description 2")) and
            (VRTSetup."Item Cross Ref. Description(V)" = VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2):
                ItemReference.ModifyAll(Description, ItemVariant."Description 2");

            (ChangedFieldNo = ItemVariant.FieldNo(Description)) and
            (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::VariantDescription1):
                ItemReference.ModifyAll("Description 2", CopyStr(ItemVariant.Description, 1, MaxStrLen(ItemReference."Description 2")));

            (ChangedFieldNo = ItemVariant.FieldNo("Description 2")) and
            (VRTSetup."Item Ref. Description 2 (V)" = VRTSetup."Item Ref. Description 2 (V)"::VariantDescription2):
                ItemReference.ModifyAll("Description 2", ItemVariant."Description 2");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ItemVariantsnBeforeDeleteEvent(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        if RunTrigger then
            VRTCheck.CheckItemVariantDeleteAllowed(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure C21OnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        if not CalledFromAdjustment then
            VRTCheck.PostingCheck(ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', true, false)]
    local procedure ItemOnAfterInsertEvent(var Rec: Record Item; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if RunTrigger then
            VRTCloneData.InsertDefaultBarcode(Rec."No.", '', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, false)]
    local procedure ItemOnAfterModifyEvent(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        VrtCheck: Codeunit "NPR Variety Check";
    begin
        if Rec.IsTemporary then
            exit;

        VrtCheck.ChangeItemVariety(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Variety Matrix", 'OnOpenPageEvent', '', false, false)]
    local procedure VarietyMatrixOnOpenPageEvent(var Rec: Record "NPR Variety Buffer")
    var
        VrtFieldSetup: Record "NPR Variety Field Setup";
    begin
        VrtFieldSetup.UpdateToLatestVersion();
    end;

    local procedure GetCalculationDate(DateIn: Date): Text
    begin
        if DateIn <> 0D then
            exit(Format(DateIn));

        exit(Format(WorkDate()));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateItemReferenceDescriptions(var ItemReference: Record "Item Reference"; Item: Record Item; ChangedFieldNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateItemVariantReferenceDescriptions(var ItemReference: Record "Item Reference"; Item: Record Item; ItemVariant: Record "Item Variant"; ChangedFieldNo: Integer; var Handled: Boolean)
    begin
    end;
}
