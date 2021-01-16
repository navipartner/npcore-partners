page 6184880 "NPR FTP Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // NPR5.55/ALST/20200709 CASE 408285 added port number

    Caption = 'FTP Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR FTP Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("FTP Host"; "FTP Host")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Host URI field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Timeout; Timeout)
                {
                    ApplicationArea = All;
                    ToolTip = 'Miliseconds';
                }
                field(User; User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Name field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field';

                    trigger OnValidate()
                    begin
                        HandlePassword(Password);
                    end;
                }
                field("Port Number"; "Port Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Port Number field';
                }
                field("Storage On Server"; "Storage On Server")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server files location field';
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

