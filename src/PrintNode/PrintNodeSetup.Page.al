page 6151220 "NPR PrintNode Setup"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Setup';
    PageType = Card;
    SourceTable = "NPR PrintNode Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Key"; "API Key")
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
            action(TestConnection)
            {
                Caption = 'Test Connection';
                Image = Confirm;

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
        Reset;
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}

