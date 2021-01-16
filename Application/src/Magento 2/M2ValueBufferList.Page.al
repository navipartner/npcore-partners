page 6151486 "NPR M2 Value Buffer List"
{
    // MAG2.20/MHA /20190425  CASE 320423 Object created - Buffer used with M2 GET Apis

    Caption = 'M2 Values';
    DataCaptionFields = Value;
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PopulateAllFields = true;
    SourceTable = "NPR M2 Value Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Visible = ShowValue;
                    ToolTip = 'Specifies the value of the Value field';
                }
                field("Label"; Label)
                {
                    ApplicationArea = All;
                    Visible = ShowLabel;
                    ToolTip = 'Specifies the value of the Label field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    Visible = ShowPosition;
                    ToolTip = 'Specifies the value of the Position field';
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

    procedure GetSourceTable(var M2ValueBuffer2: Record "NPR M2 Value Buffer" temporary)
    begin
        M2ValueBuffer2.Copy(Rec, true);
    end;

    procedure SetSourceTable(var M2ValueBuffer2: Record "NPR M2 Value Buffer" temporary)
    begin
        Rec.Copy(M2ValueBuffer2, true);
    end;
}

