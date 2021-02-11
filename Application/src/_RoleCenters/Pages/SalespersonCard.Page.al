page 6014428 "NPR Salesperson Card"
{
    Caption = 'Salesperson/Purchaser Card';
    SourceTable = "Salesperson/Purchaser";
    UsageCategory = Documents;
    ApplicationArea = All;
    layout
    {
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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Title field';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Commission %"; Rec."Commission %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Commission % field';
                }
                field("Maximum Cash Returnsale"; Rec."NPR Maximum Cash Returnsale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Maximum Cash Returnsale field';
                }
                field(Picture; Rec."NPR Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Picture field';
                }
            }
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; Rec."NPR Register Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the NPR Register Password field';
                }
                field("Reverse Sales Ticket"; Rec."NPR Reverse Sales Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Reverse Sales Ticket field';
                }
                field("Locked-to Register No."; Rec."NPR Locked-to Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Locked-to Register No. field';
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("Hide Register Imbalance"; Rec."NPR Hide Register Imbalance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Hide Register Imbalance field';
                }
                field("Sales (Qty.)"; Rec."NPR Sales (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Sales (Qty.) field';
                }
                field("Discount Amount"; Rec."NPR Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Discount Amount field';
                }
                field("Item Group Sales (LCY)"; Rec."NPR Item Group Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Item Group Sales (LCY) field';
                }
                field("Sales (LCY)"; Rec."NPR Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Sales (LCY) field';
                }
                field("COGS (LCY)"; Rec."NPR COGS (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR COGS (LCY) field';
                }
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
                ApplicationArea = All;
                ToolTip = 'Executes the List action';
            }
            action("&Statistics")
            {
                Caption = '&Statistics';
                Image = Statistics;
                RunObject = Page "Salesperson Statistics";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'F9';
                ApplicationArea = All;
                ToolTip = 'Executes the &Statistics action';
            }
            action("Sales Person report")
            {
                Caption = 'Sales Person report';
                Image = SalesPerson;
                ShortCutKey = 'Ctrl+F9';
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Person report action';
            }
            action("Remove from staff Sale")
            {
                Caption = 'Remove from Staff Sale';
                Image = RemoveContacts;
                ApplicationArea = All;
                ToolTip = 'Executes the Remove from Staff Sale action';
            }
        }
    }

}

