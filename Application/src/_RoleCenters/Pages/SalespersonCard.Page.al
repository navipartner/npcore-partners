page 6014428 "NPR Salesperson Card"
{
    Extensible = False;
    Caption = 'Salesperson/Purchaser Card';
    SourceTable = "Salesperson/Purchaser";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the Code of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the Name of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Job Title"; Rec."Job Title")
                {

                    ToolTip = 'Specifies the Job Title of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the E-Mail of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the Phone No. of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the Global Dimension 1 Code of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the Global Dimension 2 Code of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Commission %"; Rec."Commission %")
                {

                    ToolTip = 'Specifies the Commission % of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Cash Returnsale"; Rec."NPR Maximum Cash Returnsale")
                {

                    ToolTip = 'Specifies the NPR Maximum Cash Returnsale of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; Rec."NPR Register Password")
                {

                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the NPR POS Unit Password of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("NPR POS Unit Group"; Rec."NPR POS Unit Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the NPR Locked-to POS Unit No. of the salesperson/purchaser';
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("Hide Register Imbalance"; Rec."NPR Hide Register Imbalance")
                {
                    ToolTip = 'Specifies the NPR Hide Register Imbalance of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (Qty.)"; SalesQty)
                {
                    Caption = 'Sales (Qty.)';
                    ToolTip = 'Specifies the NPR Sales (Qty.) of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; DiscountAmount)
                {
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the NPR Discount Amount of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Item Group Sales (LCY)"; ItemGroupSalesLCY)
                {
                    Caption = 'Item Group Sales (LCY)';
                    ToolTip = 'Specifies the NPR Item Group Sales (LCY) of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (LCY)"; SalesLCY)
                {
                    Caption = 'Sales (LCY)';
                    ToolTip = 'Specifies the NPR Sales (LCY) of the salesperson/purchaser';
                    ApplicationArea = NPRRetail;
                }
                field("COGS (LCY)"; COGSLCY)
                {
                    Caption = 'COGS (LCY)';
                    ToolTip = 'Specifies the NPR COGS (LCY) of the salesperson/purchaser';
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

                ToolTip = 'View or edit the List of the salesperson/purchaser';
                ApplicationArea = NPRRetail;
            }
            action("&Statistics")
            {
                Caption = '&Statistics';
                Image = Statistics;
                RunObject = Page "Salesperson Statistics";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'F9';

                ToolTip = 'Executes the &Statistics report for the salespersons/purchasers';
                ApplicationArea = NPRRetail;
            }
            action("Sales Person report")
            {
                Caption = 'Sales Person report';
                Image = SalesPerson;
                ShortCutKey = 'Ctrl+F9';

                ToolTip = 'Executes the Sales Person report for the salespersons/purchasers';
                ApplicationArea = NPRRetail;
            }
            action("Remove from staff Sale")
            {
                Caption = 'Remove from Staff Sale';
                Image = RemoveContacts;

                ToolTip = 'Executes the Remove from Staff Sale for the salespersons/purchasers';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.NPRGetVESalesStats(SalesLCY, COGSLCY, SalesQty, DiscountAmount);
        Rec.NPRGetVEItemGroupSalesLCY(ItemGroupSalesLCY);
    end;

    var
        SalesLCY: Decimal;
        SalesQty: Decimal;
        DiscountAmount: Decimal;
        ItemGroupSalesLCY: Decimal;
        COGSLCY: Decimal;
}

