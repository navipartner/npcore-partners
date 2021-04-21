page 6014436 "NPR MobilePayV10 POS"
{
    PageType = List;
    SourceTable = "NPR MobilePayV10 POS";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("MobilePay POS ID"; Rec."MobilePay POS ID")
                {
                    ApplicationArea = All;
                }
                field("Merchant POS ID"; Rec."Merchant POS ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Beacon ID"; Rec."Beacon ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}