page 6060086 "MCS Recom. Sales Factbox"
{
    // NPR5.30/BR  /20170606  CASE 252646 Object Created

    Caption = 'MCS Recom. Sales Factbox';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "MCS Recommendations Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(RecDescr; RecDescr)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        RecDescr := GetRecDescr;
    end;

    var
        [InDataSet]
        TextRec1: Text;
        [InDataSet]
        TextRec2: Text;
        [InDataSet]
        TextRec3: Text;
        [InDataSet]
        TextRec4: Text;
        [InDataSet]
        TextRec5: Text;
        RecDescr: Text;

    local procedure GetRecDescr(): Text
    var
        Counter: Integer;
        TempText: Text;
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        exit("Item No." + ' - ' + Description + ' (  ' + Format(Round(Rating * 100, 1)) + '% )');
    end;
}

