page 6151127 "NPR NpIa Item AddOn Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpIa Item AddOn Line";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of entity that will be sold for this line.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Enabled = (Rec.Type = 0);
                    ToolTip = 'Specifies the number of an item.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Enabled = (Rec.Type = 0);
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the entry of the product to be sold.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an additional description of the entry of the product to be sold.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units are being sold.';
                }
                field("Per Unit"; Rec."Per Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units are being sold in base unit of measure.';
                }
                field("Fixed Quantity"; Rec."Fixed Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if quantity can be changed on POS unit. If it''s current entry have a flag fixed quantity, then POS entry will be created with predefined Quantity.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of one unit of the item.';
                }
                field("Use Unit Price"; Rec."Use Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the price of one unit of the item should be used for sold item.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
                field("Comment Enabled"; Rec."Comment Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the comment is enabled for the item on the line.';
                }
                field("Before Insert Function"; Rec."Before Insert Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies processing unit which will be executed before POS add-on line is created.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Before Insert Codeunit ID"; Rec."Before Insert Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies id of the processing unit for recalculating unit price on current entry by appling unit price % from add-on line setup table to the ratio of Total Amount and Quantity sold on POS.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Before Insert Codeunit Name"; Rec."Before Insert Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies name of the processing unit for recalculating unit price on current entry by appling unit price % from add-on line setup table to the ratio of Total Amount and Quantity sold on POS.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Options")
            {
                Caption = 'Select Options';
                Image = List;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpIa ItemAddOn Line Opt.";
                RunPageLink = "AddOn No." = FIELD("AddOn No."),
                              "AddOn Line No." = FIELD("Line No.");
                ShortCutKey = 'Ctrl+F7';
                Visible = (Rec.Type = 1);
                ApplicationArea = All;
                ToolTip = 'View or edit list of different add-on line options which could be as a template applied to add-on line.';
            }
            action("Before Insert Setup")
            {
                Image = Setup;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasBeforeInsertSetup;
                ApplicationArea = All;
                ToolTip = 'View or edit setup for current add-on line. If setup doesn''t exist for current line, then this action will create setup entry';

                trigger OnAction()
                var
                    NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
                    Handled: Boolean;
                begin
                    NpIaItemAddOnMgt.RunBeforeInsertSetup(Rec, Handled);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasBeforeInsertSetup();
    end;

    var
        HasBeforeInsertSetup: Boolean;

    local procedure SetHasBeforeInsertSetup()
    var
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        HasBeforeInsertSetup := false;
        NpIaItemAddOnMgt.HasBeforeInsertSetup(Rec, HasBeforeInsertSetup);
    end;
}

