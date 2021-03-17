page 6150614 "NPR POS Store List"
{

    Caption = 'POS Store List';
    CardPageID = "NPR POS Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Store";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Store Group Code"; "Store Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Group Code field';
                }
                field("Store Category Code"; "Store Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Category Code field';
                }
                field("Store Locality Code"; "Store Locality Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Locality Code field';
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
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-Single action';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-&Multiple action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Unit List action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Posting Setup action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Period Registers action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Entries action';
                }
            }

        }
    }


}
