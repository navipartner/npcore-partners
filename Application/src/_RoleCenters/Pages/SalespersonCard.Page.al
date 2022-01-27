page 6014428 "NPR Salesperson Card"
{
    Extensible = False;
    Caption = 'Salesperson/Purchaser Card';
    SourceTable = "Salesperson/Purchaser";
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Title"; Rec."Job Title")
                {

                    ToolTip = 'Specifies the value of the Job Title field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Commission %"; Rec."Commission %")
                {

                    ToolTip = 'Specifies the value of the Commission % field';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Cash Returnsale"; Rec."NPR Maximum Cash Returnsale")
                {

                    ToolTip = 'Specifies the value of the NPR Maximum Cash Returnsale field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; Rec."NPR Register Password")
                {

                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the NPR POS Unit Password field';
                    ApplicationArea = NPRRetail;
                }
                field("Locked-to Register No."; Rec."NPR Locked-to Register No.")
                {

                    ToolTip = 'Specifies the value of the NPR Locked-to POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("Hide Register Imbalance"; Rec."NPR Hide Register Imbalance")
                {

                    ToolTip = 'Specifies the value of the NPR Hide Register Imbalance field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (Qty.)"; Rec."NPR Sales (Qty.)")
                {

                    ToolTip = 'Specifies the value of the NPR Sales (Qty.) field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."NPR Discount Amount")
                {

                    ToolTip = 'Specifies the value of the NPR Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Group Sales (LCY)"; Rec."NPR Item Group Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the NPR Item Group Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (LCY)"; Rec."NPR Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the NPR Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("COGS (LCY)"; Rec."NPR COGS (LCY)")
                {

                    ToolTip = 'Specifies the value of the NPR COGS (LCY) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(SalespersonPicture; "Salesperson/Purchaser Picture")
            {

                SubPageLink = Code = FIELD(Code);
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "Salespersons/Purchasers";
                ShortCutKey = 'F5';

                ToolTip = 'Executes the List action';
                ApplicationArea = NPRRetail;
            }
            action("&Statistics")
            {
                Caption = '&Statistics';
                Image = Statistics;
                RunObject = Page "Salesperson Statistics";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'F9';

                ToolTip = 'Executes the &Statistics action';
                ApplicationArea = NPRRetail;
            }
            action("Sales Person report")
            {
                Caption = 'Sales Person report';
                Image = SalesPerson;
                ShortCutKey = 'Ctrl+F9';

                ToolTip = 'Executes the Sales Person report action';
                ApplicationArea = NPRRetail;
            }
            action("Remove from staff Sale")
            {
                Caption = 'Remove from Staff Sale';
                Image = RemoveContacts;

                ToolTip = 'Executes the Remove from Staff Sale action';
                ApplicationArea = NPRRetail;
            }
        }
    }

}

