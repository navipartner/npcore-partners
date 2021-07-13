page 6059984 "NPR Web Manager Activ."
{
    Caption = 'Web Order Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Order Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup("Open Orders")
            {
                Caption = 'Open Orders';
                field("Open Web Sales Orders"; Rec."Open Web Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Open Web Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Credit Memos"; Rec."Open Credit Memos")
                {

                    DrillDownPageID = "Sales Credit Memos";
                    ToolTip = 'Specifies the value of the Open Credit Memos field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Purchase Orders"; Rec."Open Purchase Orders")
                {

                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the value of the Open Purchase Orders field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup("Processed Orders")
            {
                Caption = 'Processed Orders';
                field("Posted Web Sales Orders"; Rec."Posted Web Sales Orders")
                {

                    DrillDownPageID = "Sales Invoice List";
                    ToolTip = 'Specifies the value of the Posted Web Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Credit Memos"; Rec."Posted Credit Memos")
                {

                    DrillDownPageID = "Posted Sales Credit Memos";
                    ToolTip = 'Specifies the value of the Posted Credit Memos field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Purchase Orders"; Rec."Posted Purchase Orders")
                {

                    DrillDownPageID = "Posted Purchase Invoices";
                    ToolTip = 'Specifies the value of the Posted Purchase Orders field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the New Credit Memo action';
                Image = New;
                ApplicationArea = NPRRetail;
            }
            action("New Purchase Order")
            {
                Caption = 'New Purchase Order';
                RunObject = Page "Purchase Order";

                ToolTip = 'Executes the New Purchase Order action';
                Image = New;
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

