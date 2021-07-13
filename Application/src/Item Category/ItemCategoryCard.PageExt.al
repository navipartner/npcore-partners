pageextension 6014400 "NPR Item Category Card" extends "Item Category Card"
{
    layout
    {
        addlast(General)
        {

            field("NPR Item Template Code"; Rec."NPR Item Template Code")
            {

                ToolTip = 'Specifies the value of the NPR Item Template Code field';
                ApplicationArea = NPRRetail;
            }
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
            field("NPR Blocked"; Rec."NPR Blocked")
            {

                ToolTip = 'Specifies the value of the NPR Blocked field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Main Category"; Rec."NPR Main Category")
            {

                ToolTip = 'Specifies the value of the NPR Main Category field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Main Category Code"; Rec."NPR Main Category Code")
            {

                ToolTip = 'Specifies the value of the NPR Main Category Code field';
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
                Caption = '&Functions';
                action("NPR Create Item Template")
                {

                    Caption = 'Create Item Template';
                    Image = Template;
                    ToolTip = 'Executes the Create Item Template action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        TempItem: Record Item temporary;
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        ContinueQst: Label 'You are creating item template for current item category. Do you want to continue?';
                    begin
                        Rec.Testfield("NPR Item Template Code", '');
                        if Confirm(ContinueQst) then begin
                            TempItem."Item Category Code" := Rec.Code;
                            Rec."NPR Item Template Code" := ItemCategoryMgt.CreateItemTemplate(Rec, TempItem);
                            Rec.Modify(true);
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
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                        NewItemNo: Code[20];
                        ItemCreatedMsg: Label 'Created Item No. %1.';
                    begin
                        NewItemNo := ItemCategoryMgt.CreateItemFromItemCategory(Rec);
                        if NewItemNo <> '' then
                            Message(ItemCreatedMsg, NewItemNo);
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
                        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
                    begin
                        ItemCategoryMgt.CopySetupToChildren(Rec, false);
                        CurrPage.Update();
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
}