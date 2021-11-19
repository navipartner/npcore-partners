page 6014454 "NPR Campaign Discount Lines"
{
    Caption = 'Period Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Period Discount Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookUpItem(Text);
                    end;
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {
                    ToolTip = 'Specifies the value of the Period Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Profit"; Rec."Campaign Profit")
                {
                    ToolTip = 'Specifies the value of the Campaign Profit field';
                    ApplicationArea = NPRRetail;
                }
                field(Control1160330002; Rec.Comment)
                {
                    Caption = 'Comment';
                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {
                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity On Purchase Order"; Rec."Quantity On Purchase Order")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Period Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(Profit; Rec.Profit)
                {
                    Caption = 'Revenue of period';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revenue of period field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price Incl. VAT"; Rec."Unit Price Incl. VAT")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Unit Price Incl. VAT");
        AfterGetCurrRecord();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AfterGetCurrRecord();
    end;

    local procedure AfterGetCurrRecord()
    begin
        xRec := Rec;
        Rec.CalcFields("Unit Price Incl. VAT");
    end;

    local procedure LookUpItem(Text: Text)
    var
        Item: Record Item;
        Item2: Record Item;
        ItemList: Page "Item List";
    begin
        Item.FilterGroup(2);
        Item.FilterGroup(0);
        Clear(ItemList);
        ItemList.LookupMode(true);
        ItemList.SetTableView(Item);
        if Item2.Get(Text) then
            ItemList.SetRecord(Item2);
        if ItemList.RunModal() = ACTION::LookupOK then begin
            ItemList.GetRecord(Item);
            Rec.Validate("Item No.", Item."No.");
            Commit();
        end;
    end;
}

