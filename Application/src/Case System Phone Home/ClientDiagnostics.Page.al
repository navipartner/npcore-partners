page 6059999 "NPR Client Diagnostics"
{
    // NPR5.38/CLVA/20171109  CASE 293179 Collecting client-side information
    // NPR5.40/MHA /20180328  CASE 308907 Removed Client-side information collection and changed page into normal List Page

    Caption = 'NaviPartner Retail';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Client Diagnostics";

    layout
    {
        area(content)
        {
            repeater(Control6014400)
            {
                ShowCaption = false;
                field(Username; Username)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Username field';
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Tenant ID"; "Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tenant ID field';
                }
                field("Login Info"; "Login Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Login Info field';
                }
                field("Last Logon Date"; "Last Logon Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Logon Date field';
                }
                field("Last Logon Time"; "Last Logon Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Logon Time field';
                }
                field("Full Name"; "Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Full Name field';
                }
                field("Service Server Name"; "Service Server Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Server Name field';
                }
                field("Service Instance"; "Service Instance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Instance field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Company ID"; "Company ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company ID field';
                }
                field("User Security ID"; "User Security ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Security ID field';
                }
                field("Windows Security ID"; "Windows Security ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Windows Security ID field';
                }
                field("User Login Type"; "User Login Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Login Type field';
                }
                field("Application Version"; "Application Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Application Version field';
                }
                field("License Info"; "License Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the License Info field';
                }
                field("License Type"; "License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Type field';
                }
                field("License Name"; "License Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Name field';
                }
                field("No. of Full Users"; "No. of Full Users")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Full Users field';
                }
                field("No. of ISV Users"; "No. of ISV Users")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of ISV Users field';
                }
                field("No. of Limited Users"; "No. of Limited Users")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Limited Users field';
                }
                field("Computer Info"; "Computer Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Computer Info field';
                }
                field("Client Name"; "Client Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Name field';
                }
                field("Serial Number"; "Serial Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial Number field';
                }
                field("OS Version"; "OS Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OS Version field';
                }
                field("Mac Adresses"; "Mac Adresses")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mac Adresses field';
                }
                field("Platform Version"; "Platform Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Platform Version field';
                }
                field("POS Info"; "POS Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Info field';
                }
                field("POS Client Type"; "POS Client Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Client Type field';
                }
                field("IP Address"; "IP Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the IP Address field';
                }
                field("Geolocation Latitude"; "Geolocation Latitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                }
                field("Geolocation Longitude"; "Geolocation Longitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Geolocation Longitude field';
                }
                field("Logout Info"; "Logout Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Logout Info field';
                }
                field("Last Logout Date"; "Last Logout Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Logout Date field';
                }
                field("Last Logout Time"; "Last Logout Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Logout Time field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Test NpCase Login Integration action';

                trigger OnAction()
                var
                    ClientDiagnostics: Record "NPR Client Diagnostics";
                    ClientDiagnosticsNpCaseMgt: Codeunit "NPR Client Diagn.NpCase Mgt";
                begin
                    ClientDiagnostics.Copy(Rec);
                    ClientDiagnostics."Login Info" := true;
                    ClientDiagnosticsNpCaseMgt.Run(ClientDiagnostics);
                end;
            }
        }
    }
}

