page 6014423 "NPR Report Selection: Retail"
{
    Extensible = False;
    Caption = 'Report Selection - Retail';
    ContextSensitiveHelpPage = 'retail/posunit/howto/receipt-printout.html';
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

                    ToolTip = 'Specifies the value of the Report Type field';
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

                    ToolTip = 'Specifies the value of the Sequence field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Report Name"; Rec."Report Name")
                {

                    ToolTip = 'Specifies the value of the Report Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {

                    Width = 20;
                    ToolTip = 'Specifies the value of the Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field(Optional; Rec.Optional)
                {

                    ToolTip = 'Specifies the value of the Optional field';
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

