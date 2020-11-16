page 6014640 "NPR RP Template Setup"
{
    Caption = 'Template Setup';
    SourceTable = "NPR RP Template Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Settings)
            {
                Caption = 'Settings';
                field("Version Major Number"; "Version Major Number")
                {
                    ApplicationArea = All;
                }
                field("Version Prefix"; "Version Prefix")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert(true);
        end;
    end;
}

