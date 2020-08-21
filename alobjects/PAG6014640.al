page 6014640 "RP Template Setup"
{
    Caption = 'Template Setup';
    SourceTable = "RP Template Setup";
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

