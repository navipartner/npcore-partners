page 6059999 "Client Diagnostics"
{
    // NPR5.38/CLVA/20171109  CASE 293179 Collecting client-side information
    // NPR5.40/MHA /20180328  CASE 308907 Removed Client-side information collection and changed page into normal List Page

    Caption = 'NaviPartner Retail';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Client Diagnostics";

    layout
    {
        area(content)
        {
            repeater(Control6014400)
            {
                ShowCaption = false;
                field(Username;Username)
                {
                }
                field("Database Name";"Database Name")
                {
                }
                field("Tenant ID";"Tenant ID")
                {
                }
                field("Login Info";"Login Info")
                {
                    Visible = false;
                }
                field("Last Logon Date";"Last Logon Date")
                {
                }
                field("Last Logon Time";"Last Logon Time")
                {
                }
                field("Full Name";"Full Name")
                {
                }
                field("Service Server Name";"Service Server Name")
                {
                }
                field("Service Instance";"Service Instance")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Company ID";"Company ID")
                {
                }
                field("User Security ID";"User Security ID")
                {
                }
                field("Windows Security ID";"Windows Security ID")
                {
                }
                field("User Login Type";"User Login Type")
                {
                }
                field("Application Version";"Application Version")
                {
                }
                field("License Info";"License Info")
                {
                    Visible = false;
                }
                field("License Type";"License Type")
                {
                }
                field("License Name";"License Name")
                {
                }
                field("No. of Full Users";"No. of Full Users")
                {
                }
                field("No. of ISV Users";"No. of ISV Users")
                {
                }
                field("No. of Limited Users";"No. of Limited Users")
                {
                }
                field("Computer Info";"Computer Info")
                {
                    Visible = false;
                }
                field("Client Name";"Client Name")
                {
                }
                field("Serial Number";"Serial Number")
                {
                }
                field("OS Version";"OS Version")
                {
                }
                field("Mac Adresses";"Mac Adresses")
                {
                }
                field("Platform Version";"Platform Version")
                {
                }
                field("POS Info";"POS Info")
                {
                    Visible = false;
                }
                field("POS Client Type";"POS Client Type")
                {
                }
                field("IP Address";"IP Address")
                {
                }
                field("Geolocation Latitude";"Geolocation Latitude")
                {
                }
                field("Geolocation Longitude";"Geolocation Longitude")
                {
                }
                field("Logout Info";"Logout Info")
                {
                    Visible = false;
                }
                field("Last Logout Date";"Last Logout Date")
                {
                }
                field("Last Logout Time";"Last Logout Time")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Test NpCase Login Integration")
            {
                Caption = 'Test NpCase Login Integration';
                Image = CoupledUser;
                Visible = false;

                trigger OnAction()
                var
                    ClientDiagnostics: Record "Client Diagnostics";
                    ClientDiagnosticsNpCaseMgt: Codeunit "Client Diagnostics NpCase Mgt.";
                begin
                    ClientDiagnostics.Copy(Rec);
                    ClientDiagnostics."Login Info" := true;
                    ClientDiagnosticsNpCaseMgt.Run(ClientDiagnostics);
                end;
            }
        }
    }
}

