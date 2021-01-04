page 6014564 "NPR Warranty Cat. Lines"
{
    // NPR5.29/MHA /20161208  CASE 256690 AutoSplitKey set to Yes
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    AutoSplitKey = true;
    Caption = 'Warranty Cat. Lines';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Warranty Line";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Label No."; "Label No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Label Number field';
                }
                field("Lock Code"; "Lock Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Code field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field(InsuranceType; InsuranceType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance Type  field';
                }
                field("Insurance send"; "Insurance send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance send field';
                }
                field("Serial No. not Created"; "Serial No. not Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. not Created field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount incl. VAT"; "Amount incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount incl. VAT field';
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
            }
        }
    }

    actions
    {
    }
}

