page 6014454 "NPR Campaign Discount Lines"
{
    Caption = 'Period Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Period Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
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
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Price field';
                }
                field("Campaign Profit"; Rec."Campaign Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Campaign Profit field';
                }
                field(Control1160330002; Rec.Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comment';
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Quantity On Purchase Order"; Rec."Quantity On Purchase Order")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Cost field';
                }
                field(Profit; Rec.Profit)
                {
                    ApplicationArea = All;
                    Caption = 'Revenue of period';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revenue of period field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Date field';
                }
                field("Unit Price Incl. VAT"; Rec."Unit Price Incl. VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Comment)
            {
                Caption = 'Comment';
                Image = Comment;
                RunObject = Page "NPR Retail Comments";
                RunPageLink = "Table ID" = CONST(6014414),
                              "No." = FIELD(Code),
                              "No. 2" = FIELD("Item No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Comment action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.40 [294655]
        Rec.CalcFields("Unit Price Incl. VAT");
        //CALCFIELDS(Status,"Unit Price Incl. VAT");
        //+NPR5.40 [294655]
        //-NPR5.38 [300893]
        //OnAfterGetCurrRecord;
        AfterGetCurrRecord;
        //+NPR5.38 [300893]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.38 [300893]
        //OnAfterGetCurrRecord;
        AfterGetCurrRecord;
        //+NPR5.38 [300893]
    end;

    var
        Item: Record Item;

    procedure GetCurrLine(var PeriodDiscountLine: Record "NPR Period Discount Line")
    begin
        PeriodDiscountLine := Rec;
    end;

    local procedure AfterGetCurrRecord()
    begin
        xRec := Rec;
        //-NPR5.40 [294655]
        Rec.CalcFields("Unit Price Incl. VAT");
        //CALCFIELDS(Status,"Unit Price Incl. VAT");
        //+NPR5.40 [294655]
    end;
}

