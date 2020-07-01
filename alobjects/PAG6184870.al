page 6184870 "DropBox Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox Setup';
    PageType = List;
    SourceTable = "DropBox API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Code"; "Account Code")
                {
                }
                field(Description; Description)
                {
                }
                field(DropBoxToken; DropBoxToken)
                {
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
                    ToolTip = 'Miliseconds';
                }
                field("Storage On Server"; "Storage On Server")
                {
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

