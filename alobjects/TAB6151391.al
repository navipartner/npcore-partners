table 6151391 "CS Stock-Takes"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Refactored to use Item Journal
    //                                    Added fields "Journal Template Name","Journal Batch Name","Predicted Qty." and "Inventory Calculated"
    // NPR5.52/CLVA/20191102 CASE 375749 Changed code to support version specific changes (NAV 2018+).

    Caption = 'CS Stock-Takes';

    fields
    {
        field(1;"Stock-Take Id";Guid)
        {
            Caption = 'Stock-Take Id';
        }
        field(10;Closed;DateTime)
        {
            Caption = 'Closed';
        }
        field(11;Location;Code[20])
        {
            Caption = 'Location';
            TableRelation = Location;
        }
        field(12;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(13;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(14;"Salesfloor Started";DateTime)
        {
            Caption = 'Salesfloor Started';
        }
        field(15;"Salesfloor Started By";Code[10])
        {
            Caption = 'Salesfloor Started By';
        }
        field(16;"Salesfloor Closed";DateTime)
        {
            Caption = 'Salesfloor Closed';
        }
        field(17;"Salesfloor Closed By";Code[20])
        {
            Caption = 'Salesfloor Closed By';
        }
        field(18;"Salesfloor Entries";Integer)
        {
            CalcFormula = Count("CS Stock-Takes Data" WHERE ("Stock-Take Id"=FIELD("Stock-Take Id"),
                                                             Area=CONST(Salesfloor)));
            Caption = 'Salesfloor Entries';
            FieldClass = FlowField;
        }
        field(19;"Stockroom Started";DateTime)
        {
            Caption = 'Stockroom Started';
        }
        field(20;"Stockroom Started By";Code[10])
        {
            Caption = 'Stockroom Started By';
        }
        field(21;"Stockroom Closed";DateTime)
        {
            Caption = 'Stockroom Closed';
        }
        field(22;"Stockroom Closed By";Code[20])
        {
            Caption = 'Stockroom Closed By';
        }
        field(23;"Stockroom Entries";Integer)
        {
            CalcFormula = Count("CS Stock-Takes Data" WHERE ("Stock-Take Id"=FIELD("Stock-Take Id"),
                                                             Area=CONST(Stockroom)));
            Caption = 'Stockroom Entries';
            FieldClass = FlowField;
        }
        field(24;"Refill Started";DateTime)
        {
            Caption = 'Refill Started';
        }
        field(25;"Refill Started By";Code[10])
        {
            Caption = 'Refill Started By';
        }
        field(26;"Refill Closed";DateTime)
        {
            Caption = 'Refill Closed';
        }
        field(27;"Refill Closed By";Code[20])
        {
            Caption = 'Refill Closed By';
        }
        field(28;"Salesfloor Duration";Duration)
        {
            Caption = 'Salesfloor Duration';
        }
        field(29;"Stockroom Duration";Duration)
        {
            Caption = 'Stockroom Duration';
        }
        field(30;"Refill Duration";Duration)
        {
            Caption = 'Refill Duration';
        }
        field(31;"Closed By";Code[10])
        {
            Caption = 'Closed By';
        }
        field(32;Approved;DateTime)
        {
            Caption = 'Approved';
        }
        field(33;"Approved By";Code[20])
        {
            Caption = 'Approved By';
        }
        field(34;Note;Text[250])
        {
            Caption = 'Note';
        }
        field(35;"Refill Entries";Integer)
        {
            CalcFormula = Count("CS Refill Data" WHERE ("Stock-Take Id"=FIELD("Stock-Take Id")));
            Caption = 'Refill Entries';
            FieldClass = FlowField;
        }
        field(36;"Create Refill Data Started";DateTime)
        {
            Caption = 'Create Refill Data Started';
        }
        field(37;"Create Refill Data Ended";DateTime)
        {
            Caption = 'Create Refill Data Ended';
        }
        field(38;"Journal Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Item Journal Template";
        }
        field(39;"Journal Batch Name";Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Journal Template Name"));
        }
        field(40;"Predicted Qty.";Decimal)
        {
            Caption = 'Predicted Qty.';
            Editable = false;
        }
        field(41;"Inventory Calculated";Boolean)
        {
            Caption = 'Inventory Calculated';
            Editable = false;
        }
        field(42;"Journal Posted";Boolean)
        {
            Caption = 'Journal Posted';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Stock-Take Id")
        {
        }
        key(Key2;Created)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        CSStockTakes.SetRange(Location,Location);
        CSStockTakes.SetRange(Closed, 0DT);
        if CSStockTakes.FindSet then
         Error(Err_CSStockTakes,"Stock-Take Id");
    end;

    trigger OnModify()
    begin
        if ("Salesfloor Closed" <> 0DT) and ("Stockroom Closed" <> 0DT) and ("Refill Closed" <> 0DT) and (Approved <> 0DT) then begin
         Closed := CurrentDateTime;
         "Closed By" := UserId;
        end;

        if "Salesfloor Closed" <> 0DT then
         "Salesfloor Duration" := "Salesfloor Closed" - "Salesfloor Started";
        if "Stockroom Closed" <> 0DT then
         "Stockroom Duration" := "Stockroom Closed" - "Stockroom Started";
        if "Refill Closed" <> 0DT then
         "Refill Duration" := "Refill Closed" - "Refill Started";
    end;

    var
        CSStockTakes: Record "CS Stock-Takes";
        Err_CSStockTakes: Label 'There is already an open Stock-Take with id %1';
        Err_ConfirmForceClose: Label 'This will delete Phy. Inventory Journal: %1 %2';
        Err_MissingLocation: Label 'Location is missing on POS Store';
        Err_SalesfloorClosed: Label 'Sales floor counting is not closed';
        Err_StockroomClosed: Label 'Stockroom counting is not closed';
        Err_RefillClosed: Label 'Refill is not closed';
        Txt_CountingCancelled: Label 'Counting was cancelled';
        Err_StockTakeWorksheetNotEmpty: Label 'Phy. Inventory Journal is not empty: %1 %2';
        Err_PostingIsScheduled: Label 'Phy. Inventory Journal is scheduled for posting: %1 %2';
        Text001: Label 'Location %1';
        Text002: Label 'Calculate Inventory for Location %1';
        Text003: Label 'There is no Items on Location %1';

    procedure CreateNewCounting()
    var
        LocationRec: Record Location;
        CSHelperFunctions: Codeunit "CS Helper Functions";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
        CSSetup: Record "CS Setup";
        ItemJournalTemplate: Record "Item Journal Template";
        CalculateInventory: Report "Calculate Inventory";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        QtyCalculated: Decimal;
    begin
        if not LocationRec.Get(GetFilter(Location)) then
          Error(Err_MissingLocation);

        //-NPR5.52 [364063]
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,Location);
        CSStockTakes.SetRange(Closed, 0DT);
        if CSStockTakes.FindSet then
         Error(Err_CSStockTakes,"Stock-Take Id");

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",LocationRec.Code) then begin
          ItemJournalBatch.Init;
          ItemJournalBatch.Validate("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
          ItemJournalBatch.Validate(Name,LocationRec.Code);
          ItemJournalBatch.Description := StrSubstNo(Text001,LocationRec.Code);
          ItemJournalBatch.Validate("No. Series",CSSetup."Phys. Inv Jour No. Series");
          ItemJournalBatch.Validate("Reason Code",ItemJournalTemplate."Reason Code");
          ItemJournalBatch.Insert(true);
        end else begin
          RecRef.GetTable(ItemJournalBatch);
          Clear(CSPostingBuffer);
          CSPostingBuffer.SetRange("Table No.",RecRef.Number);
          CSPostingBuffer.SetRange("Record Id",RecRef.RecordId);
          CSPostingBuffer.SetRange(Executed,false);
          if CSPostingBuffer.FindSet then
            Error(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
          if ItemJournalLine.Count > 0 then
            Error(Err_StockTakeWorksheetNotEmpty,ItemJournalLine."Journal Template Name",ItemJournalLine."Journal Batch Name");
        end;

        // CSHelperFunctions.CreateStockTakeWorksheet(Location,'SALESFLOOR',StockTakeWorksheet);
        // StockTakeWorksheet.TESTFIELD(Status,StockTakeWorksheet.Status::OPEN);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",StockTakeWorksheet.Name);
        // IF StockTakeWorksheetLine.COUNT > 0 THEN
        //  ERROR(Err_StockTakeWorksheetNotEmpty,StockTakeWorksheet."Stock-Take Config Code",StockTakeWorksheet.Name);
        //
        // CSHelperFunctions.CreateStockTakeWorksheet(Location,'STOCKROOM',StockTakeWorksheet);
        // StockTakeWorksheet.TESTFIELD(Status,StockTakeWorksheet.Status::OPEN);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",StockTakeWorksheet.Name);
        // IF StockTakeWorksheetLine.COUNT > 0 THEN
        //  ERROR(Err_StockTakeWorksheetNotEmpty,StockTakeWorksheet."Stock-Take Config Code",StockTakeWorksheet.Name);
        //
        // StockTakeConfiguration.GET(StockTakeWorksheet."Stock-Take Config Code");
        // StockTakeConfiguration."Inventory Calc. Date" := WORKDATE;
        // StockTakeConfiguration.MODIFY(TRUE);
        //+NPR5.52 [364063]

        Init;
        "Stock-Take Id" := CreateGuid;
        Created := CurrentDateTime;
        "Created By" := UserId;
        //-NPR5.52 [364063]
        //Location := GETFILTER(Location);
        Location := LocationRec.Code;
        "Journal Template Name" := ItemJournalBatch."Journal Template Name";
        "Journal Batch Name" := ItemJournalBatch.Name;
        //+NPR5.52 [364063]
        Insert(true);

        Commit;

        if Confirm(StrSubstNo(Text002,Location,true)) then begin
          Clear(ItemJournalLine);
          ItemJournalLine.Init;
          ItemJournalLine.Validate("Journal Template Name","Journal Template Name");
          ItemJournalLine.Validate("Journal Batch Name","Journal Batch Name");
          ItemJournalLine."Location Code" := Location;

          Clear(NoSeriesMgt);
          ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
          ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
          ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
          ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

          Clear(Item);
          Item.SetFilter("Location Filter",Location);
          if not Item.FindSet then
            Error(Text003,Location);

          Clear(CalculateInventory);
          CalculateInventory.UseRequestPage(false);
          CalculateInventory.SetTableView(Item);
          CalculateInventory.SetItemJnlLine(ItemJournalLine);
          //-NPR5.52 [375749]
          //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
          CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
          //+NPR5.52 [375749]
          CalculateInventory.RunModal;

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name","Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name","Journal Batch Name");
          ItemJournalLine.SetRange("Location Code",Location);
          if ItemJournalLine.FindSet then begin
            repeat
              QtyCalculated += ItemJournalLine."Qty. (Calculated)"
            until ItemJournalLine.Next = 0;
          end;

          "Predicted Qty." := QtyCalculated;
          "Inventory Calculated" := true;
          Modify(true);
        end;
    end;

    procedure CancelCounting()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        if Closed <> 0DT then
          exit;

        //-NPR5.52 [364063]
        if not LocationRec.Get(GetFilter(Location)) then
          Error(Err_MissingLocation);

        if ItemJournalBatch.Get("Journal Template Name","Journal Batch Name") then begin
          RecRef.GetTable(ItemJournalBatch);
          Clear(CSPostingBuffer);
          CSPostingBuffer.SetRange("Table No.",RecRef.Number);
          CSPostingBuffer.SetRange("Record Id",RecRef.RecordId);
          CSPostingBuffer.SetRange(Executed,false);
          if CSPostingBuffer.FindSet then
            Error(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          if not Confirm(StrSubstNo(Err_ConfirmForceClose,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name),true) then
            exit;

          ItemJournalBatch.Delete(true);

        end;
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'SALESFLOOR');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //
        // CLEAR(StockTakeWorksheetLine);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'STOCKROOM');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //+NPR5.52 [364063]

        Closed := CurrentDateTime;
        "Closed By" := UserId;
        Note := Txt_CountingCancelled;

        Modify(true);
    end;

    procedure ApproveCounting()
    begin
        if ("Salesfloor Closed" = 0DT) then
          Error(Err_SalesfloorClosed);

        if ("Stockroom Closed" = 0DT) then
          Error(Err_StockroomClosed);

        if ("Refill Closed" = 0DT) then
          Error(Err_RefillClosed);

        Approved := CurrentDateTime;
        "Approved By" := UserId;
        Modify(true);
    end;

    procedure CloseStockroom()
    begin
        if "Stockroom Closed" <> 0DT then
          exit;

        if ("Stockroom Started" = 0DT) then begin
          "Stockroom Started" := CurrentDateTime;
          "Stockroom Started By" := UserId;
        end;

        "Stockroom Closed" := CurrentDateTime;
        "Stockroom Closed By" := UserId;
        Modify(true);
    end;

    procedure CloseSalesfloor()
    begin
        if "Salesfloor Closed" <> 0DT then
          exit;

        if ("Salesfloor Started" = 0DT) then begin
          "Salesfloor Started" := CurrentDateTime;
          "Salesfloor Started By" := UserId;
        end;

        "Salesfloor Closed" := CurrentDateTime;
        "Salesfloor Closed By" := UserId;
        Modify(true);
    end;
}

