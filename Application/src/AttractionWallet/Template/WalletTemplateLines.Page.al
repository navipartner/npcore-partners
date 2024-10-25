page 6184855 "NPR WalletTemplateLines"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpIa Item AddOn Line";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of entity that will be sold for this line.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    Enabled = (Rec.Type = Rec.Type::Quantity);
                    ShowMandatory = (Rec.Type = Rec.Type::Quantity);
                    ToolTip = 'Specifies the number of an item.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Enabled = (Rec.Type = Rec.Type::Quantity);
                    ToolTip = 'Specifies the variant of the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the entry of the product to be sold.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ToolTip = 'Specifies an additional description of the entry of the product to be sold.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies how many units are being sold.';
                    ApplicationArea = NPRRetail;
                }
                field("Per Unit"; Rec."Per Unit")
                {
                    ToolTip = 'Specifies that the quantity is calculated per each unit of base item.';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Quantity"; Rec."Fixed Quantity")
                {
                    ToolTip = 'Specifies if quantity can be changed on POS unit. If it''s current entry have a flag fixed quantity, then POS entry will be created with predefined Quantity.';
                    ApplicationArea = NPRRetail;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ToolTip = 'Specifies if salesperson can omit inserting the line to the sale.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the price of one unit of the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Unit Price"; Rec."Use Unit Price")
                {
                    ToolTip = 'Specifies if the price of one unit of the item should be used for sold item.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field(IncludeFromDate; Rec.IncludeFromDate)
                {
                    ToolTip = 'Specifies the date from which the template line is included in the sale.';
                    ApplicationArea = NPRRetail;
                }
                field(IncludeUntilDate; Rec.IncludeUntilDate)
                {
                    ToolTip = 'Specifies the date to which the template line is included in the sale.';
                    ApplicationArea = NPRRetail;
                }
                field(AddToWallet; Rec.AddToWallet)
                {
                    ToolTip = 'Specifies if the template line should be added to the wallet.';
                    ApplicationArea = NPRRetail;
                }
                field("Comment Enabled"; Rec."Comment Enabled")
                {
                    ToolTip = 'Specifies if the comment is enabled for the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Before Insert Function"; Rec."Before Insert Function")
                {
                    ToolTip = 'Specifies processing unit which will be executed before POS template line is created.';
                    ApplicationArea = NPRRetail;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Before Insert Codeunit ID"; Rec."Before Insert Codeunit ID")
                {
                    Visible = false;
                    ToolTip = 'Specifies id of the processing unit for recalculating unit price on current entry by applying unit price % from template line setup table to the ratio of Total Amount and Quantity sold on POS.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Before Insert Codeunit Name"; Rec."Before Insert Codeunit Name")
                {
                    Visible = false;
                    ToolTip = 'Specifies name of the processing unit for recalculating unit price on current entry by applying unit price % from template line setup table to the ratio of Total Amount and Quantity sold on POS.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Before Insert Setup")
            {
                Image = Setup;
                Visible = HasBeforeInsertSetup;
                ToolTip = 'View or edit setup for current template line. If setup doesn''t exist for current line, then this action will create setup entry';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn";
                    Handled: Boolean;
                begin
                    ItemAddOnMgt.RunBeforeInsertSetup(Rec, Handled);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasBeforeInsertSetup();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.AddToWallet := true;
    end;

    var
        HasBeforeInsertSetup: Boolean;

    local procedure SetHasBeforeInsertSetup()
    var
        ItemAddOn: Codeunit "NPR NpIa Item AddOn";
    begin
        HasBeforeInsertSetup := false;
        ItemAddOn.CheckIfHasSetupBeforeInsertSetup(Rec, HasBeforeInsertSetup);
    end;
}

