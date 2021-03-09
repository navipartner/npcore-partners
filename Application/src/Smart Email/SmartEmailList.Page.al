page 6059821 "NPR Smart Email List"
{
    Caption = 'Smart Email List';
    CardPageID = "NPR Smart Email Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Smart Email";
    UsageCategory = Lists;
    ApplicationArea = All;
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
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Merge Table ID field';
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("Smart Email Name"; Rec."Smart Email Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Smart Email Name field';
                }
            }
        }
    }

}

