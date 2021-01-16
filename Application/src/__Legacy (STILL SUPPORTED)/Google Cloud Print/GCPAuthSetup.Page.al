page 6014635 "NPR GCP Auth Setup"
{
    // NPR5.22/MMV/20160413 CASE 228382 Created page
    // NPR5.26/MMV /20160826 CASE 246209 Moved from P 6014583 to P 6014635. Old page marked for deletion.
    //                                   Renamed page to GCP Auth Setup.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Google Cloud Print Account Setup';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Header)
            {
                Caption = 'Google Cloud Print';
                InstructionalText = 'Please visit the following URL in a browser, login with a Google account you wish to print through & paste the given code back here.';
                field(AuthURL; AuthURL)
                {
                    ApplicationArea = All;
                    Caption = 'URL';
                    Editable = false;
                    Enabled = true;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the URL field';
                }
                field(AuthCode; AuthCode)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ToolTip = 'Specifies the value of the Code field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        AuthURL := GoogleCloudPrintMgt.GetAuthURL();
    end;

    var
        AuthURL: Text;
        AuthCode: Text;
        GoogleCloudPrintMgt: Codeunit "NPR GCP Mgt.";

    procedure GetAuthCode(): Text
    begin
        exit(AuthCode);
    end;
}

