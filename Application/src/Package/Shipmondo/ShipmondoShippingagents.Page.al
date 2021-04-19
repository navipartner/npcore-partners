page 6014569 "NPR Package Shipping Agents"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    CardPageID = "NPR Package Shipping agent";
    PageType = List;
    SourceTable = "NPR Package Shipping Agent";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Ship to Contact Mandatory"; Rec."Ship to Contact Mandatory")
                {
                    ApplicationArea = All;
                }
                field("Automatic Drop Point Service"; Rec."Automatic Drop Point Service")
                {
                    ApplicationArea = All;
                }
                field("Use own Agreement"; Rec."Use own Agreement")
                {
                    ApplicationArea = All;
                }
                field("Package Type Required"; Rec."Package Type Required")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}

