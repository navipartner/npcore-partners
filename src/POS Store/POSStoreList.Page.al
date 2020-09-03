page 6150614 "NPR POS Store List"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.34/KENU/20170623 CASE 282023 Added page POS Unit List in Navigate Tab
    // NPR5.36/KENU/20170807 CASE 285988 Added page "NP Retail Setup" in Navigate Tab
    // NPR5.36/BR  /20170810 CASE 277096 Added Actions to navigate to Entries, Ledger Registers and Posting Setup
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register No.
    // NPR5.48/TS  /20181213  CASE 339803 Added field Store Group Code
    // NPR5.50/CLVA/20190304 CASE 332844 Added Action Group "Stock-Take"
    // NPR5.53/ALPO/20191021 CASE 371956 Dimensions: POS Store & POS Unit integration
    // NPR5.54/SARA/20200301 CASE 395944 Added 'Location Code','VAT Bus. Posting Group',Gen. Bus. Posting Group'

    Caption = 'POS Store List';
    CardPageID = "NPR POS Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Store";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
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
                field("Store Group Code"; "Store Group Code")
                {
                    ApplicationArea = All;
                }
                field("Store Category Code"; "Store Category Code")
                {
                    ApplicationArea = All;
                }
                field("Store Locality Code"; "Store Locality Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Store")
            {
                Caption = 'POS Store';
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(6150614),
                                      "No." = FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        trigger OnAction()
                        var
                            POSStore: Record "NPR POS Store";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            //-NPR5.53 [371956]
                            CurrPage.SetSelectionFilter(POSStore);
                            DefaultDimMultiple.SetMultiRecord(POSStore, FieldNo(Code));
                            DefaultDimMultiple.RunModal;
                            //-NPR5.53 [371956]
                        end;
                    }
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    Image = List;
                    RunObject = Page "NPR POS Unit List";
                }
                action("NP Retail Setup")
                {
                    Caption = 'NP Retail Setup';
                    Image = Setup;
                    RunObject = Page "NPR NP Retail Setup";
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    Image = GeneralPostingSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Posting Setup";
                    RunPageLink = "POS Store Code" = FIELD(Code);
                }
                action("POS Period Registers")
                {
                    Caption = 'POS Period Registers';
                    Image = Register;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Period Register List";
                    RunPageLink = "POS Store Code" = FIELD(Code);
                }
                action("POS Entries")
                {
                    Caption = 'POS Entries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry List";
                    RunPageLink = "POS Store Code" = FIELD(Code);
                }
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
                    RunObject = Page "NPR CS Stock-Takes List";
                    RunPageLink = Location = FIELD("Location Code");
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
        CSSetup: Record "NPR CS Setup";
        StockTakeVisible: Boolean;
}

