page 6151386 "CS Stock-Takes Card"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Added field "Journal Template Name","Journal Batch Name","Inventory Calculated" and "Journal Qty. (Calculated)"

    Caption = 'CS Stock-Takes Card';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "CS Stock-Takes";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Stock-Take Id";"Stock-Take Id")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field(Closed;Closed)
                {
                }
                field("Closed By";"Closed By")
                {
                }
                field(Approved;Approved)
                {
                }
                field("Approved By";"Approved By")
                {
                }
                field(Location;Location)
                {
                }
                field("Journal Template Name";"Journal Template Name")
                {
                }
                field("Journal Batch Name";"Journal Batch Name")
                {
                }
                field("Inventory Calculated";"Inventory Calculated")
                {
                }
                field("Predicted Qty.";"Predicted Qty.")
                {
                }
                field(Note;Note)
                {
                }
            }
            group(Stockroom)
            {
                field("Stockroom Started";"Stockroom Started")
                {
                }
                field("Stockroom Started By";"Stockroom Started By")
                {
                }
                field("Stockroom Entries";"Stockroom Entries")
                {
                }
                field("Stockroom Closed";"Stockroom Closed")
                {
                }
                field("Stockroom Closed By";"Stockroom Closed By")
                {
                }
                field("Stockroom Duration";"Stockroom Duration")
                {
                }
            }
            group("Sales floor")
            {
                field("Salesfloor Started";"Salesfloor Started")
                {
                }
                field("Salesfloor Started By";"Salesfloor Started By")
                {
                }
                field("Salesfloor Entries";"Salesfloor Entries")
                {
                }
                field("Salesfloor Closed";"Salesfloor Closed")
                {
                }
                field("Salesfloor Closed By";"Salesfloor Closed By")
                {
                }
                field("Salesfloor Duration";"Salesfloor Duration")
                {
                }
            }
            group(Refill)
            {
                field("Refill Started";"Refill Started")
                {
                }
                field("Refill Started By";"Refill Started By")
                {
                }
                field("Refill Entries";"Refill Entries")
                {
                }
                field("Refill Closed";"Refill Closed")
                {
                }
                field("Refill Closed By";"Refill Closed By")
                {
                }
                field("Refill Duration";"Refill Duration")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Force Close")
            {
                Caption = 'Force Close';
                Image = Cancel;

                trigger OnAction()
                begin
                    //-NPR5.52 [364063]
                    //CancelCounting();

                    CSHelperFunctions.CancelCounting(Rec);
                    CurrPage.Update();
                    //+NPR5.52 [364063]
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
}

