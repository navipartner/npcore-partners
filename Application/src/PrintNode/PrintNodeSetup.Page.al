page 6151220 "NPR PrintNode Setup"
{
    Caption = 'PrintNode Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR PrintNode Setup";
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                Image = Confirm;
                ApplicationArea = All;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Test Connection action';

                trigger OnAction()
                var
                    PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
                begin
                    PrintNodeAPIMgt.TestConnection(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}

