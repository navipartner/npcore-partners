page 6014423 "NPR Report Selection: Retail"
{
    Extensible = False;
    Caption = 'Report Selection - Retail';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/receipt_printout/';
    DelayedInsert = true;
    Editable = true;
    PageType = Worksheet;
    SourceTable = "NPR Report Selection Retail";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Control6150624)
            {
                ShowCaption = false;
                field(ReportType2; ReportTypeEnum)
                {
                    ToolTip = 'Specifies the report type of the report selection - retail';
                    Caption = 'Report Type';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetReportTypeFilter();
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Control6150626)
            {
                ShowCaption = false;
                field(Sequence; Rec.Sequence)
                {
                    ToolTip = 'Specifies the sequence of the report type';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {
                    ToolTip = 'Specifies the POS unit number for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {
                    ToolTip = 'Specifies the Report ID for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field("Report Name"; Rec."Report Name")
                {
                    ToolTip = 'Specifies the report name for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit ID for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the codeunit name for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {

                    Width = 20;
                    ToolTip = 'Specifies the print template for this sequence';
                    ApplicationArea = NPRRetail;
                }
                field(Optional; Rec.Optional)
                {
                    ToolTip = 'Specifies this sequence is optional or not';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.NewRecord();
    end;

    trigger OnOpenPage()
    begin
        ReportTypeEnum := ReportTypeEnum::"Price Label";
        SetReportTypeFilter();
    end;

    local procedure SetReportTypeFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Rec."Report Type", ReportTypeEnum);
        Rec.FilterGroup(0);
    end;

    var
        ReportTypeEnum: Enum "NPR Report Selection Type";
}

