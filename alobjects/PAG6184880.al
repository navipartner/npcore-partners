page 6184880 "FTP Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // NPR5.55/ALST/20200709 CASE 408285 added port number

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
                    ApplicationArea = All;
                }
                field("FTP Host"; "FTP Host")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Timeout; Timeout)
                {
                    ApplicationArea = All;
                    ToolTip = 'Miliseconds';
                }
                field(User; User)
                {
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        HandlePassword(Password);
                    end;
                }
                field("Port Number"; "Port Number")
                {
                    ApplicationArea = All;
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
        if not IsNullGuid("Service Password") then begin
            IsolatedStorage.Get("Service Password", DataScope::Company, Password);
        end;
    end;

    var
        Password: Text;
}

