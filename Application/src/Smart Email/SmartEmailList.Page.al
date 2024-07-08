page 6059821 "NPR Smart Email List"
{
    Extensible = false;
    Caption = 'Smart Email List';
    CardPageId = "NPR Smart Email Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Smart Email";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the smart email';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the smart email';
                    ApplicationArea = NPRRetail;
                }
                field(Provider; Rec.Provider)
                {
                    ToolTip = 'Specifies the provider for the smart email';
                    ApplicationArea = NPRRetail;
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the ID of the table in which the smart email is going to be merged.';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ToolTip = 'Specifies the name of the table in which the smart email is going to be merged.';
                    ApplicationArea = NPRRetail;
                }
                field("Smart Email Name"; Rec."Smart Email Name")
                {
                    ToolTip = 'Specifies the smart email name';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

