page 6059956 "NPR MCS Person Group Setup"
{

    Caption = 'MCS Person Group Setup';
    PageType = List;
    SourceTable = "NPR MCS Person Groups Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Id"; Rec."Table Id")
                {

                    ToolTip = 'Specifies the value of the Table Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Person Groups Id"; Rec."Person Groups Id")
                {

                    ToolTip = 'Specifies the value of the Person Groups Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Person Groups Name"; Rec."Person Groups Name")
                {

                    ToolTip = 'Specifies the value of the Person Groups Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

