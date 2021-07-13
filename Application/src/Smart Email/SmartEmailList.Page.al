page 6059821 "NPR Smart Email List"
{
    Caption = 'Smart Email List';
    CardPageID = "NPR Smart Email Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Smart Email";
    UsageCategory = Lists;
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
                field(Provider; Rec.Provider)
                {

                    ToolTip = 'Specifies the value of the Provider field';
                    ApplicationArea = NPRRetail;
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Merge Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {

                    ToolTip = 'Specifies the value of the Table Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Smart Email Name"; Rec."Smart Email Name")
                {

                    ToolTip = 'Specifies the value of the Smart Email Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

