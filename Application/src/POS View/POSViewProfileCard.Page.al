page 6150636 "NPR POS View Profile Card"
{
    Caption = 'POS View Profile Card';
    PageType = Card;
    SourceTable = "NPR POS View Profile";
    UsageCategory = None;

    layout
    {

        area(factboxes)
        {
            part(POSViewPic; "NPR POS View Picture")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                SubPageLink = "Code" = FIELD("Code");
            }
        }
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Discount field';
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                }
                field("Lock Timeout"; Rec."Lock Timeout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Timeout field';
                }
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tax type, POS view should be adjusted for by default';
                }
            }
            group("Number and Date Formatting")
            {
                field("Client Formatting Culture ID"; Rec."Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Formatting Culture ID field';
                }
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Date Separator field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action(DetectSeparators)
                {
                    Caption = 'Detect Decimal and Thousands Separators';
                    Image = SuggestNumber;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Detect Decimal and Thousands Separators action';

                    trigger OnAction()
                    begin
                        Rec.DetectDecimalThousandsSeparator();
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }
}
