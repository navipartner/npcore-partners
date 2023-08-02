page 6014582 "NPR Store Groups"
{
    Extensible = False;
    Caption = 'Store Groups';
    ContextSensitiveHelpPage = 'docs/retail/pos_store/intro/';
    PageType = List;
    SourceTable = "NPR Store Group";
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
                    ToolTip = 'Specifies the code of the store group';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the store group';
                    ApplicationArea = NPRRetail;
                }
                field("Blank Location"; Rec."Blank Location")
                {
                    ToolTip = 'Specifies if a blank location is allowed or not';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

