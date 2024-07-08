page 6150614 "NPR POS Store List"
{
    ApplicationArea = NPRRetail;
    Caption = 'POS Store List';
    CardPageID = "NPR POS Store Card";
    ContextSensitiveHelpPage = 'docs/retail/pos_store/intro/';
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines code of POS Store';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines name of POS Store';
                }
                field(Inactive; Rec.Inactive)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines is POS Store inactive';
                }
                field("Post Code"; Rec."Post Code")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Post Code of POS Store';
                }
                field(City; Rec.City)
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines city in which store is located';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Dimension value of Global dimension 1 assigned to POS Store';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Dimension value of Global dimension 2 assigned to POS Store';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Location for store. This location is used for posting item ledger entries';
                }
                field("Store Group Code"; Rec."Store Group Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Store Group for a store. Store Group code can be used in reporting purposes';
                    Visible = false;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Store Category for a store. Store Category code can be used in reporting purposes';
                    Visible = false;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Store Locality for a store. Store Locality code can be used in reporting purposes';
                    Visible = false;
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
                        ApplicationArea = NPRRetail;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(6150614),
                                      "No." = FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';

                        ToolTip = 'Opens the Default Dimensions List';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = NPRRetail;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        ToolTip = 'Opens the Default Dimensions-Multiple List';

                        trigger OnAction()
                        var
                            POSStore: Record "NPR POS Store";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(POSStore);
                            DefaultDimMultiple.SetMultiRecord(POSStore, Rec.FieldNo(Code));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
                action("POS Unit List")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Unit List';
                    Image = List;
                    RunObject = Page "NPR POS Unit List";

                    ToolTip = 'Opens the POS Unit List';
                }
                action("POS Posting Setup")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Posting Setup';
                    Image = GeneralPostingSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "NPR POS Posting Setup";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'View or edit the POS Posting Setup';
                }
                action("POS Period Registers")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Period Registers';
                    Image = Register;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "NPR POS Period Register List";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'Opens the POS Period Registers List';
                }
                action("POS Entries")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Entries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "NPR POS Entry List";
                    RunPageLink = "POS Store Code" = FIELD(Code);

                    ToolTip = 'Opens the POS Entries List';
                }
            }
        }
    }
}