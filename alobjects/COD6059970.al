codeunit 6059970 "Variety Wrapper"
{
    // VRT1.01/MMV /20150513 CASE 213635 Added handling of RJL
    // NPR4.16/TJ  /20151103 CASE 222281 Added handling of Item Replenishment by Store
    // VRT1.11/JDH /20160530 CASE 242940 new events to support auto popup + moved event listeners to this CU
    // NPR5.23/JDH /20160620 CASE xxxxxx Code missing for Variety Group change
    // NPR5.23.02/JDH/20160624 CASE xxxxxx call to barcode creation mistakenly discontinued in CU 6014424
    // NPR5.27/BHR /20160928 CASE 250687 Fix, call retail function to display  correct description.
    // VRT1.20/JDH /20161213 CASE 260472 Moved Description control to new CU
    // VRT1.20/JDH /20170105 CASE 260516 Variety Lookup from Transfer lines
    // VRT1.20/JDH /20161012 CASE 251896 Missing call if a modification of Item variety setup is allowed
    // VRT1.20/JDH /20161012 CASE 262474 Event listeners implemented
    // NPR5.31/JDH /20170502 CASE 271133 Added Purchase Prices
    // NPR5.36/JDH /20170921 CASE 288696 Item Journal line added to Variety Matrix
    // NPR5.37/MHA /20171004 CASE 292138 Location Filter added to Show Variety from Document Line functions
    // NPR5.37/JDH /20171018 CASE 293486 Changed function ItemIsVariety to global
    // NPR5.37/JDH /20171023 CASE 293486 A new function "ShowVarietyMatrix" has been added, that is not used here, but rather to "copy paste" to pages where you want the Variety Matrix to popup
    // NPR5.47/JDH /20180918 CASE 327541 several filters transferred from the source to the matrix, so they can be used for calculation later
    // NPR5.51/THRO/20190716 CASE 361514 EventPublisherElement changed in P30OnAfterActionEventVariety. Action renamed on Page 30
    // NPR5.51/BHR /20190826 CASE 366143 Event Publisher for Item Journal 40OnAfterActionEventVariety


    trigger OnRun()
    begin
    end;

    procedure ShowVarietyMatrix(var ItemParm: Record Item;ShowFieldNo: Integer)
    var
        RecRef: RecordRef;
        VRTShowTable: Codeunit "Variety ShowTables";
        ItemVar: Record "Item Variant";
    begin
        with ItemParm do begin
          //test variant item
          TestItemIsVariety(ItemParm);
          //RecRef.GETTABLE(ItemParm);
          ItemVar.SetRange("Item No.", ItemParm."No.");
          RecRef.GetTable(ItemVar);
          VRTShowTable.ShowVarietyMatrix(RecRef, ItemParm, ShowFieldNo);
        end;
    end;

    procedure ShowMaintainItemMatrix(var ItemParm: Record Item;ShowFieldNo: Integer)
    var
        RecRef: RecordRef;
        VRTShowTable: Codeunit "Variety ShowTables";
        ItemVar: Record "Item Variant";
    begin
        //-VRT1.11
        with ItemParm do begin
          //test variant item
          TestItemIsVariety(ItemParm);
          //RecRef.GETTABLE(ItemParm);
          ItemVar.SetRange("Item No.", ItemParm."No.");
          //-NPR5.47 [327541]
          ItemParm.SetFilter("Date Filter", GetCalculationDate(WorkDate));
          //+NPR5.47 [327541]
          RecRef.GetTable(ItemVar);
          VRTShowTable.ShowBooleanMatrix(RecRef, ItemParm, ShowFieldNo);
        end;
        //+VRT1.11
    end;

    procedure SalesLineShowVariety(SalesLine: Record "Sales Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with SalesLine do begin
          //Fetch base data
          TestField(Type, Type::Item);
          Item.Get("No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Line No." = 0 then begin
              //virgin line
              "Is Master" := true;
              "Master Line No." := "Line No.";
              Modify;
              Commit;
            end else
              //existing Variety
              Get("Document Type", "Document No.", "Master Line No.");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(SalesLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",SalesLine."Location Code");
        //+NPR5.37 [292138]

        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(SalesLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", SalesLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", SalesLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", SalesLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        Item.SetFilter("Drop Shipment Filter", '%1', SalesLine."Drop Shipment");
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchLineShowVariety(PurchLine: Record "Purchase Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with PurchLine do begin
          //Fetch base data
          TestField(Type, Type::Item);
          Item.Get("No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Line No." = 0 then begin
              //virgin line
              "Is Master" := true;
              "Master Line No." := "Line No.";
              Modify;
              Commit;
            end else
              //existing Variety
              Get("Document Type", "Document No.", "Master Line No.");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(PurchLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",PurchLine."Location Code");
        //+NPR5.37 [292138]

        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(PurchLine."Expected Receipt Date"));
        Item.SetFilter("Global Dimension 1 Filter", PurchLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", PurchLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", PurchLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        Item.SetFilter("Drop Shipment Filter", '%1', PurchLine."Drop Shipment");
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure SalesShipmentLineShowVariety(SalesShipLine: Record "Sales Shipment Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with SalesShipLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(SalesShipLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",SalesShipLine."Location Code");
        //+NPR5.37 [292138]

        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(SalesShipLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", SalesShipLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", SalesShipLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", SalesShipLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        Item.SetFilter("Drop Shipment Filter", '%1', SalesShipLine."Drop Shipment");
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure SalesInvLineShowVariety(SalesInvLine: Record "Sales Invoice Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with SalesInvLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(SalesInvLine);
        //-NPR5.47 [327541]
        Item.SetFilter("Location Filter", SalesInvLine."Location Code");
        Item.SetFilter("Date Filter", GetCalculationDate(SalesInvLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", SalesInvLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", SalesInvLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", SalesInvLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        Item.SetFilter("Drop Shipment Filter", '%1', SalesInvLine."Drop Shipment");
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure SalesCrMemoLineShowVariety(SalesCrMemoLine: Record "Sales Cr.Memo Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with SalesCrMemoLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(SalesCrMemoLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",SalesCrMemoLine."Location Code");
        //+NPR5.37 [292138]
        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(SalesCrMemoLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", SalesCrMemoLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", SalesCrMemoLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", SalesCrMemoLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        //Item.SETFILTER("Drop Shipment Filter", '%1',
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchReceiptLineShowVariety(PurchRcptLine: Record "Purch. Rcpt. Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with PurchRcptLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(PurchRcptLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",PurchRcptLine."Location Code");
        //+NPR5.37 [292138]

        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(PurchRcptLine."Expected Receipt Date"));
        Item.SetFilter("Global Dimension 1 Filter", PurchRcptLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", PurchRcptLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", PurchRcptLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        //Item.SETFILTER("Drop Shipment Filter", '%1',
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchInvLineShowVariety(PurchInvLine: Record "Purch. Inv. Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with PurchInvLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(PurchInvLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",PurchInvLine."Location Code");
        //+NPR5.37 [292138]
        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(PurchInvLine."Expected Receipt Date"));
        Item.SetFilter("Global Dimension 1 Filter", PurchInvLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", PurchInvLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", PurchInvLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        //Item.SETFILTER("Drop Shipment Filter", '%1',
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchCrMemoLineShowVariety(PurchCrMemoLine: Record "Purch. Cr. Memo Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with PurchCrMemoLine do begin
          TestField(Type, Type::Item);
          Item.Get("No.");

          TestItemIsVariety(Item);
        end;

        RecRef.GetTable(PurchCrMemoLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",PurchCrMemoLine."Location Code");
        //+NPR5.37 [292138]
        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(PurchCrMemoLine."Expected Receipt Date"));
        Item.SetFilter("Global Dimension 1 Filter", PurchCrMemoLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", PurchCrMemoLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", PurchCrMemoLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        //Item.SETFILTER("Drop Shipment Filter", '%1',
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure SalesPriceShowVariety(SalesPrice: Record "Sales Price";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with SalesPrice do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Record Reference" = '' then begin
              //virgin line - can only be done on blank Variant Code
              TestField("Variant Code", '');
              "Is Master" := true;
              "Master Record Reference" := SalesPrice.GetPosition(false);
              Modify;
              Commit;
            end else
              //existing Variety
              SetPosition("Master Record Reference");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(SalesPrice);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure PurchPriceShowVariety(PurchPrice: Record "Purchase Price";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        with PurchPrice do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Record Reference" = '' then begin
              //virgin line - can only be done on blank Variant Code
              TestField("Variant Code", '');
              "Is Master" := true;
              "Master Record Reference" := PurchPrice.GetPosition(false);
              Modify;
              Commit;
            end else
              //existing Variety
              SetPosition("Master Record Reference");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(PurchPrice);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
    end;

    procedure RetailJournalLineShowVariety(RetailJournalLine: Record "Retail Journal Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        //-VRT1.01
        with RetailJournalLine do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Line No." = 0 then begin
              //virgin line
              "Is Master" := true;
              "Master Line No." := "Line No.";
              Modify;
              Commit;
            end else
              //existing Variety
              Get("No.","Line No.");
          end;
        end;

        RecRef.GetTable(RetailJournalLine);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
        //+VRT1.01
    end;

    procedure ItemReplenishmentShowVariety(ItemReplenishByStore: Record "Item Replenishment by Store";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        //-NPR4.16
        with ItemReplenishByStore do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Record Reference" = '' then begin
              //virgin line - can only be done on blank Variant Code
              TestField("Variant Code", '');
              "Is Master" := true;
              "Master Record Reference" := ItemReplenishByStore.GetPosition(false);
              Modify;
              Commit;
            end else
              //existing Variety
              SetPosition("Master Record Reference");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(ItemReplenishByStore);
        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
        //+NPR4.16
    end;

    local procedure ItemJnlLineShowVariety(ItemJnlLine: Record "Item Journal Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        //-NPR5.36 [288696]
        with ItemJnlLine do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Line No." = 0 then begin
              //virgin line
              "Is Master" := true;
              "Master Line No." := "Line No.";
              Modify;
              Commit;
            end else
              //existing Variety
              Get("Journal Template Name", "Journal Batch Name", "Line No.");
          end;
        end;

        //transfer the filter to the matrix, so inventory can be shown for this location
        if ItemJnlLine."Location Code" <> '' then
          Item.SetRange("Location Filter", ItemJnlLine."Location Code");

        RecRef.GetTable(ItemJnlLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",ItemJnlLine."Location Code");
        //+NPR5.37 [292138]
        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(ItemJnlLine."Posting Date"));
        Item.SetFilter("Global Dimension 1 Filter", ItemJnlLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", ItemJnlLine."Shortcut Dimension 2 Code");
        Item.SetFilter("Bin Filter", ItemJnlLine."Bin Code");
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        Item.SetFilter("Drop Shipment Filter", '%1', ItemJnlLine."Drop Shipment");
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
        //+NPR5.36 [288696]
    end;

    procedure TestItemIsVariety(Item: Record Item)
    begin
    end;

    procedure ItemIsVariety(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        //-VRT1.11
        if ItemNo = '' then
          exit(false);

        Item.Get(ItemNo);
        exit((Item."Variety 1" <> '') or (Item."Variety 2" <> '') or (Item."Variety 3" <> '') or (Item."Variety 4" <> ''));
        //+VRT1.11
    end;

    procedure TransferLineShowVariety(TransferLine: Record "Transfer Line";ShowFieldNo: Integer)
    var
        Item: Record Item;
        VRTShowTable: Codeunit "Variety ShowTables";
        RecRef: RecordRef;
    begin
        //-VRT1.20 [260516]
        with TransferLine do begin
          //Fetch base data
          Item.Get("Item No.");

          //check its a Variety item
          TestItemIsVariety(Item);

          //find or create a line that is a master line
          if not "Is Master" then begin
            if "Master Line No." = 0 then begin
              //virgin line
              "Is Master" := true;
              "Master Line No." := "Line No.";
              Modify;
              Commit;
            end else
              //existing Variety
              Get("Document No.", "Master Line No.");
          end;
        end;

        //Show the matrix form
        RecRef.GetTable(TransferLine);
        //-NPR5.37 [292138]
        Item.SetFilter("Location Filter",TransferLine."Transfer-from Code");
        //+NPR5.37 [292138]
        //-NPR5.47 [327541]
        Item.SetFilter("Date Filter", GetCalculationDate(TransferLine."Shipment Date"));
        Item.SetFilter("Global Dimension 1 Filter", TransferLine."Shortcut Dimension 1 Code");
        Item.SetFilter("Global Dimension 2 Filter", TransferLine."Shortcut Dimension 2 Code");
        //Item.SETFILTER("Bin Filter",
        //Item.SETFILTER("Lot No. Filter",
        //Item.SETFILTER("Serial No. Filter",
        //Item.SETFILTER("Drop Shipment Filter", '%1',
        //+NPR5.47 [327541]

        VRTShowTable.ShowVarietyMatrix(RecRef, Item, ShowFieldNo);
        //+VRT1.20 [260516]
    end;

    [EventSubscriber(ObjectType::Table, 5401, 'OnAfterInsertEvent', '', false, false)]
    local procedure T5401OnAfterInsertEvent(var Rec: Record "Item Variant";RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "Variety Clone Data";
    begin
        if RunTrigger then
        //-VRT1.00
          VRTCloneData.InsertDefaultBarcode(Rec."Item No.",Rec.Code,true);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Table, 5401, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure T5401OnBeforeDeleteEvent(var Rec: Record "Item Variant";RunTrigger: Boolean)
    var
        VRTCheck: Codeunit "Variety Check";
    begin
        if RunTrigger then
        //-VRT1.00
          VRTCheck.CheckItemVariantDeleteAllowed(Rec);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Codeunit, 21, 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure C21OnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        VRTCheck: Codeunit "Variety Check";
    begin
        //-VRT1.00
        VRTCheck.PostingCheck(ItemJnlLine);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'VarietyMatrix', false, false)]
    local procedure P30OnAfterActionEventVariety(var Rec: Record Item)
    var
        VRTWrapper: Codeunit "Variety Wrapper";
    begin
        //-VRT1.00
        VRTWrapper.ShowVarietyMatrix(Rec,0);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Page, 7002, 'OnAfterActionEvent', 'Variety', false, false)]
    local procedure P7002OnAfterActionEventVariety(var Rec: Record "Sales Price")
    var
        VRTWrapper: Codeunit "Variety Wrapper";
    begin
        //-VRT1.00
        VRTWrapper.SalesPriceShowVariety(Rec,0);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Page, 7012, 'OnAfterActionEvent', 'Variety', false, false)]
    local procedure P7012OnAfterActionEventVariety(var Rec: Record "Purchase Price")
    var
        VRTWrapper: Codeunit "Variety Wrapper";
    begin
        //-VRT1.00
        VRTWrapper.PurchPriceShowVariety(Rec,0);
        //+VRT1.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Variety Group', true, false)]
    local procedure T27OnAfterValVarietyGroup(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        VrtGroup: Record "Variety Group";
        VrtCheck: Codeunit "Variety Check";
    begin
        //-NPR5.23
        with Rec do begin
          if "Variety Group" = xRec."Variety Group" then
            exit;

          //updateitem
          if "Variety Group" = '' then
            VrtGroup.Init
          else
            VrtGroup.Get("Variety Group");
          "Variety 1" := VrtGroup."Variety 1";
          "Variety 1 Table" := VrtGroup.GetVariety1Table(Rec);
          "Variety 2" := VrtGroup."Variety 2";
          "Variety 2 Table" := VrtGroup.GetVariety2Table(Rec);
          "Variety 3" := VrtGroup."Variety 3";
          "Variety 3 Table" := VrtGroup.GetVariety3Table(Rec);
          "Variety 4" := VrtGroup."Variety 4";
          "Variety 4 Table" := VrtGroup.GetVariety4Table(Rec);
          "Cross Variety No." := VrtGroup."Cross Variety No.";

          //Above code will be executed IF its a temporary record - Below wont be executed if its a temporary record
          if Rec.IsTemporary then
            exit;

          //check change allowed
          VrtCheck.ChangeItemVariety(Rec, xRec);

          //copy base table info (if needed)
          VrtGroup.CopyTableData(Rec);
        end;
        //+NPR5.23
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, false)]
    local procedure T27OnAfterInsertEvent(var Rec: Record Item;RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "Variety Clone Data";
    begin
        //-NPR5.23.02
        if RunTrigger then
          VRTCloneData.InsertDefaultBarcode(Rec."No.",'',true);
        //+NPR5.23.02
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, false)]
    local procedure T27OnAfterModifyEvent(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    var
        VrtCheck: Codeunit "Variety Check";
    begin
        //-VRT1.20 [251896]
        if Rec.IsTemporary then
          exit;
        VrtCheck.ChangeItemVariety(Rec, xRec);
        //+VRT1.20 [251896]
    end;

    [EventSubscriber(ObjectType::Page, 40, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P40OnAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        //-NPR5.51 [366143]
        ItemJnlLineShowVariety(Rec,0);
        //+NPR5.51 [366143]
    end;

    [EventSubscriber(ObjectType::Page, 46, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P46OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        //-VRT1.20 [262474]
        SalesLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 47, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P47OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        //-VRT1.20 [262474]
        SalesLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P54OnAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        //-VRT1.20 [262474]
        PurchLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 55, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P55OnAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        //-VRT1.20 [262474]
        PurchLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 95, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P95OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        //-VRT1.20 [262474]
        SalesLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 96, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P96OnAfterActionEventShowVariety(var Rec: Record "Sales Line")
    begin
        //-VRT1.20 [262474]
        SalesLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 98, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P98OnAfterActionEventShowVariety(var Rec: Record "Purchase Line")
    begin
        //-VRT1.20 [262474]
        PurchLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 131, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P131OnAfterActionEventShowVariety(var Rec: Record "Sales Shipment Line")
    begin
        //-VRT1.20 [262474]
        SalesShipmentLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 133, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P133OnAfterActionEventShowVariety(var Rec: Record "Sales Invoice Line")
    begin
        //-VRT1.20 [262474]
        SalesInvLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 135, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P135OnAfterActionEventShowVariety(var Rec: Record "Sales Cr.Memo Line")
    begin
        //-VRT1.20 [262474]
        SalesCrMemoLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 137, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P137OnAfterActionEventShowVariety(var Rec: Record "Purch. Rcpt. Line")
    begin
        //-VRT1.20 [262474]
        PurchReceiptLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 139, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P139OnAfterActionEventShowVariety(var Rec: Record "Purch. Inv. Line")
    begin
        //-VRT1.20 [262474]
        PurchInvLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 141, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P141OnAfterActionEventShowVariety(var Rec: Record "Purch. Cr. Memo Line")
    begin
        //-VRT1.20 [262474]
        PurchCrMemoLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 393, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P393OnAfterActionEventShowVariety(var Rec: Record "Item Journal Line")
    begin
        //-NPR5.36 [288696]
        ItemJnlLineShowVariety(Rec,0);
        //+NPR5.36 [288696]
    end;

    [EventSubscriber(ObjectType::Page, 5741, 'OnAfterActionEvent', 'Variety', true, true)]
    local procedure P5741OnAfterActionEventShowVariety(var Rec: Record "Transfer Line")
    begin
        //-VRT1.20 [262474]
        TransferLineShowVariety(Rec,0);
        //+VRT1.20 [262474]
    end;

    [EventSubscriber(ObjectType::Page, 6059974, 'OnOpenPageEvent', '', false, false)]
    local procedure P6059974OnOpenPageEvent(var Rec: Record "Variety Buffer")
    var
        VrtFieldSetup: Record "Variety Field Setup";
    begin
        //-NPR5.36 [285733]
        VrtFieldSetup.UpdateToLatestVersion;
        //+NPR5.36 [285733]
    end;

    local procedure ShowVariety()
    var
        VarietyWrapper: Codeunit "Variety Wrapper";
    begin
        //-NPR5.37 [293486]
        //New Function that can be copy pasted to sales order subform pages (and with a small change purchase etc.) to show Variety Matrix after entering the item no.
        //This function must be placed directly on the subpage (due to the use of saverecord and update)
        //This function will thereby NOT work in Extensions.
        //a line of code must also be added on the field that should trigger the popup - should likely be field "No."
        /*
        IF Type <> Type::Item THEN
          EXIT;
        
        IF NOT VarietyWrapper.ItemIsVariety("No.") THEN
          EXIT;
        
        CurrPage.SAVERECORD;
        VarietyWrapper.SalesLineShowVariety(Rec, 0);
        CurrPage.UPDATE(FALSE);
        */
        //+NPR5.37 [293486]

    end;

    local procedure GetCalculationDate(DateIn: Date): Text
    begin
        //-NPR5.47 [327541]
        if DateIn <> 0D then
          exit(Format(DateIn));
        exit(Format(WorkDate));
        //+NPR5.47 [327541]
    end;
}

