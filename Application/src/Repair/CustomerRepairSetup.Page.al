page 6014409 "NPR Customer Repair Setup"
{

    Caption = 'Customer Repair Setup';
    PageType = Card;
    SourceTable = "NPR Customer Repair Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Customer Repair No. Series"; Rec."Customer Repair No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Repair Management field';
                }
                field("Rep. Cust. Default"; Rec."Rep. Cust. Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rep. Cust. Default field';
                }
                field("Fixed Price of Mending"; Rec."Fixed Price of Mending")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Price Of Mending field';
                }
                field("Fixed Price of Denied Mending"; Rec."Fixed Price of Denied Mending")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Price Of Denied Mending field';
                }
            }
        }
    }

}
