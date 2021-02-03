page 6014492 "NPR Retail Comments"
{
    AutoSplitKey = true;
    Caption = 'NPR Comment Sheet';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Retail Comment";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Date"; Rec.Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Sales Person Code"; Rec."Sales Person Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Person Code field';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("Long Comment"; Rec."Long Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Long comment field';
                }
                field("Hide on printout"; Rec."Hide on printout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide on printout field';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine();
    end;

    trigger OnOpenPage()
    begin
        if Rec."Table ID" = 6060001 then begin
            StartdateVisible := true;
            EndateVisible := true;
        end
        else begin
            StartdateVisible := false;
            EndateVisible := false;
        end;
    end;

    var
        [InDataSet]
        EndateVisible: Boolean;
        [InDataSet]
        StartdateVisible: Boolean;
}

