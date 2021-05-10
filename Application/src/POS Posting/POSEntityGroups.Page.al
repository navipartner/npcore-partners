page 6150649 "NPR POS Entity Groups"
{
    Caption = 'POS Entity Groups';
    DataCaptionExpression = GetFormCaption();
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entity Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
            }
        }
    }

    actions
    {
    }

    local procedure GetFormCaption(): Text
    var
        "Field": Record "Field";
    begin
        if Field.Get(Rec."Table ID", Rec."Field No.") then
            exit(Field."Field Caption");
    end;
}

