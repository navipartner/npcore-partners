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

    SourceTable = "NPR EFT Aux Operation";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Auxiliary ID"; Rec."Auxiliary ID")
                {

                    ToolTip = 'Specifies the value of the Auxiliary ID field';
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

    actions
    {
    }
}

