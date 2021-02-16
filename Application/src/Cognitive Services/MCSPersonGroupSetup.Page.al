page 6059956 "NPR MCS Person Group Setup"
{

    Caption = 'MCS Person Group Setup';
    PageType = List;
    SourceTable = "NPR MCS Person Groups Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Id"; Rec."Table Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Id field';
                }
                field("Person Groups Id"; Rec."Person Groups Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Groups Id field';
                }
                field("Person Groups Name"; Rec."Person Groups Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Groups Name field';
                }
            }
        }
    }
}

