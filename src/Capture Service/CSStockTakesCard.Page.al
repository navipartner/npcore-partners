page 6151386 "NPR CS Stock-Takes Card"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Added field "Journal Template Name","Journal Batch Name","Inventory Calculated" and "Journal Qty. (Calculated)"
    // NPR5.54/CLVA/20200217  CASE 391080 Added fields "Unknown Entries" and "Manuel Posting". Added action "Tag Data"
    // NPR5.54/CLVA/20200225  CASE 392901 Added action "Update Predicted Qty."
    // NPR5.55/ALST/20200727  CASE 415521 added action "Update Unknown Entries"

    Caption = 'CS Stock-Takes Card';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "NPR CS Stock-Takes";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Stock-Take Id"; "Stock-Take Id")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                }
                field("Closed By"; "Closed By")
                {
                    ApplicationArea = All;
                }
                field(Approved; Approved)
                {
                    ApplicationArea = All;
                }
                field("Approved By"; "Approved By")
                {
                    ApplicationArea = All;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Posted"; "Journal Posted")
                {
                    ApplicationArea = All;
                }
                field("Inventory Calculated"; "Inventory Calculated")
                {
                    ApplicationArea = All;
                }
                field("Predicted Qty."; "Predicted Qty.")
                {
                    ApplicationArea = All;
                }
                field("Unknown Entries"; "Unknown Entries")
                {
                    ApplicationArea = All;
                }
                field("Manuel Posting"; "Manuel Posting")
                {
                    ApplicationArea = All;
                }
                field("Adjust Inventory"; "Adjust Inventory")
                {
                    ApplicationArea = All;
                }
                field(Note; Note)
                {
                    ApplicationArea = All;
                }
            }
            group(Stockroom)
            {
                field("Stockroom Started"; "Stockroom Started")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Started By"; "Stockroom Started By")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Entries"; "Stockroom Entries")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Closed"; "Stockroom Closed")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Closed By"; "Stockroom Closed By")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Duration"; "Stockroom Duration")
                {
                    ApplicationArea = All;
                }
            }
            group("Sales floor")
            {
                field("Salesfloor Started"; "Salesfloor Started")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Started By"; "Salesfloor Started By")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Entries"; "Salesfloor Entries")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Closed"; "Salesfloor Closed")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Closed By"; "Salesfloor Closed By")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Duration"; "Salesfloor Duration")
                {
                    ApplicationArea = All;
                }
            }
            group(Refill)
            {
                field("Refill Started"; "Refill Started")
                {
                    ApplicationArea = All;
                }
                field("Refill Started By"; "Refill Started By")
                {
                    ApplicationArea = All;
                }
                field("Refill Entries"; "Refill Entries")
                {
                    ApplicationArea = All;
                }
                field("Refill Closed"; "Refill Closed")
                {
                    ApplicationArea = All;
                }
                field("Refill Closed By"; "Refill Closed By")
                {
                    ApplicationArea = All;
                }
                field("Refill Duration"; "Refill Duration")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR CS Stock-Takes Data List";
                RunPageLink = "Stock-Take Id" = FIELD("Stock-Take Id");
            }
            group(Overview)
            {
                Caption = 'Overview';
                action(Devices)
                {
                    Caption = 'Devices';
                    Image = MiniForm;
                    RunObject = Page "NPR CS Devices";
                    RunPageLink = Location = FIELD(Location);
                }
                action("&Item Journal")
                {
                    Caption = '&Item Journal';
                    Image = Worksheet2;
                    RunObject = Page "Phys. Inventory Journal";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name");
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
                        CalcItemJournalLine.SetRange("Journal Template Name", "Journal Template Name");
                        CalcItemJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
                        CalcItemJournalLine.SetRange("Location Code", Location);
                        if CalcItemJournalLine.FindSet then begin
                            repeat
                                QtyCalculated += CalcItemJournalLine."Qty. (Calculated)"
                            until CalcItemJournalLine.Next = 0;
                        end;

                        if Confirm(StrSubstNo(Txt001, Rec."Predicted Qty.", QtyCalculated), true) then begin
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
                action("Update Unknown Entries")
                {
                    Caption = 'Update Unknown Entries';
                    Image = Links;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "NPR CS Upd. Unknown Entries";
                    RunPageLink = "Stock-Take Id" = FIELD("Stock-Take Id");
                    RunPageView = WHERE("Item No." = CONST(''));
                }
            }
        }
    }

    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        Txt001: Label 'Update Predicted Qty. from %1 to %2';
}

