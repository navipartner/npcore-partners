page 6184487 "NPR Pepper Card Type Group"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Group';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_card_types/';
    PageType = List;
    SourceTable = "NPR Pepper Card Type Group";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code value associated with the Pepper Card Type Group';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Card Type Group';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}