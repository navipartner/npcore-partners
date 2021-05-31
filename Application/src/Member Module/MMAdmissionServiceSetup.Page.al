page 6060090 "NPR MM Admission Service Setup"
{

    Caption = 'MM Admission Service Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Admis. Service Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Validate Members"; Rec."Validate Members")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Members field';
                }
                field("Validate Tickes"; Rec."Validate Tickes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Tickes field';
                }
                field("Validate Re-Scan"; Rec."Validate Re-Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Re-Scan field';
                }
                field("Validate Scanner Station"; Rec."Validate Scanner Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Scanner Station field';
                }
                field("Allowed Re-Scan Interval"; Rec."Allowed Re-Scan Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allowed Re-Scan Interval field';
                }
                field(WebServiceIsPublished; WebServiceIsPublished)
                {
                    Caption = 'Web Service Is Published';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                }
            }
            part(Turnstiles; "NPR MM Admis. Scanner Stations")
            {
                Caption = 'Turnstiles';
                ShowFilter = false;
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(ServiceSetupFactbox; "NPR Adm. Service Setup Factbox")
            {
                Caption = 'Images';
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
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
                ApplicationArea = All;
                ToolTip = 'Executes the Published Webservice action';
            }
            action(Entries)
            {
                Caption = 'Entries';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admis. Service Entries";
                ApplicationArea = All;
                ToolTip = 'Executes the Entries action';
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