page 6014433 "NPR Payment Type - Card"
{
    Caption = 'Payment Type Card';
    PromotedActionCategories = 'New,Process,Prints,Master Data,Test5,Test6,Test7,Test8';
    SourceTable = "NPR Payment Type POS";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6150671)
                {
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Register No. field';
                    }
                    field("Account Type"; "Account Type")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Account Type field';

                        trigger OnValidate()
                        begin
                            if "Account Type" = "Account Type"::Customer then begin
                                "G/L Account No." := '';
                                "Bank Acc. No." := '';
                            end else
                                if "Account Type" = "Account Type"::"G/L Account" then begin
                                    "Customer No." := '';
                                    "Bank Acc. No." := '';
                                end else begin
                                    "Customer No." := '';
                                    "G/L Account No." := '';
                                end;
                            CustomerEditable := "Account Type" = "Account Type"::Customer;
                            GlAccountEditable := "Account Type" = "Account Type"::"G/L Account";
                            BankEditable := "Account Type" = "Account Type"::Bank;
                        end;
                    }
                    field("G/L Account No."; "G/L Account No.")
                    {
                        ApplicationArea = All;
                        Editable = GlAccountEditable;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the G/L Account field';
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        Editable = CustomerEditable;
                        ToolTip = 'Specifies the value of the Customer field';
                    }
                    field("Bank Acc. No."; "Bank Acc. No.")
                    {
                        ApplicationArea = All;
                        Editable = BankEditable;
                        ToolTip = 'Specifies the value of the Bank field';
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Sales Line Text"; "Sales Line Text")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Line Text field';
                    }
                    field("Zero as Default on Popup"; "Zero as Default on Popup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Zero as Default on Popup field';
                    }
                }
                group(Control6150684)
                {
                    ShowCaption = false;
                    field("Search Description"; "Search Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Search Description field';
                    }
                    field(Prefix; Prefix)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Prefix field';
                    }
                    field("Processing Type"; "Processing Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Processing Type field';

                        trigger OnValidate()
                        begin
                            FixedAmountEditable := ("Processing Type" = "Processing Type"::"Gift Voucher");
                            QtyperSaleEditable := ("Processing Type" = "Processing Type"::"Gift Voucher");
                            MinSalesAmountEditable := ("Processing Type" = "Processing Type"::"Gift Voucher");
                        end;
                    }
                    field("Payment Method Code"; "Payment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Method Code field';
                    }
                    field(Posting; Posting)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting field';
                    }
                    field("Immediate Posting"; "Immediate Posting")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Immediate Posting field';
                    }
                    field("Day Clearing Account"; "Day Clearing Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Day Clearing Account field';
                    }
                    field(Euro; Euro)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Euro field';
                    }
                    field("Is Check"; "Is Check")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Check field';
                    }
                    field("Common Company Clearing"; "Common Company Clearing")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Common Company Clearing field';
                    }
                    field("Auto End Sale"; "Auto End Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Auto end sale field';
                    }
                    field("Forced Amount"; "Forced Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Forced amount field';
                    }
                    field("Match Sales Amount"; "Match Sales Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Match Sales Amount field';
                    }
                    field("Reverse Unrealized VAT"; "Reverse Unrealized VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reverse Unrealized VAT field';
                    }
                    field(Control6150645; '')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field("Open Drawer"; "Open Drawer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Open Drawer field';
                    }
                }
            }
            group(Options)
            {
                Caption = 'Option';
                field("Via Terminal"; "Via Terminal")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Via Cash Terminal field';
                }
                field("Reference Incoming"; "Reference Incoming")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Incoming field';
                }
                field("Fixed Rate"; "Fixed Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Rate field';
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding precision field';
                }
                field("Receipt - Post it Now"; "Receipt - Post it Now")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt - Post it now field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only used by Global Dimension 1 field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only used by Global Dimension 2 field';
                }
                field("Maximum Amount"; "Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max amount field';
                }
                field("Minimum Amount"; "Minimum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Min amount field';
                }
                field("No Min Amount on Web Orders"; "No Min Amount on Web Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No Min Amount on Web Orders field';
                }
                field("Allow Refund"; "Allow Refund")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Refund field';
                }
                field("EFT Surcharge Service Item No."; "EFT Surcharge Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Surcharge Service Item No. field';
                }
                field("EFT Tip Service Item No."; "EFT Tip Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tip Service Item No. field';
                }
            }
            group(Integration)
            {
                Caption = 'Integration';
                group(Specialization)
                {
                    Caption = 'Specialization';
                    field("Validation Codeunit"; "Validation Codeunit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validation Codeunit field';
                    }
                    field("On Sale End Codeunit"; "On Sale End Codeunit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the On Sale End Codeunit field';
                    }
                    field("Post Processing Codeunit"; "Post Processing Codeunit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Processing Codeunit field';
                    }
                }
            }
            group(Balancing)
            {
                field("To be Balanced"; "To be Balanced")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Incl. in balancing field';
                }
                field("Balancing Type"; "Balancing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing type field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = '&Function';
                Image = Setup;
                action("Prefix Table")
                {
                    Caption = 'Prefix Table';
                    Image = "Table";
                    ShortCutKey = 'F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Prefix Table action';

                    trigger OnAction()
                    var
                        PaymentTypePrefix: Record "NPR Payment Type - Prefix";
                        CreditCardPrefix: Page "NPR Credit Card Prefix";
                    begin
                        PaymentTypePrefix.Reset;
                        PaymentTypePrefix.SetRange("Payment Type", "No.");
                        PaymentTypePrefix.SetRange("Register No.", "Register No.");
                        PaymentTypePrefix.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                        CreditCardPrefix.SetTableView(PaymentTypePrefix);
                        CreditCardPrefix.LookupMode := true;
                        CreditCardPrefix.ShowPrefix;
                        CreditCardPrefix.RunModal;
                    end;
                }
                action("Coin Types")
                {
                    Caption = 'Coin Types';
                    Image = Currency;
                    ShortCutKey = 'Ctrl+F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coin Types action';

                    trigger OnAction()
                    var
                        PaymentTypePrefix: Record "NPR Payment Type - Prefix";
                        CreditCardPrefix: Page "NPR Credit Card Prefix";
                    begin
                        PaymentTypePrefix.Reset;
                        PaymentTypePrefix.SetRange("Payment Type", "No.");
                        PaymentTypePrefix.SetRange("Register No.", "Register No.");
                        CreditCardPrefix.SetTableView(PaymentTypePrefix);
                        CreditCardPrefix.LookupMode := true;
                        CreditCardPrefix.weights;
                        CreditCardPrefix.RunModal;
                    end;
                }
                action("G/L Account")
                {
                    Caption = 'G/L Account';
                    Image = GL;
                    ShortCutKey = 'Shift+F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the G/L Account action';

                    trigger OnAction()
                    begin
                        TestField("G/L Account No.");
                        GLAccount.Get("G/L Account No.");
                        PAGE.RunModal(PAGE::"G/L Account Card", GLAccount);
                    end;
                }
            }

            group(Dimensions_Menu)
            {
                Caption = '&Dimensions';
                Image = Setup;
                action(Dimensions)
                {
                    Caption = 'Dimensions-Single';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6014402),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions-Single action';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CustomerEditable := "Account Type" = "Account Type"::Customer;
        GlAccountEditable := "Account Type" = "Account Type"::"G/L Account";
        BankEditable := "Account Type" = "Account Type"::Bank;
    end;

    var
        GLAccount: Record "G/L Account";
        ErrPBSGiftEnable: Label 'Processing type must be gift voucher and via terminal must be set.';
        [InDataSet]
        CustomerEditable: Boolean;
        [InDataSet]
        GlAccountEditable: Boolean;
        [InDataSet]
        BankEditable: Boolean;
        [InDataSet]
        FixedAmountEditable: Boolean;
        [InDataSet]
        QtyperSaleEditable: Boolean;
        [InDataSet]
        PBSCustomerIDEditable: Boolean;
        [InDataSet]
        MinSalesAmountEditable: Boolean;
}