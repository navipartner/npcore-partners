page 6014640 "NPR RP Template Setup"
{
    Extensible = False;
    Caption = 'Template Setup';
    SourceTable = "NPR RP Template Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Settings)
            {
                Caption = 'Settings';
                field("Version Major Number"; Rec."Version Major Number")
                {

                    ToolTip = 'Specifies the value of the Version Major Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Version Prefix"; Rec."Version Prefix")
                {

                    ToolTip = 'Specifies the value of the Version Prefix field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}

