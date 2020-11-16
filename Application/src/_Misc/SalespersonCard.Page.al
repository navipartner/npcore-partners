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
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Job Title"; "Job Title")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Commission %"; "Commission %")
                {
                    ApplicationArea = All;
                }
                field("Maximum Cash Returnsale"; "NPR Maximum Cash Returnsale")
                {
                    ApplicationArea = All;
                }
                field(Picture; "NPR Picture")
                {
                    ApplicationArea = All;
                }
            }
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; "NPR Register Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Reverse Sales Ticket"; "NPR Reverse Sales Ticket")
                {
                    ApplicationArea = All;
                }
                field("Locked-to Register No."; "NPR Locked-to Register No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("Hide Register Imbalance"; "NPR Hide Register Imbalance")
                {
                    ApplicationArea = All;
                }
                field("Sales (Qty.)"; "NPR Sales (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "NPR Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Item Group Sales (LCY)"; "NPR Item Group Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Sales (LCY)"; "NPR Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("COGS (LCY)"; "NPR COGS (LCY)")
                {
                    ApplicationArea = All;
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
            }
            action("&Statistics")
            {
                Caption = '&Statistics';
                Image = Statistics;
                RunObject = Page "Salesperson Statistics";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'F9';
                ApplicationArea = All;
            }
            action("Sales Person report")
            {
                Caption = 'Sales Person report';
                Image = SalesPerson;
                ShortCutKey = 'Ctrl+F9';
                ApplicationArea = All;
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
            }
            action("Remove from staff Sale")
            {
                Caption = 'Remove from Staff Sale';
                Image = RemoveContacts;
                ApplicationArea = All;
            }
        }
    }

    var
        npc: Record "NPR Retail Setup";
}

