page 6151385 "CS Stock-Takes List"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created

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
                begin
                    CreateNewCounting();
                end;
            }
            action("Force Close")
            {
                Caption = 'Force Close';
                Image = Cancel;

                trigger OnAction()
                begin
                    CancelCounting();
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
                action("&Worksheets")
                {
                    Caption = '&Worksheets';
                    Image = Worksheet2;
                    RunObject = Page "Stock-Take Worksheet";
                    RunPageLink = "Stock-Take Config Code"=FIELD(Location);
                }
            }
            group(Process)
            {
                Caption = 'Process';
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
}

