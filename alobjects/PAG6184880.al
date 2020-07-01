page 6184880 "FTP Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Setup';
    PageType = List;
    SourceTable = "FTP Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field("FTP Host"; "FTP Host")
                {
                }
                field(Description; Description)
                {
                }
                field(Timeout; Timeout)
                {
                    ToolTip = 'Miliseconds';
                }
                field(User; User)
                {
                }
                field(Password; Password)
                {
                    Caption = 'Password';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        HandlePassword(Password);
                    end;
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
        if not IsNullGuid("Service Password") then begin
            IsolatedStorage.Get("Service Password", DataScope::Company, Password);
        end;
    end;

    var
        Password: Text;
}

