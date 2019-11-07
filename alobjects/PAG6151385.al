page 6151385 "CS Stock-Takes List"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Added field "Journal Qty. (Calculated)"

    Caption = 'CS Stock-Takes List';
    CardPageID = "CS Stock-Takes Card";
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Stock-Takes";
    SourceTableView = SORTING(Created)
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Location;Location)
                {
                }
                field(Created;Created)
                {
                }
                field(Closed;Closed)
                {
                }
                field(Approved;Approved)
                {
                }
                field("Salesfloor Started";"Salesfloor Started")
                {
                }
                field("Salesfloor Duration";"Salesfloor Duration")
                {
                }
                field("Salesfloor Entries";"Salesfloor Entries")
                {
                }
                field("Stockroom Started";"Stockroom Started")
                {
                }
                field("Stockroom Duration";"Stockroom Duration")
                {
                }
                field("Stockroom Entries";"Stockroom Entries")
                {
                }
                field("Refill Started";"Refill Started")
                {
                }
                field("Refill Duration";"Refill Duration")
                {
                }
                field("Refill Entries";"Refill Entries")
                {
                }
                field("Inventory Calculated";"Inventory Calculated")
                {
                }
                field("Predicted Qty.";"Predicted Qty.")
                {
                }
                field("Journal Posted";"Journal Posted")
                {
                }
                field("Stock-Take Id";"Stock-Take Id")
                {
                }
                field(Note;Note)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("New Counting")
            {
                Caption = 'New Counting';
                Image = LedgerEntries;

                trigger OnAction()
                var
                    LocationRec: Record Location;
                begin
                    //CreateNewCounting();
                    if not LocationRec.Get(GetFilter(Location)) then
                      Error(Err_MissingLocation);

                    CSHelperFunctions.CreateNewCounting(LocationRec);
                    CurrPage.Update();
                end;
            }
            action("Force Close")
            {
                Caption = 'Force Close';
                Image = Cancel;

                trigger OnAction()
                begin
                    //CancelCounting();

                    CSHelperFunctions.CancelCounting(Rec);
                    CurrPage.Update();
                end;
            }
            group(Overview)
            {
                Caption = 'Overview';
                action(Devices)
                {
                    Caption = 'Devices';
                    Image = MiniForm;
                    RunObject = Page "CS Devices";
                    RunPageLink = Location=FIELD(Location);
                }
                action("&Item Journal")
                {
                    Caption = '&Item Journal';
                    Image = Worksheet2;
                    RunObject = Page "Phys. Inventory Journal";
                    RunPageLink = "Journal Template Name"=FIELD("Journal Template Name"),
                                  "Journal Batch Name"=FIELD("Journal Batch Name");
                }
                action("&Item Journal Batch")
                {
                    Caption = '&Item Journal Batch';
                    Image = InventoryJournal;
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST("Phys. Inventory"));
                }
            }
            group(Process)
            {
                Caption = 'Process';
                Visible = false;
                action("1. Close Stockroom")
                {
                    Caption = '1. Close Stockroom';
                    Image = Close;

                    trigger OnAction()
                    var
                        CSWS: Codeunit "CS WS";
                    begin
                        CSWS.CloseCounting("Stock-Take Id",'STOCKROOM');
                    end;
                }
                action("2. Close Sales Floor")
                {
                    Caption = '2. Close Sales Floor';
                    Image = Close;

                    trigger OnAction()
                    var
                        CSWS: Codeunit "CS WS";
                    begin
                        CSWS.CloseCounting("Stock-Take Id",'SALESFLOOR');
                    end;
                }
                action("3. Approve Counting")
                {
                    Caption = '3. Approve Counting';
                    Image = Approve;

                    trigger OnAction()
                    var
                        CSWS: Codeunit "CS WS";
                    begin
                        CSWS.ApproveCounting("Stock-Take Id");
                    end;
                }
                action("4. View Refill Suggestions")
                {
                    Caption = '4. View Refill Suggestions';
                    Image = View;
                    RunObject = Page "CS Refill Data";
                    RunPageLink = "Stock-Take Id"=FIELD("Stock-Take Id");
                }
                action("5. Close Refill")
                {
                    Caption = '5. Close Refill';
                    Image = Close;

                    trigger OnAction()
                    var
                        CSWS: Codeunit "CS WS";
                    begin
                        CSWS.CloseRefill("Stock-Take Id");
                    end;
                }
            }
        }
    }

    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        Err_MissingLocation: Label 'Location is missing on POS Store';
}

