pageextension 6014446 "NPR Item Categories" extends "Item Categories"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Global Dimension 1 Code"; Rec."NPR Global Dimension 1 Code")
            {

                ToolTip = 'Specifies the value of the NPR Global Dimension 1 Code field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Global Dimension 2 Code"; Rec."NPR Global Dimension 2 Code")
            {

                ToolTip = 'Specifies the value of the NPR Global Dimension 2 Code field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Item Template Code"; Rec."NPR Item Template Code")
            {

                ToolTip = 'Specifies the value of the NPR Item Template Code field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Blocked"; Rec."NPR Blocked")
            {

                ToolTip = 'Specifies the value of the NPR Blocked field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group("NPR Dimension")
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                action("NPR Dimensions-Single")
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = Const(5722), "No." = Field(Code);
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'Executes the Dimensions action';
                    ApplicationArea = NPRRetail;
                }
            }

            group("NPR Function")
            {
                Caption = '&Function';

                action("NPR Create Item Template")
                {

                    Caption = 'Create Item Template';
                    Image = Template;
                    ToolTip = 'Executes the Create Item Template action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemCategory: Record "Item Category";
                        TempItem: Record Item temporary;
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        ContinueQst: Label 'You are creating item template for selected categories. Do you want to continue?';
                    begin
                        CurrPage.SetSelectionFilter(ItemCategory);
                        if ItemCategory.FindSet() then
                            if Confirm(ContinueQst) then begin
                                repeat
                                    if ItemCategory."NPR Item Template Code" = '' then begin
                                        TempItem."Item Category Code" := ItemCategory.Code;
                                        ItemCategory."NPR Item Template Code" := ItemCategoryMgt.CreateItemTemplate(ItemCategory, TempItem);
                                        ItemCategory.Modify(true);
                                    end;
                                until ItemCategory.Next() = 0;

                                UpdateDisplayOrder();
                                CurrPage.Update();
                            end;
                    end;
                }
                action("NPR Create Item From Item Category")
                {
                    Caption = 'Create Item(s) From Item Category';
                    Image = ItemGroup;

                    ToolTip = 'Executes the Create Item(s) From Item Category action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemCategory: Record "Item Category";
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        Counter: Integer;
                        ItemsCreatedMsg: Label '%1 Item(s) has been created.', Comment = '%1 = Number of Items';
                    begin
                        Counter := 0;
                        CurrPage.SetSelectionFilter(ItemCategory);
                        if ItemCategory.FindSet() then begin
                            repeat
                                if ItemCategoryMgt.CreateItemFromItemCategory(ItemCategory) <> '' then
                                    Counter += 1;
                            until ItemCategory.Next() = 0;

                            Message(ItemsCreatedMsg, Counter);
                        end;
                    end;
                }
                action("NPR Copy Item Category Setup to SubCategories")
                {
                    Caption = 'Copy Item Category Setup to SubCategories';
                    Image = ProdBOMMatrixPerVersion;

                    ToolTip = 'Executes the Copy Item Category Setup to SubCategories';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemCategory: Record "Item Category";
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        ContinueQst: Label 'You are copying setup from selected categories to their sub categories. Do you want to continue?';
                    begin
                        CurrPage.SetSelectionFilter(ItemCategory);
                        if ItemCategory.FindSet() then
                            if Confirm(ContinueQst) then begin
                                repeat
                                    ItemCategoryMgt.CopySetupToChildren(ItemCategory, true);
                                until ItemCategory.Next() = 0;
                                UpdateDisplayOrder();
                                CurrPage.Update();
                            end;
                    end;
                }
            }
        }
        addlast(Navigation)
        {
            group("NPR &Overview")
            {
                Caption = '&Overview';
                action("NPR Item Ledger Entries")
                {
                    Caption = '&Item Ledger Entries';
                    Image = Form;
                    RunObject = Page "NPR Aux. Item Ledger Entries";
                    RunPageLink = "Item Category Code" = FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+N';

                    ToolTip = 'Executes the Item Ledger Entries action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR VAT Posting Grups")
                {
                    Caption = '&VAT Posting Grups';
                    Image = Form;

                    ToolTip = 'Executes the &VAT Posting Grups action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VATPostingSetup: Record "VAT Posting Setup";
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        MissingSettingsErr: Label 'Enter VAT posting settings on item category card!';
                    begin
                        if ItemCategoryMgt.GetVATPostingSetupFromItemCategory(Rec, VATPostingSetup) then
                            PAGE.RunModal(PAGE::"VAT Posting Setup Card", VATPostingSetup)
                        else
                            Error(MissingSettingsErr);
                    end;
                }
                action("NPR Item List")
                {
                    Caption = '&Item List';
                    Image = ItemWorksheet;
                    RunObject = Page "Item List";
                    RunPageLink = "Item Category Code" = FIELD(Code);

                    ToolTip = 'Executes the &Item List action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    local procedure UpdateDisplayOrder()
    var
        ItemCategoryMgt: Codeunit "Item Category Management";
    begin
        ItemCategoryMgt.UpdatePresentationOrder();
    end;
}