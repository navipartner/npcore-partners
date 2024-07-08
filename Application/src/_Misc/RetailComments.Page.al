page 6014492 "NPR Retail Comments"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'NPR Comment Sheet';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Retail Comment";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Date"; Rec.Date)
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Person Code"; Rec."Sales Person Code")
                {

                    ToolTip = 'Specifies the value of the Sales Person Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Long Comment"; Rec."Long Comment")
                {

                    ToolTip = 'Specifies the value of the Long comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Hide on printout"; Rec."Hide on printout")
                {

                    ToolTip = 'Specifies the value of the Hide on printout field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; Rec."End Date")
                {

                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
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
        end
        else begin
        end;
    end;

}

