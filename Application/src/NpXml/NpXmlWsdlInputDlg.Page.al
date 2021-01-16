page 6151565 "NPR NpXml Wsdl Input Dlg"
{
    // NC2.01/TR/2016092329  CASE 240432 Object created
    // NC2.01/TR  /20170102  CASE 240432 Updated names of variables.

    Caption = 'WSDL Input Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("Import WSDL")
            {
                Caption = 'Import WSDL';
                field(Wsdl; Wsdl)
                {
                    ApplicationArea = All;
                    Caption = 'WSDL (url or file path)';
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the WSDL (url or file path) field';
                }
                group("When using NTLM username and password are reqired.")
                {
                    Caption = 'When using NTLM username and password are reqired.';
                    field(Username; Username)
                    {
                        ApplicationArea = All;
                        Caption = 'Username';
                        ToolTip = 'Specifies the value of the Username field';
                    }
                    field(Password; Password)
                    {
                        ApplicationArea = All;
                        Caption = 'Password';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Password field';
                    }
                }
            }
        }
    }

    actions
    {
    }

    var
        Wsdl: Text;
        Username: Text;
        Password: Text;

    procedure GetPassword(): Text
    begin
        exit(Password);
    end;

    procedure GetUsername(): Text
    begin
        exit(Username);
    end;

    procedure GetWSDLPath(): Text
    begin
        exit(Wsdl);
    end;
}

