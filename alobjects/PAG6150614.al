page 6150614 "POS Store List"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.34/KENU/20170623 CASE 282023 Added page POS Unit List in Navigate Tab
    // NPR5.36/KENU/20170807 CASE 285988 Added page "NP Retail Setup" in Navigate Tab
    // NPR5.36/BR  /20170810 CASE 277096 Added Actions to navigate to Entries, Ledger Registers and Posting Setup
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register No.
    // NPR5.48/TS  /20181213  CASE 339803 Added field Store Group Code
    // NPR5.50/CLVA/20190304 CASE 332844 Added Action Group "Stock-Take"

    Caption = 'POS Store List';
    CardPageID = "POS Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Store";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Store Group Code";"Store Group Code")
                {
                }
                field("Store Category Code";"Store Category Code")
                {
                }
                field("Store Locality Code";"Store Locality Code")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Unit List")
            {
                Caption = 'POS Unit List';
                Image = List;
                RunObject = Page "POS Unit List";
            }
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                Image = Setup;
                RunObject = Page "NP Retail Setup";
            }
            action("POS Posting Setup")
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Posting Setup";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Period Register List";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Entry List";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
            group("Stock-Take")
            {
                Caption = 'Stock-Take';
                Visible = StockTakeVisible;
                action(Countings)
                {
                    Caption = 'Countings';
                    Image = LedgerEntries;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = false;
                    RunObject = Page "CS Stock-Takes List";
                    RunPageLink = Location=FIELD("Location Code");
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.50
        if CSSetup.Get then
          StockTakeVisible := CSSetup."Enable Capture Service";
        //+NPR5.50
    end;

    var
        CSSetup: Record "CS Setup";
        StockTakeVisible: Boolean;
}

