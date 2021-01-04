page 6014428 "NPR Salesperson Card"
{
    // 
    // //-3.1a Ved Nikolai Pedersen
    //   Tilf¢jet F9 åbern form 5117
    // 
    // //-NPR3.c d.25.05.05 v. Simon Sch¢bel
    //   Oversættelse
    // NPR4.14/TS/20150818 CASE 220962 Removed field Item Filter,Item Group Filter,Global Dim 1 Filter
    // NPR5.26/TS/20160809 CASE 248269 Removed Actions Add to Staff Sale and Related Customer
    // NPR5.26/CLVA/20160902 CASE 48272 Added actions Camera and Identify. Added field Picture
    // NPR5.30/TJ  /20170222 CASE 266875 Removed function AutoCreateCustomer as it's not used anywhere
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.42/TS  /20180509 CASE 313970 Added Masjked on field Register Password
    // NPR5.53/BHR /20190810 CASE 369354 Removed Fields 'New Customer creation'

    Caption = 'Salesperson/Purchaser Card';
    SourceTable = "Salesperson/Purchaser";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Job Title"; "Job Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Title field';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Commission %"; "Commission %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Commission % field';
                }
                field("Maximum Cash Returnsale"; "NPR Maximum Cash Returnsale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Maximum Cash Returnsale field';
                }
                field(Picture; "NPR Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Picture field';
                }
            }
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; "NPR Register Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the NPR Register Password field';
                }
                field("Reverse Sales Ticket"; "NPR Reverse Sales Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Reverse Sales Ticket field';
                }
                field("Locked-to Register No."; "NPR Locked-to Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Locked-to Register No. field';
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("Hide Register Imbalance"; "NPR Hide Register Imbalance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Hide Register Imbalance field';
                }
                field("Sales (Qty.)"; "NPR Sales (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Sales (Qty.) field';
                }
                field("Discount Amount"; "NPR Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Discount Amount field';
                }
                field("Item Group Sales (LCY)"; "NPR Item Group Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Item Group Sales (LCY) field';
                }
                field("Sales (LCY)"; "NPR Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Sales (LCY) field';
                }
                field("COGS (LCY)"; "NPR COGS (LCY)")
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
            action(Kassekoder)
            {
                Caption = 'Cash Codes';
                Image = "Action";
                RunObject = Page "NPR Alternative Number";
                RunPageLink = Code = FIELD(Code),
                              Type = CONST(SalesPerson);
                RunPageView = SORTING(Type, Code, "Alt. No.");
                ShortCutKey = 'Ctrl+A';
                ApplicationArea = All;
                ToolTip = 'Executes the Cash Codes action';
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

    var
        npc: Record "NPR Retail Setup";
}

