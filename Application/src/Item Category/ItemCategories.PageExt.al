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
            field("NPR Gen. Bus. Posting Group"; Rec."NPR Gen. Bus. Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Gen. Bus. Posting Group field';
            }
            field("NPR Gen. Prod. Posting Group"; Rec."NPR Gen. Prod. Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Gen. Prod. Posting Group field';
            }
            field("NPR VAT Bus. Posting Group"; Rec."NPR VAT Bus. Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR VAT Bus. Posting Group field';
            }
            field("NPR VAT Prod. Posting Group"; Rec."NPR VAT Prod. Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR VAT Prod. Posting Group field';
            }
            field("NPR Inventory Posting Group"; Rec."NPR Inventory Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Inventory Posting Group field';
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

                action("NPR Create Item From Item Category")
                {
                    Caption = 'Create Item(s) From Item Category';
                    Image = ItemGroup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Item(s) From Item Category action';

                    trigger OnAction()
                    var
                        ItemCategory: Record "Item Category";
                    begin
                        CurrPage.SetSelectionFilter(ItemCategory);
                        REPORT.Run(Report::"NPR Create Item From ItemGr.", true, false, ItemCategory);
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
                        MissingSettingsErr: Label 'Enter VAT posting settings on item category card!';
                    begin
                        if VATPostingSetup.Get("NPR VAT Bus. Posting Group", "NPR VAT Prod. Posting Group") then
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
}