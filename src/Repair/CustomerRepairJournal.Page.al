page 6014504 "NPR Customer Repair Journal"
{
    // NPR70.00.00.01/BHR/20150211 CASE 204899 add new fields " Item part no", description, Quantity
    // NPR5.26/TS/20160913  CASE 251086 Added field Qty Posted
    // NPR5.30/BHR /20170202 CASE 262923 Add fields to page

    AutoSplitKey = true;
    Caption = 'Customer Repair Register';
    PageType = ListPart;
    SourceTable = "NPR Customer Repair Journal";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Date"; Date)
                {
                    ApplicationArea = All;
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                }
                field("Item Part No."; "Item Part No.")
                {
                    ApplicationArea = All;
                    Visible = Show2;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Visible = Show2;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Visible = show2;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Visible = show2;
                }
                field("Qty Posted"; "Qty Posted")
                {
                    ApplicationArea = All;
                    Visible = Show2;
                }
                field("Unit Price Excl. VAT"; "Unit Price Excl. VAT")
                {
                    ApplicationArea = All;
                    Visible = Show2;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    Visible = show2;
                }
                field("Expenses to be charged"; "Expenses to be charged")
                {
                    ApplicationArea = All;
                    Enabled = EnableExpense;
                    Visible = show2;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Visible = show2;
                }
                field("VAT Amount"; "VAT Amount")
                {
                    ApplicationArea = All;
                    Visible = show2;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.30 [262923]
        if CustomerRepair.Get("Customer Repair No.") then begin
            if (CustomerRepair.Status <> CustomerRepair.Status::Claimed) and (Description <> '') then
                EnableExpense := true
            else
                EnableExpense := false;
        end;
        //NPR5.30 [262923]
    end;

    var
        [InDataSet]
        Show2: Boolean;
        EnableExpense: Boolean;
        CustomerRepair: Record "NPR Customer Repair";

    procedure ShowField(var ShowField1: Boolean)
    begin
        Show2 := ShowField1;
        CurrPage.Update(true);
        CurrPage.Activate(Show2);
    end;
}

