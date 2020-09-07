page 6059984 "NPR Web Manager Activ."
{
    // NPR5.40/MHA /20180319  CASE 308396 ActionContainer ActionItems added to "New Credit Memo" and "New Purchase Order"

    Caption = 'Web Order Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Order Cue";

    layout
    {
        area(content)
        {
            cuegroup("Open Orders")
            {
                Caption = 'Open Orders';
                field("Open Web Sales Orders"; "Open Web Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                }
                field("Open Credit Memos"; "Open Credit Memos")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Credit Memo Lines Subform";
                }
                field("Open Purchase Orders"; "Open Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Purchase Order List";
                }
            }
            cuegroup("Processed Orders")
            {
                Caption = 'Processed Orders';
                field("Posted Web Sales Orders"; "Posted Web Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Invoice List";
                }
                field("Posted Credit Memos"; "Posted Credit Memos")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Sales Credit Memos";
                }
                field("Posted Purchase Orders"; "Posted Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Purchase Invoices";
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("New Credit Memo")
            {
                Caption = 'New Credit Memo';
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;
                ApplicationArea=All;
            }
            action("New Purchase Order")
            {
                Caption = 'New Purchase Order';
                RunObject = Page "Purchase Order";
                ApplicationArea=All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

