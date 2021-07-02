page 6150641 "NPR POS Info Subform"
{
    Caption = 'POS Info Subform';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Info Subcode";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Subcode; Rec.Subcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subcode field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }
}
