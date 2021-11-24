page 6150614 "NPR POS Store List"
{

    Caption = 'POS Store List';
    CardPageID = "NPR POS Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Store";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code for the POS Store';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the name for the POS Store';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the Post Code of the location in which the store is located.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the City in which the POS Store is situated ';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the Location Code that is attached the POS Store ';
                    ApplicationArea = NPRRetail;
                }
                field("Store Group Code"; Rec."Store Group Code")
                {

                    ToolTip = 'Specifies a Group Code that a set of POS Stores can be grouped into for BI purposes.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {

                    ToolTip = 'Specifies a Category Code that POS Stores can be categorized into for BI purposes.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {

                    ToolTip = 'Specifies a Locality Code that POS Stores can be regrouped into for BI purposes';
                    ApplicationArea = NPRRetail;
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

                        ToolTip = 'Executes the Dimensions-Single action';
                        ApplicationArea = NPRRetail;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        ToolTip = 'Executes the Dimensions-&Multiple action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            POSStore: Record "NPR POS Store";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            //-NPR5.53 [371956]
                            CurrPage.SetSelectionFilter(POSStore);
                            DefaultDimMultiple.SetMultiRecord(POSStore, Rec.FieldNo(Code));
                            DefaultDimMultiple.RunModal();
                            //-NPR5.53 [371956]
                        end;
                    }
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    Image = List;
                    RunObject = Page "NPR POS Unit List";

                    ToolTip = 'Executes the POS Unit List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    Image = GeneralPostingSetup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Posting Setup";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'Executes the POS Posting Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Period Registers")
                {
                    Caption = 'POS Period Registers';
                    Image = Register;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Period Register List";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'Executes the POS Period Registers action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Entries")
                {
                    Caption = 'POS Entries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry List";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'Executes the POS Entries action';
                    ApplicationArea = NPRRetail;
                }
            }

        }
    }


}
