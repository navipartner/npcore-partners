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

    procedure PriceShowVariety(PriceListLine: Record "Price List Line"; ShowFieldNo: Integer)
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

    [EventSubscriber(ObjectType::Table, Page::"Item Variants", 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemVariantsOnAfterInsertEvent(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if RunTrigger then
            VRTCloneData.InsertDefaultBarcode(Rec."Item No.", Rec.Code, true);
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
    local procedure C21OnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        VRTCheck.PostingCheck(ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterActionEvent', 'NPR VarietyMatrix', false, false)]
    local procedure ItemCardAfterActionEventVariety(var Rec: Record Item)
    var
        VRTWrapper: Codeunit "NPR Variety Wrapper";
    begin
        VRTWrapper.ShowVarietyMatrix(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'NPR Variety Group', true, false)]
    local procedure T27OnAfterValVarietyGroup(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        VrtGroup: Record "NPR Variety Group";
        VrtCheck: Codeunit "NPR Variety Check";
    begin
        if Rec."NPR Variety Group" = xRec."NPR Variety Group" then
            exit;

        //updateitem
        if Rec."NPR Variety Group" = '' then
            VrtGroup.Init()
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

    [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure ItemJournalAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        ItemJnlLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure SalesOrderSubformAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure SalesInvoiceSubformAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure PurchaseOrderSubformAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        PurchLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Return Order Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure PurchReturnOrderSubformOnAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        PurchLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure SalesQuoteSubformAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure SalesCrMemoSubformAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        SalesLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Reclass. Journal", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure ItemReclassJournalAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        ItemJnlLineShowVariety(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order Subform", 'OnAfterActionEvent', 'NPR Variety', true, true)]
    local procedure TransferOrderSubformAfterActionEventShowVariety(var Rec: Record "Transfer Line")
    begin
        TransferLineShowVariety(Rec, 0);
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
}