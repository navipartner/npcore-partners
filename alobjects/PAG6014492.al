page 6014492 "Retail Comments"
{
    // 
    // StartdateVisible
    // EndateVisible

    AutoSplitKey = true;
    Caption = 'NPR Comment Sheet';
    PageType = List;
    SourceTable = "Retail Comment";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Date;Date)
                {
                }
                field("Code";Code)
                {
                }
                field("Sales Person Code";"Sales Person Code")
                {
                }
                field(Comment;Comment)
                {
                }
                field("Long Comment";"Long Comment")
                {
                }
                field("Hide on printout";"Hide on printout")
                {
                }
                field("Start Date";"Start Date")
                {
                }
                field("End Date";"End Date")
                {
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

        if "Table ID" = 6060001 then
           begin
              //CurrForm."Start Date".VISIBLE := TRUE;
              StartdateVisible:=true;
              //CurrForm."End Date".VISIBLE := TRUE;
             EndateVisible:= true;
           end
        else
           begin
              //CurrForm."Start Date".VISIBLE := FALSE;
             StartdateVisible:= false;
              //CurrForm."End Date".VISIBLE := FALSE;
             EndateVisible:= false;
           end;
    end;

    var
        [InDataSet]
        StartdateVisible: Boolean;
        [InDataSet]
        EndateVisible: Boolean;
}

