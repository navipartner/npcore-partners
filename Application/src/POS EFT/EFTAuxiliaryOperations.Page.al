page 6184474 "NPR EFT Auxiliary Operations"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Auxiliary Operations';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR EFT Aux Operation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Auxiliary ID"; "Auxiliary ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auxiliary ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

