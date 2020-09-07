page 6014433 "NPR Payment Type - Card"
{
    // NPR4.10/JDH/20150609 CASE 215893 Added Location code so its possible to set up payments per location
    // NPR4.12/TSA/20150630 CASE 217683 - Auto-Merge problem, Removed empty/blank global variable
    // NPR5.00/NPKNAV/20160113  CASE 226725 NP Retail 2016
    // NPR5.25/TTH/20160718 CASE 238859 Added Swipp Fields
    // NPR5.27/TSA/20160928 CASE 253683 removed field "Amount in Audit Roll" from page. visible false seems not to be work
    // NPR5.30/TJ /20170213 CASE 264909 Removed Swipp group with controls
    // NPR5.35/TJ /20170816 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                  Removed unused variables
    // NPR5.37.03/MMV /20171130 CASE 296642 Added field "Rounding Direction".
    // NPR5.38/MMV /20180108 CASE 300957 Rolled back 5.37.03
    // NPR5.44/NPKNAV/20180727  CASE 323064 Transport NPR5.44 - 27 July 2018
    // NPR5.46/MMV /20180919 CASE Removed deprecated fields
    // NPR5.47/TS  /20181022 CASE 309123 Removed unused fields
    // NPR5.50/TSA /20190530 CASE 354832 Added field 100 - "Reverse Unrealized VAT"
    // NPR5.51/MMV /20190628 CASE 359385 Removed PBS & Kvittering.dk fields from page.
    // NPR5.51/TJ  /20190628 CASE 359385 Added field 110 "Open Drawer"
    // NPR5.51/JAKUBV/20190903  CASE 357069 Transport NPR5.51 - 3 September 2019
    // NPR5.52/JAKUBV/20191022  CASE 373294 Transport NPR5.52 - 22 October 2019
    // NPR5.54/MMV /20200225 CASE 364340 Added tip & surcharge fields.
    //                                   Removed legacy fields.
    // NPR5.55/ALPO/20200623 CASE 410991 Zero as default payment amount on popup window for specific payment types
    // NPR5.55/TJ  /20200430 CASE 399242 Removed Dimensions action (with entire RelatedInformation group) as it is no longer supported for this table

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
                            //CurrForm.Customer.EDITABLE := "Account Type" = "Account Type"::Customer;
                            //CurrForm."G/L Account".EDITABLE := "Account Type" = "Account Type"::"G/L Account";
                            //CurrForm.Bank.EDITABLE := "Account Type" = "Account Type"::Bank;
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
                            //CurrForm.FixedAmount.EDITABLE("Processing Type" = "Processing Type"::"Gift Voucher");
                            //CurrForm.QtyPerSale.EDITABLE("Processing Type" = "Processing Type"::"Gift Voucher");
                            //CurrForm.MinSalesAmount.EDITABLE("Processing Type" = "Processing Type"::"Gift Voucher");
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
                    ApplicationArea=All;

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
                        //PræfixForm.Prefix;
                        CreditCardPrefix.ShowPrefix;
                        CreditCardPrefix.RunModal;
                    end;
                }
                action("Coin Types")
                {
                    Caption = 'Coin Types';
                    Image = Currency;
                    ShortCutKey = 'Ctrl+F5';
                    ApplicationArea=All;

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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        TestField("G/L Account No.");
                        GLAccount.Get("G/L Account No.");
                        //FORM.RUNMODAL(FORM::"G/L Account Card",Finanskontorec);
                        PAGE.RunModal(PAGE::"G/L Account Card", GLAccount);
                    end;
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

