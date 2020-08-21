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
                field(Username; Username)
                {
                    ApplicationArea = All;
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                }
                field("Tenant ID"; "Tenant ID")
                {
                    ApplicationArea = All;
                }
                field("Login Info"; "Login Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Logon Date"; "Last Logon Date")
                {
                    ApplicationArea = All;
                }
                field("Last Logon Time"; "Last Logon Time")
                {
                    ApplicationArea = All;
                }
                field("Full Name"; "Full Name")
                {
                    ApplicationArea = All;
                }
                field("Service Server Name"; "Service Server Name")
                {
                    ApplicationArea = All;
                }
                field("Service Instance"; "Service Instance")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Company ID"; "Company ID")
                {
                    ApplicationArea = All;
                }
                field("User Security ID"; "User Security ID")
                {
                    ApplicationArea = All;
                }
                field("Windows Security ID"; "Windows Security ID")
                {
                    ApplicationArea = All;
                }
                field("User Login Type"; "User Login Type")
                {
                    ApplicationArea = All;
                }
                field("Application Version"; "Application Version")
                {
                    ApplicationArea = All;
                }
                field("License Info"; "License Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("License Type"; "License Type")
                {
                    ApplicationArea = All;
                }
                field("License Name"; "License Name")
                {
                    ApplicationArea = All;
                }
                field("No. of Full Users"; "No. of Full Users")
                {
                    ApplicationArea = All;
                }
                field("No. of ISV Users"; "No. of ISV Users")
                {
                    ApplicationArea = All;
                }
                field("No. of Limited Users"; "No. of Limited Users")
                {
                    ApplicationArea = All;
                }
                field("Computer Info"; "Computer Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Client Name"; "Client Name")
                {
                    ApplicationArea = All;
                }
                field("Serial Number"; "Serial Number")
                {
                    ApplicationArea = All;
                }
                field("OS Version"; "OS Version")
                {
                    ApplicationArea = All;
                }
                field("Mac Adresses"; "Mac Adresses")
                {
                    ApplicationArea = All;
                }
                field("Platform Version"; "Platform Version")
                {
                    ApplicationArea = All;
                }
                field("POS Info"; "POS Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("POS Client Type"; "POS Client Type")
                {
                    ApplicationArea = All;
                }
                field("IP Address"; "IP Address")
                {
                    ApplicationArea = All;
                }
                field("Geolocation Latitude"; "Geolocation Latitude")
                {
                    ApplicationArea = All;
                }
                field("Geolocation Longitude"; "Geolocation Longitude")
                {
                    ApplicationArea = All;
                }
                field("Logout Info"; "Logout Info")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Logout Date"; "Last Logout Date")
                {
                    ApplicationArea = All;
                }
                field("Last Logout Time"; "Last Logout Time")
                {
                    ApplicationArea = All;
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

