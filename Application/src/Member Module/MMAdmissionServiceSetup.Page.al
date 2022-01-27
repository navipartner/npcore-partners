page 6060090 "NPR MM Admission Service Setup"
{
    Extensible = False;

    Caption = 'MM Admission Service Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Service Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Validate Members"; Rec."Validate Members")
                {

                    ToolTip = 'Specifies the value of the Validate Members field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Tickes"; Rec."Validate Tickes")
                {

                    ToolTip = 'Specifies the value of the Validate Tickes field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Re-Scan"; Rec."Validate Re-Scan")
                {

                    ToolTip = 'Specifies the value of the Validate Re-Scan field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Scanner Station"; Rec."Validate Scanner Station")
                {

                    ToolTip = 'Specifies the value of the Validate Scanner Station field';
                    ApplicationArea = NPRRetail;
                }
                field("Allowed Re-Scan Interval"; Rec."Allowed Re-Scan Interval")
                {

                    ToolTip = 'Specifies the value of the Allowed Re-Scan Interval field';
                    ApplicationArea = NPRRetail;
                }
                field(WebServiceIsPublished; WebServiceIsPublished)
                {
                    Caption = 'Web Service Is Published';
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Turnstiles; "NPR MM Admis. Scanner Stations")
            {
                Caption = 'Turnstiles';
                ShowFilter = false;
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            part(ServiceSetupFactbox; "NPR Adm. Service Setup Factbox")
            {
                Caption = 'Images';

                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Published Webservice")
            {
                Caption = 'Published Webservice';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Codeunit "NPR MM Admission Service WS";

                ToolTip = 'Executes the Published Webservice action';
                ApplicationArea = NPRRetail;
            }
            action(Entries)
            {
                Caption = 'Entries';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admis. Service Entries";

                ToolTip = 'Executes the Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceIsPublished := false;
        WebServiceManagement.LoadRecords(WebService);
        if WebService.Get(WebService."Object Type"::Codeunit, 'admission_service') then
            WebServiceIsPublished := true;
    end;

    var
        WebServiceIsPublished: Boolean;
}
