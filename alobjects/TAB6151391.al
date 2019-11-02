table 6151391 "CS Stock-Takes"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Refactored to use Item Journal
    //                                    Added fields "Journal Template Name","Journal Batch Name","Predicted Qty." and "Inventory Calculated"

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
            CalcFormula = Count("CS Stock-Takes Data" WHERE (Stock-Take Id=FIELD(Stock-Take Id), Area=CONST(Salesfloor)));
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
            CalcFormula = Count("CS Stock-Takes Data" WHERE (Stock-Take Id=FIELD(Stock-Take Id), Area=CONST(Stockroom)));
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
            CalcFormula = Count("CS Refill Data" WHERE (Stock-Take Id=FIELD(Stock-Take Id)));
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
            TableRelation = "Item Journal Batch".Name WHERE (Journal Template Name=FIELD(Journal Template Name));
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
        CSStockTakes.SETRANGE(Location,Location);
        CSStockTakes.SETRANGE(Closed, 0DT);
        IF CSStockTakes.FINDSET THEN
         ERROR(Err_CSStockTakes,"Stock-Take Id");
    end;

    trigger OnModify()
    begin
        IF ("Salesfloor Closed" <> 0DT) AND ("Stockroom Closed" <> 0DT) AND ("Refill Closed" <> 0DT) AND (Approved <> 0DT) THEN BEGIN
         Closed := CURRENTDATETIME;
         "Closed By" := USERID;
        END;

        IF "Salesfloor Closed" <> 0DT THEN
         "Salesfloor Duration" := "Salesfloor Closed" - "Salesfloor Started";
        IF "Stockroom Closed" <> 0DT THEN
         "Stockroom Duration" := "Stockroom Closed" - "Stockroom Started";
        IF "Refill Closed" <> 0DT THEN
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
        IF NOT LocationRec.GET(GETFILTER(Location)) THEN
          ERROR(Err_MissingLocation);

        //-NPR5.52 [364063]
        CLEAR(CSStockTakes);
        CSStockTakes.SETRANGE(Location,Location);
        CSStockTakes.SETRANGE(Closed, 0DT);
        IF CSStockTakes.FINDSET THEN
         ERROR(Err_CSStockTakes,"Stock-Take Id");

        CSSetup.GET;
        CSSetup.TESTFIELD("Phys. Inv Jour Temp Name");
        ItemJournalTemplate.GET(CSSetup."Phys. Inv Jour Temp Name");
        IF NOT ItemJournalBatch.GET(CSSetup."Phys. Inv Jour Temp Name",LocationRec.Code) THEN BEGIN
          ItemJournalBatch.INIT;
          ItemJournalBatch.VALIDATE("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
          ItemJournalBatch.VALIDATE(Name,LocationRec.Code);
          ItemJournalBatch.Description := STRSUBSTNO(Text001,LocationRec.Code);
          ItemJournalBatch.VALIDATE("No. Series",CSSetup."Phys. Inv Jour No. Series");
          ItemJournalBatch.VALIDATE("Reason Code",ItemJournalTemplate."Reason Code");
          ItemJournalBatch.INSERT(TRUE);
        END ELSE BEGIN
          RecRef.GETTABLE(ItemJournalBatch);
          CLEAR(CSPostingBuffer);
          CSPostingBuffer.SETRANGE("Table No.",RecRef.NUMBER);
          CSPostingBuffer.SETRANGE("Record Id",RecRef.RECORDID);
          CSPostingBuffer.SETRANGE(Executed,FALSE);
          IF CSPostingBuffer.FINDSET THEN
            ERROR(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          CLEAR(ItemJournalLine);
          ItemJournalLine.SETRANGE("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SETRANGE("Journal Batch Name",ItemJournalBatch.Name);
          IF ItemJournalLine.COUNT > 0 THEN
            ERROR(Err_StockTakeWorksheetNotEmpty,ItemJournalLine."Journal Template Name",ItemJournalLine."Journal Batch Name");
        END;

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

        INIT;
        "Stock-Take Id" := CREATEGUID;
        Created := CURRENTDATETIME;
        "Created By" := USERID;
        //-NPR5.52 [364063]
        //Location := GETFILTER(Location);
        Location := LocationRec.Code;
        "Journal Template Name" := ItemJournalBatch."Journal Template Name";
        "Journal Batch Name" := ItemJournalBatch.Name;
        //+NPR5.52 [364063]
        INSERT(TRUE);

        COMMIT;

        IF CONFIRM(STRSUBSTNO(Text002,Location,TRUE)) THEN BEGIN
          CLEAR(ItemJournalLine);
          ItemJournalLine.INIT;
          ItemJournalLine.VALIDATE("Journal Template Name","Journal Template Name");
          ItemJournalLine.VALIDATE("Journal Batch Name","Journal Batch Name");
          ItemJournalLine."Location Code" := Location;

          CLEAR(NoSeriesMgt);
          ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",FALSE);
          ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
          ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
          ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

          CLEAR(Item);
          Item.SETFILTER("Location Filter",Location);
          IF NOT Item.FINDSET THEN
            ERROR(Text003,Location);

          CLEAR(CalculateInventory);
          CalculateInventory.USEREQUESTPAGE(FALSE);
          CalculateInventory.SETTABLEVIEW(Item);
          CalculateInventory.SetItemJnlLine(ItemJournalLine);
          CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
          CalculateInventory.RUNMODAL;

          CLEAR(ItemJournalLine);
          ItemJournalLine.SETRANGE("Journal Template Name","Journal Template Name");
          ItemJournalLine.SETRANGE("Journal Batch Name","Journal Batch Name");
          ItemJournalLine.SETRANGE("Location Code",Location);
          IF ItemJournalLine.FINDSET THEN BEGIN
            REPEAT
              QtyCalculated += ItemJournalLine."Qty. (Calculated)"
            UNTIL ItemJournalLine.NEXT = 0;
          END;

          "Predicted Qty." := QtyCalculated;
          "Inventory Calculated" := TRUE;
          MODIFY(TRUE);
        END;
    end;

    procedure CancelCounting()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        IF Closed <> 0DT THEN
          EXIT;

        //-NPR5.52 [364063]
        IF NOT LocationRec.GET(GETFILTER(Location)) THEN
          ERROR(Err_MissingLocation);

        IF ItemJournalBatch.GET("Journal Template Name","Journal Batch Name") THEN BEGIN
          RecRef.GETTABLE(ItemJournalBatch);
          CLEAR(CSPostingBuffer);
          CSPostingBuffer.SETRANGE("Table No.",RecRef.NUMBER);
          CSPostingBuffer.SETRANGE("Record Id",RecRef.RECORDID);
          CSPostingBuffer.SETRANGE(Executed,FALSE);
          IF CSPostingBuffer.FINDSET THEN
            ERROR(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          IF NOT CONFIRM(STRSUBSTNO(Err_ConfirmForceClose,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name),TRUE) THEN
            EXIT;

          ItemJournalBatch.DELETE(TRUE);

        END;
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'SALESFLOOR');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //
        // CLEAR(StockTakeWorksheetLine);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'STOCKROOM');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //+NPR5.52 [364063]

        Closed := CURRENTDATETIME;
        "Closed By" := USERID;
        Note := Txt_CountingCancelled;

        MODIFY(TRUE);
    end;

    procedure ApproveCounting()
    begin
        IF ("Salesfloor Closed" = 0DT) THEN
          ERROR(Err_SalesfloorClosed);

        IF ("Stockroom Closed" = 0DT) THEN
          ERROR(Err_StockroomClosed);

        IF ("Refill Closed" = 0DT) THEN
          ERROR(Err_RefillClosed);

        Approved := CURRENTDATETIME;
        "Approved By" := USERID;
        MODIFY(TRUE);
    end;

    procedure CloseStockroom()
    begin
        IF "Stockroom Closed" <> 0DT THEN
          EXIT;

        IF ("Stockroom Started" = 0DT) THEN BEGIN
          "Stockroom Started" := CURRENTDATETIME;
          "Stockroom Started By" := USERID;
        END;

        "Stockroom Closed" := CURRENTDATETIME;
        "Stockroom Closed By" := USERID;
        MODIFY(TRUE);
    end;

    procedure CloseSalesfloor()
    begin
        IF "Salesfloor Closed" <> 0DT THEN
          EXIT;

        IF ("Salesfloor Started" = 0DT) THEN BEGIN
          "Salesfloor Started" := CURRENTDATETIME;
          "Salesfloor Started By" := USERID;
        END;

        "Salesfloor Closed" := CURRENTDATETIME;
        "Salesfloor Closed By" := USERID;
        MODIFY(TRUE);
    end;
}

