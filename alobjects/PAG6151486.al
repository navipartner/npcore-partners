page 6151486 "M2 Value Buffer List"
{
    // MAG2.20/MHA /20190425  CASE 320423 Object created - Buffer used with M2 GET Apis

    Caption = 'M2 Values';
    DataCaptionFields = Value;
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "M2 Value Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value;Value)
                {
                    Visible = ShowValue;
                }
                field(Label;Label)
                {
                    Visible = ShowLabel;
                }
                field(Position;Position)
                {
                    Visible = ShowPosition;
                }
            }
        }
    }

    actions
    {
    }

    var
        ShowValue: Boolean;
        ShowLabel: Boolean;
        ShowPosition: Boolean;

    procedure SetShowValue(NewShowValue: Boolean)
    begin
        ShowValue := NewShowValue;
    end;

    procedure SetShowLabel(NewShowLabel: Boolean)
    begin
        ShowLabel := NewShowLabel;
    end;

    procedure SetShowPosition(NewShowPosition: Boolean)
    begin
        ShowPosition := NewShowPosition;
    end;

    procedure SetCaption(NewCaption: Text)
    begin
        CurrPage.Caption(NewCaption);
    end;

    procedure GetSourceTable(var M2ValueBuffer2: Record "M2 Value Buffer" temporary)
    begin
        M2ValueBuffer2.Copy(Rec,true);
    end;

    procedure SetSourceTable(var M2ValueBuffer2: Record "M2 Value Buffer" temporary)
    begin
        Rec.Copy(M2ValueBuffer2,true);
    end;
}

