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

                    ToolTip = 'Specifies the value of the Subcode field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
