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
                    }
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Account Type"; "Account Type")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;

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
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        Editable = CustomerEditable;
                    }
                    field("Bank Acc. No."; "Bank Acc. No.")
                    {
                        ApplicationArea = All;
                        Editable = BankEditable;
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field("Sales Line Text"; "Sales Line Text")
                    {
                        ApplicationArea = All;
                    }
                    field("Zero as Default on Popup"; "Zero as Default on Popup")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150684)
                {
                    ShowCaption = false;
                    field("Search Description"; "Search Description")
                    {
                        ApplicationArea = All;
                    }
                    field(Prefix; Prefix)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Processing Type"; "Processing Type")
                    {
                        ApplicationArea = All;

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
                    }
                    field(Posting; Posting)
                    {
                        ApplicationArea = All;
                    }
                    field("Immediate Posting"; "Immediate Posting")
                    {
                        ApplicationArea = All;
                    }
                    field("Day Clearing Account"; "Day Clearing Account")
                    {
                        ApplicationArea = All;
                    }
                    field(Euro; Euro)
                    {
                        ApplicationArea = All;
                    }
                    field("Is Check"; "Is Check")
                    {
                        ApplicationArea = All;
                    }
                    field("Common Company Clearing"; "Common Company Clearing")
                    {
                        ApplicationArea = All;
                    }
                    field("Auto End Sale"; "Auto End Sale")
                    {
                        ApplicationArea = All;
                    }
                    field("Forced Amount"; "Forced Amount")
                    {
                        ApplicationArea = All;
                    }
                    field("Match Sales Amount"; "Match Sales Amount")
                    {
                        ApplicationArea = All;
                    }
                    field("Reverse Unrealized VAT"; "Reverse Unrealized VAT")
                    {
                        ApplicationArea = All;
                    }
                    field(Control6150645; '')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field("Open Drawer"; "Open Drawer")
                    {
                        ApplicationArea = All;
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
                }
                field("Reference Incoming"; "Reference Incoming")
                {
                    ApplicationArea = All;
                }
                field("Fixed Rate"; "Fixed Rate")
                {
                    ApplicationArea = All;
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Receipt - Post it Now"; "Receipt - Post it Now")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Maximum Amount"; "Maximum Amount")
                {
                    ApplicationArea = All;
                }
                field("Minimum Amount"; "Minimum Amount")
                {
                    ApplicationArea = All;
                }
                field("No Min Amount on Web Orders"; "No Min Amount on Web Orders")
                {
                    ApplicationArea = All;
                }
                field("Allow Refund"; "Allow Refund")
                {
                    ApplicationArea = All;
                }
                field("EFT Surcharge Service Item No."; "EFT Surcharge Service Item No.")
                {
                    ApplicationArea = All;
                }
                field("EFT Tip Service Item No."; "EFT Tip Service Item No.")
                {
                    ApplicationArea = All;
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
                    }
                    field("On Sale End Codeunit"; "On Sale End Codeunit")
                    {
                        ApplicationArea = All;
                    }
                    field("Post Processing Codeunit"; "Post Processing Codeunit")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Balancing)
            {
                field("To be Balanced"; "To be Balanced")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Balancing Type"; "Balancing Type")
                {
                    ApplicationArea = All;
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