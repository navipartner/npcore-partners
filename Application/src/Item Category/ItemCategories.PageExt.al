pageextension 6014446 "NPR Item Categories" extends "Item Categories"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Global Dimension 1 Code"; Rec."NPR Global Dimension 1 Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Global Dimension 1 Code field';
            }
            field("NPR Global Dimension 2 Code"; Rec."NPR Global Dimension 2 Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Global Dimension 2 Code field';
            }
            field("NPR Item Template Code"; Rec."NPR Item Template Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Template Code field';
            }
            field("NPR Blocked"; Rec."NPR Blocked")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Blocked field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';
                }
            }

            group("NPR Function")
            {
                Caption = '&Function';

                action("NPR Create Item Template")
                {
                    ApplicationArea = All;
                    Caption = 'Create Item Template';
                    Image = Template;
                    ToolTip = 'Executes the Create Item Template action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Item(s) From Item Category action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy Item Category Setup to SubCategories';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Ledger Entries action';
                }
                action("NPR VAT Posting Grups")
                {
                    Caption = '&VAT Posting Grups';
                    Image = Form;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &VAT Posting Grups action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Item List action';
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