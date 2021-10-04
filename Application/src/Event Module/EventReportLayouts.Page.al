page 6014671 "NPR Event Report Layouts"
{

    Caption = 'Event Report Layouts';
    PageType = List;
    SourceTable = "NPR Event Report Layout";
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Usage; Rec.Usage)
                {
                    ToolTip = 'Specifies the value of the Usage field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {
                    ToolTip = 'Specifies the value of the Report ID field.';
                    ApplicationArea = NPRRetail;
                }
                field("Layout Code"; Rec."Layout Code")
                {
                    ToolTip = 'Specifies the value of the Layout ID field.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Req. Page Parameters"; Rec."Use Req. Page Parameters")
                {
                    ToolTip = 'Specifies the value of the Use Req. Page Parameters field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(reporting)
        {
            action(PreviewReport)
            {
                Caption = 'Preview Report';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'Preview the report as pdf.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.PreviewReport();
                end;
            }
            action(RequestPage)
            {
                Caption = 'Request Page';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'View or set filters to be applied to the report.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.RunReportRequestPage();
                end;
            }
        }
    }

}
