page 6014669 "NPR POS Entry Statistics"
{
    Extensible = False;
    Caption = 'POS Entry Statistics';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "NPR POS Entry Statistics";
    UsageCategory = None;
    DataCaptionFields = "Data Caption";

    layout
    {
        area(content)
        {
            grid(Statistics)
            {
                ShowCaption = false;
                group(Payment)
                {
                    Caption = 'Payment';
                    field("Payment Amount"; Rec."Payment Amount")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the payment amount.';
                    }
                    field("Tax Payment Base Amount"; Rec."Tax Payment Base Amount")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the tax base amount.';
                    }
                    field("Tax Payment Amount"; Rec."Tax Payment Amount")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the tax amount.';
                    }
                }
                group(POSEntry)
                {
                    Caption = 'POS Entry';
                    group(Direct)
                    {
                        Caption = 'Direct Sale';
                        field("Direct Sale Excl. Tax"; Rec."Direct Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the direct sale amount after excluding tax.';
                        }
                        field(TaxAmount1; Rec."Direct Sale Amount Incl. Tax" - Rec."Direct Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            Editable = false;
                            Caption = 'Tax Amount';
                            ToolTip = 'Specifies the direct sale tax amount.';
                        }
                        field("Direct Sale Incl. Tax"; Rec."Direct Sale Amount Incl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the direct sale amount.';
                        }
                    }
                    group(Balancing)
                    {
                        Caption = 'Balancing';
                        field("Balancing Amount Excl. Tax"; Rec."Balancing Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the balancing amount after excluding tax.';
                        }
                        field(TaxAmount2; Rec."Balancing Amount Incl. Tax" - Rec."Balancing Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            Editable = false;
                            Caption = 'Tax Amount';
                            ToolTip = 'Specifies the balance tax amount.';
                        }
                        field("Balancing Amount Incl. Tax"; Rec."Balancing Amount Incl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the balancing amount.';
                        }
                    }
                    group(DebitSale)
                    {
                        Caption = 'Debit Sale';

                        field("Debit Sale Amount Excl. Tax"; Rec."Debit Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the debit sale amount after excluding tax.';
                        }
                        field(TaxAmount3; Rec."Debit Sale Amount Incl. Tax" - Rec."Debit Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            Editable = false;
                            Caption = 'Tax Amount';
                            ToolTip = 'Specifies the debit sale tax amount.';
                        }
                        field("Debit Sale Amount Incl. Tax"; Rec."Debit Sale Amount Incl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the debit sale amount.';
                        }
                    }
                    group(CreditSale)
                    {
                        Caption = 'Credit Sale';

                        field("Credit Sale Excl. Tax"; Rec."Credit Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the credit sale amount after excluding tax.';
                        }
                        field(TaxAmount4; Rec."Credit Sale Amount Incl. Tax" - Rec."Credit Sale Amount Excl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            Editable = false;
                            Caption = 'Tax Amount';
                            ToolTip = 'Specifies the credit sale tax amount.';
                        }
                        field("Credit Sale Incl. Tax"; Rec."Credit Sale Amount Incl. Tax")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the credit sale amount.';
                        }
                    }
                }
            }
        }
    }
}
