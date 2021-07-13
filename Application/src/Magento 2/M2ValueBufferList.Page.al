page 6151486 "NPR M2 Value Buffer List"
{
    Caption = 'M2 Values';
    DataCaptionFields = Value;
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    PopulateAllFields = true;
    SourceTable = "NPR M2 Value Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING(Position);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value; Rec.Value)
                {

                    Visible = ShowValue;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Label"; Rec.Label)
                {

                    Visible = ShowLabel;
                    ToolTip = 'Specifies the value of the Label field';
                    ApplicationArea = NPRRetail;
                }
                field(Position; Rec.Position)
                {

                    Visible = ShowPosition;
                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
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