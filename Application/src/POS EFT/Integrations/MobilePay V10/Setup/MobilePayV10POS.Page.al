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
                    ToolTip = 'Specifies the value of the MobilePay POS ID field';
                }
                field("Merchant POS ID"; Rec."Merchant POS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant POS ID field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Beacon ID"; Rec."Beacon ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Beacon ID field';
                }
            }
        }
    }
}