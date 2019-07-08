table 6151391 "CS Stock-Takes"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created

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
                                                             "Worksheet Name"=FILTER('SALESFLOOR')));
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
                                                             "Worksheet Name"=FILTER('STOCKROOM')));
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
        Err_ConfirmForceClose: Label 'This will delete all Stock-Take Worksheet lines for location %1';
        Err_MissingLocation: Label 'Location is missing on POS Store';
        Err_SalesfloorClosed: Label 'Sales floor counting is not closed';
        Err_StockroomClosed: Label 'Stockroom counting is not closed';
        Err_RefillClosed: Label 'Refill is not closed';
        Txt_CountingCancelled: Label 'Counting was cancelled';
        Err_StockTakeWorksheetNotEmpty: Label 'Worksheet is not empty for Stock-Take %1 %2';

    procedure CreateNewCounting()
    var
        LocationRec: Record Location;
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        CSHelperFunctions: Codeunit "CS Helper Functions";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        StockTakeConfiguration: Record "Stock-Take Configuration";
    begin
        if not LocationRec.Get(GetFilter(Location)) then
          Error(Err_MissingLocation);

        CSHelperFunctions.CreateStockTakeWorksheet(Location,'SALESFLOOR',StockTakeWorksheet);
        StockTakeWorksheet.TestField(Status,StockTakeWorksheet.Status::OPEN);
        StockTakeWorksheetLine.SetRange("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorksheetLine.SetRange("Worksheet Name",StockTakeWorksheet.Name);
        if StockTakeWorksheetLine.Count > 0 then
          Error(Err_StockTakeWorksheetNotEmpty,StockTakeWorksheet."Stock-Take Config Code",StockTakeWorksheet.Name);

        CSHelperFunctions.CreateStockTakeWorksheet(Location,'STOCKROOM',StockTakeWorksheet);
        StockTakeWorksheet.TestField(Status,StockTakeWorksheet.Status::OPEN);
        StockTakeWorksheetLine.SetRange("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorksheetLine.SetRange("Worksheet Name",StockTakeWorksheet.Name);
        if StockTakeWorksheetLine.Count > 0 then
          Error(Err_StockTakeWorksheetNotEmpty,StockTakeWorksheet."Stock-Take Config Code",StockTakeWorksheet.Name);

        StockTakeConfiguration.Get(StockTakeWorksheet."Stock-Take Config Code");
        StockTakeConfiguration."Inventory Calc. Date" := WorkDate;
        StockTakeConfiguration.Modify(true);

        Init;
        "Stock-Take Id" := CreateGuid;
        Created := CurrentDateTime;
        "Created By" := UserId;
        Location := GetFilter(Location);
        Insert(true);
    end;

    procedure CancelCounting()
    var
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
    begin
        if Closed <> 0DT then
          exit;

        if not Confirm(StrSubstNo(Err_ConfirmForceClose,Location),true) then
          exit;

        StockTakeWorksheetLine.SetRange("Stock-Take Config Code",Location);
        StockTakeWorksheetLine.SetRange("Worksheet Name",'SALESFLOOR');
        StockTakeWorksheetLine.DeleteAll(true);

        Clear(StockTakeWorksheetLine);
        StockTakeWorksheetLine.SetRange("Stock-Take Config Code",Location);
        StockTakeWorksheetLine.SetRange("Worksheet Name",'STOCKROOM');
        StockTakeWorksheetLine.DeleteAll(true);

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

