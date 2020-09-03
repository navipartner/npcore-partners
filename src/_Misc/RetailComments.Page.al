page 6014492 "NPR Retail Comments"
{
    // 
    // StartdateVisible
    // EndateVisible

    AutoSplitKey = true;
    Caption = 'NPR Comment Sheet';
    PageType = List;
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
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Sales Person Code"; "Sales Person Code")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("Long Comment"; "Long Comment")
                {
                    ApplicationArea = All;
                }
                field("Hide on printout"; "Hide on printout")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
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

