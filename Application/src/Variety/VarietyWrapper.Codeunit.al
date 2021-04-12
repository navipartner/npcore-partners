codeunit 6059970 "NPR Variety Wrapper"
{
    procedure ShowVarietyMatrix(var ItemParm: Record Item; ShowFieldNo: Integer)
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

    procedure ShowMaintainItemMatrix(var ItemParm: Record Item; ShowFieldNo: Integer)
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

    procedure SalesLineShowVariety(SalesLine: Record "Sales Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        SalesLine.TestField(SalesLine.Type, SalesLine.Type::Item);
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

    procedure PurchLineShowVariety(PurchLine: Record "Purchase Line"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        PurchLine.TestField(PurchLine.Type, PurchLine.Type::Item);
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

    procedure SalesPriceShowVariety(SalesPrice: Record "Sales Price"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(SalesPrice."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Sales Price", SalesPrice.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line - can only be done on blank Variant Code
                SalesPrice.TestField(SalesPrice."Variant Code", '');
                MasterLineMapMgt.CreateMap(Database::"Sales Price", SalesPrice.SystemId, SalesPrice.SystemId);
                Commit();
            end else
                //existing Variety
                SalesPrice.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(SalesPrice);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchPriceShowVariety(PurchPrice: Record "Purchase Price"; ShowFieldNo: Integer)
    var
        Item: Record Item;
        MasterLineMap: Record "NPR Master Line Map";
        VRTShowTable: Codeunit "NPR Variety ShowTables";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //Fetch base data
        Item.Get(PurchPrice."Item No.");
        //check its a Variety item
        TestItemIsVariety(Item);
        //find or create a line that is a master line
        if not MasterLineMap.Get(Database::"Purchase Price", PurchPrice.SystemId) then
            Clear(MasterLineMap);

        if not MasterLineMap."Is Master" then
            if IsNullGuid(MasterLineMap."Master Id") then begin
                //virgin line - can only be done on blank Variant Code
                PurchPrice.TestField(PurchPrice."Variant Code", '');
                MasterLineMapMgt.CreateMap(Database::"Purchase Price", PurchPrice.SystemId, PurchPrice.SystemId);
                Commit();
            end else
                //existing Variety
                PurchPrice.GetBySystemId(MasterLineMap."Master Id");

        //Show the matrix form
        RecRef.GetTable(PurchPrice);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure RetailJournalLineShowVariety(RetailJournalLine: Record "NPR Retail Journal Line"; ShowFieldNo: Integer)
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

    procedure ItemReplenishmentShowVariety(ItemReplenishByStore: Record "NPR Item Repl. by Store"; ShowFieldNo: Integer)
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

    local procedure ItemJnlLineShowVariety(ItemJnlLine: Record "Item Journal Line"; ShowFieldNo: Integer)
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

    procedure TestItemIsVariety(Item: Record Item)
    begin
        // forgotten check? todo?
    end;

    procedure TransferLineShowVariety(TransferLine: Record "Transfer Line"; ShowFieldNo: Integer)
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

    [EventSubscriber(ObjectType::Table, 5401, 'OnAfterInsertEvent', '', false, false)]
    local procedure T5401OnAfterInsertEvent(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if RunTrigger then
            VRTCloneData.InsertDefaultBarcode(Rec."Item No.", Rec.Code, true);
    end;

    [EventSubscriber(ObjectType::Table, 5401, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure T5401OnBeforeDeleteEvent(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        if RunTrigger then
            VRTCheck.CheckItemVariantDeleteAllowed(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 21, 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure C21OnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        VRTCheck.PostingCheck(ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'NPR VarietyMatrix', false, false)]
    local procedure P30OnAfterActionEventVariety(var Rec: Record Item)
    var
        VRTWrapper: Codeunit "NPR Variety Wrapper";
    begin
        VRTWrapper.ShowVarietyMatrix(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 7002, 'OnAfterActionEvent', 'NPR Variety', false, false)]
    local procedure P7002OnAfterActionEventVariety(var Rec: Record "Sales Price")
    var
        VRTWrapper: Codeunit "NPR Variety Wrapper";
    begin
        VRTWrapper.SalesPriceShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 7012, 'OnAfterActionEvent', 'NPR Variety', false, false)]
    local procedure P7012OnAfterActionEventVariety(var Rec: Record "Purchase Price")
    var
        VRTWrapper: Codeunit "NPR Variety Wrapper";
    begin
        VRTWrapper.PurchPriceShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Variety Group', true, false)]
    local procedure T27OnAfterValVarietyGroup(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        VrtGroup: Record "NPR Variety Group";
        VrtCheck: Codeunit "NPR Variety Check";
    begin
        if Rec."NPR Variety Group" = xRec."NPR Variety Group" then
            exit;

        //updateitem
        if Rec."NPR Variety Group" = '' then
            VrtGroup.Init
        else
            VrtGroup.Get(Rec."NPR Variety Group");

        Rec."NPR Variety 1" := VrtGroup."Variety 1";
        Rec."NPR Variety 1 Table" := VrtGroup.GetVariety1Table(Rec);
        Rec."NPR Variety 2" := VrtGroup."Variety 2";
        Rec."NPR Variety 2 Table" := VrtGroup.GetVariety2Table(Rec);
        Rec."NPR Variety 3" := VrtGroup."Variety 3";
        Rec."NPR Variety 3 Table" := VrtGroup.GetVariety3Table(Rec);
        Rec."NPR Variety 4" := VrtGroup."Variety 4";
        Rec."NPR Variety 4 Table" := VrtGroup.GetVariety4Table(Rec);
        Rec."NPR Cross Variety No." := VrtGroup."Cross Variety No.";

        //Above code will be executed IF its a temporary record - Below wont be executed if its a temporary record
        if Rec.IsTemporary then
            exit;
        //check change allowed
        VrtCheck.ChangeItemVariety(Rec, xRec);
        //copy base table info (if needed)
        VrtGroup.CopyTableData(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, false)]
    local procedure T27OnAfterInsertEvent(var Rec: Record Item; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if RunTrigger then
            VRTCloneData.InsertDefaultBarcode(Rec."No.", '', true);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, false)]
    local procedure T27OnAfterModifyEvent(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        VrtCheck: Codeunit "NPR Variety Check";
    begin
        if Rec.IsTemporary then
            exit;

        VrtCheck.ChangeItemVariety(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, 40, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P40OnAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        ItemJnlLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 46, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P46OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 47, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P47OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P54OnAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        PurchLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 95, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P95OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 96, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P96OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 393, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P393OnAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        ItemJnlLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 5741, 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure P5741OnAfterActionEventShowVariety(var Rec: Record "Transfer Line")
    begin
        TransferLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, 6059974, 'OnOpenPageEvent', '', false, false)]
    local procedure P6059974OnOpenPageEvent(var Rec: Record "NPR Variety Buffer")
    var
        VrtFieldSetup: Record "NPR Variety Field Setup";
    begin
        VrtFieldSetup.UpdateToLatestVersion;
    end;

    local procedure GetCalculationDate(DateIn: Date): Text
    begin
        if DateIn <> 0D then
            exit(Format(DateIn));

        exit(Format(WorkDate()));
    end;
}