﻿page 6150614 "NPR POS Store List"
{
    Caption = 'POS Store List';
    ContextSensitiveHelpPage = 'retail/posunit/howto/Create_new_POS_store.html';
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
                    ToolTip = 'Defines code of POS Store';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Defines name of POS Store';
                    ApplicationArea = NPRRetail;
                }
                field(Inactive; Rec.Inactive)
                {
                    ToolTip = 'Defines is POS Store inactive';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Defines Post Code of POS Store';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Defines city in which store is located';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Dimension value of Global dimension 1 assigned to POS Store';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Dimension value of Global dimension 2 assigned to POS Store';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Defines Location for store. This location is used for posting item ledger entries';
                    ApplicationArea = NPRRetail;
                }
                field("Store Group Code"; Rec."Store Group Code")
                {

                    ToolTip = 'Defines Store Group for a store. Store Group code can be used in reporting purposes';
                    ApplicationArea = NPRRetail;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {

                    ToolTip = 'Defines Store Category for a store. Store Category code can be used in reporting purposes';
                    ApplicationArea = NPRRetail;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {

                    ToolTip = 'Defines Store Locality for a store. Store Locality code can be used in reporting purposes';
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
