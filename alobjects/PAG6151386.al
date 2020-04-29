page 6151386 "CS Stock-Takes Card"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Added field "Journal Template Name","Journal Batch Name","Inventory Calculated" and "Journal Qty. (Calculated)"
    // NPR5.54/CLVA/20200217  CASE 391080 Added fields "Unknown Entries" and "Manuel Posting". Added action "Tag Data"
    // NPR5.54/CLVA/20200225  CASE 392901 Added action "Update Predicted Qty."

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
                field("Journal Posted";"Journal Posted")
                {
                }
                field("Inventory Calculated";"Inventory Calculated")
                {
                }
                field("Predicted Qty.";"Predicted Qty.")
                {
                }
                field("Unknown Entries";"Unknown Entries")
                {
                }
                field("Manuel Posting";"Manuel Posting")
                {
                }
                field("Adjust Inventory";"Adjust Inventory")
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
            action("Tag Data")
            {
                Caption = 'Tag Data';
                Image = DataEntry;
                RunObject = Page "CS Stock-Takes Data List";
                RunPageLink = "Stock-Take Id"=FIELD("Stock-Take Id");
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
                action("Update Predicted Qty.")
                {
                    Caption = 'Update Predicted Qty.';

                    trigger OnAction()
                    var
                        CalcItemJournalLine: Record "Item Journal Line";
                        QtyCalculated: Decimal;
                    begin
                        if "Journal Posted" then
                          exit;

                        QtyCalculated := 0;
                        Clear(CalcItemJournalLine);
                        CalcItemJournalLine.SetRange("Journal Template Name","Journal Template Name");
                        CalcItemJournalLine.SetRange("Journal Batch Name","Journal Batch Name");
                        CalcItemJournalLine.SetRange("Location Code",Location);
                        if CalcItemJournalLine.FindSet then begin
                          repeat
                            QtyCalculated += CalcItemJournalLine."Qty. (Calculated)"
                          until CalcItemJournalLine.Next = 0;
                        end;

                        if Confirm(StrSubstNo(Txt001,Rec."Predicted Qty.",QtyCalculated),true) then begin
                          "Predicted Qty." := QtyCalculated;
                          Modify;
                        end;
                    end;
                }
                action("Set Manuel Posting")
                {
                    Caption = 'Set Manuel Posting';
                    Image = Add;

                    trigger OnAction()
                    begin
                        if "Journal Posted" then
                          exit;

                        "Manuel Posting" := true;
                        Modify;
                    end;
                }
                action("Remove Posting Flag")
                {
                    Caption = 'Remove Posting Flag';
                    Image = ReOpen;

                    trigger OnAction()
                    begin
                        if "Journal Posted" then begin
                          "Journal Posted" := false;
                          Modify;
                        end;
                    end;
                }
                action("Set Posting Flag")
                {
                    Caption = 'Set Posting Flag';
                    Image = Close;

                    trigger OnAction()
                    begin
                        if not "Journal Posted" then begin
                          "Journal Posted" := true;
                          Modify;
                        end;
                    end;
                }
            }
        }
    }

    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        Txt001: Label 'Update Predicted Qty. from %1 to %2';
}

