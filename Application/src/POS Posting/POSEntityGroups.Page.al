page 6150649 "NPR POS Entity Groups"
{
    // NPR5.31/AP/20170418  CASE 272321  New list page for lookup and drill down of POS Entity Groups

    Caption = 'POS Entity Groups';
    DataCaptionExpression = GetFormCaption;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Entity Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sorting"; Sorting)
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
        if Field.Get("Table ID", "Field No.") then
            exit(Field."Field Caption");
    end;
}

