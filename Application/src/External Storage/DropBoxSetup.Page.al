page 6184870 "NPR DropBox Setup"
{
    Caption = 'DropBox Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR DropBox API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Code"; "Account Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(DropBoxToken; DropBoxToken)
                {
                    ApplicationArea = All;
                    Caption = 'DropBox Access Token';
                    ExtendedDatatype = Masked;
                    ToolTip = 'https://www.dropbox.com/developers/apps -> select your app -> OAuth 2 section -> Generate Access token';

                    trigger OnValidate()
                    begin
                        HandleToken(DropBoxToken);
                    end;
                }
                field(Timeout; Timeout)
                {
                    ApplicationArea = All;
                    ToolTip = 'Miliseconds';
                }
                field("Storage On Server"; "Storage On Server")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if not IsNullGuid(Token) then begin
            IsolatedStorage.Get(Token, DataScope::Company, DropBoxToken);
        end;
    end;

    var
        DropBoxToken: Text;
}

