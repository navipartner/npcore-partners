page 6151225 "NPR NpCs Store Stock Setup"
{
    Caption = 'Collect Store Stock Setup';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR NpCs Store Stock Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Store Stock Enabled"; Rec."Store Stock Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Store Stock Enabled field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Init Store Stock Items")
            {
                Caption = 'Init Store Stock Items';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Init Store Stock Items action';
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoreStockSyncMgt: Codeunit "NPR NpCs Store Stock Sync Mgt.";
                begin
                    NpCsStoreStockSyncMgt.ScheduleStockItemInitiation();
                    Message(Text000);
                    PAGE.Run(PAGE::"NPR NpCs Store Stock Items");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert(true);
        end;
    end;

    var
        Text000: Label 'Store Stock Item Initiation started';
}