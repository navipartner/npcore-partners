page 6150649 "NPR POS Entity Groups"
{
    Extensible = False;
    Caption = 'POS Entity Groups';
    DataCaptionExpression = GetFormCaption();
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Entity Group";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
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

