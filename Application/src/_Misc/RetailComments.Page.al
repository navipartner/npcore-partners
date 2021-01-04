page 6014492 "NPR Retail Comments"
{
    // 
    // StartdateVisible
    // EndateVisible

    AutoSplitKey = true;
    Caption = 'NPR Comment Sheet';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Comment";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Sales Person Code"; "Sales Person Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Person Code field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("Long Comment"; "Long Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Long comment field';
                }
                field("Hide on printout"; "Hide on printout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide on printout field';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewLine;
    end;

    trigger OnOpenPage()
    begin

        if "Table ID" = 6060001 then begin
            //CurrForm."Start Date".VISIBLE := TRUE;
            StartdateVisible := true;
            //CurrForm."End Date".VISIBLE := TRUE;
            EndateVisible := true;
        end
        else begin
            //CurrForm."Start Date".VISIBLE := FALSE;
            StartdateVisible := false;
            //CurrForm."End Date".VISIBLE := FALSE;
            EndateVisible := false;
        end;
    end;

    var
        [InDataSet]
        StartdateVisible: Boolean;
        [InDataSet]
        EndateVisible: Boolean;
}

