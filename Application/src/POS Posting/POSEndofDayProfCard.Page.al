page 6150752 "NPR POS End of Day Prof. Card"
{
    Extensible = False;
    Caption = 'POS End of Day/Bin Tr. Profile Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/eod/balance_config/';
    PageType = Card;
    SourceTable = "NPR POS End of Day Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique code for the profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the short description of profile.';
                    ApplicationArea = NPRRetail;
                }

                field("End of Day Frequency"; Rec."End of Day Frequency")
                {
                    ToolTip = 'Specifies how often the end of day process is required. There are two available options: Daily (End of Day will be performed every day) or Never (End of Day will never be performed).';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Type"; Rec."End of Day Type")
                {
                    ToolTip = 'Specifies the type of the end-of-day process. Master&Slave (there are master and slave POS units, the master unit is a unit in which balancing is performed for slave POS units) or Individual (every POS unit has to be balanced individually).';
                    ApplicationArea = NPRRetail;
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {
                    ToolTip = 'Specifies the number of the POS unit in which the balancing is performed if the End of Day Type is Master&Slave.';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {
                    ToolTip = 'There are two available options: Summary+Balancing (when running the Z-report the page with summary will be opened first, followed by the balancing page) and Only Balancing (the balancing page is opened immediately).';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report UI"; Rec."X-Report UI")
                {
                    ToolTip = 'There are two available options: Summary+Balancing (when running the X-report the page with summary will be opened first, followed by the balancing page) and Only Balancing (the balancing page is opened immediately).';
                    ApplicationArea = NPRRetail;
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {
                    ToolTip = 'You can choose between either Print or No print.';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Profile"; Rec."SMS Profile")
                {
                    ToolTip = 'Specifies the SMS template which will be used for sending an SMS after the balancing is done.';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {
                    ToolTip = 'Specifies the number series used for creating the Document No. in the POS entry for entries created from running the Z report.';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {
                    ToolTip = 'Specifies the number series used for creating the Document No. in the POS entry for entries created from running the X report.';
                    ApplicationArea = NPRRetail;
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {
                    ToolTip = 'If this field is checked on the balancing page the amount won''t be shown in the system.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {
                    ToolTip = 'Make all payment methods visible on the balancing page even if they haven''t been used.';
                    ApplicationArea = NPRRetail;
                }
                field("Hide Turnover Section"; Rec."Hide Turnover Section")
                {
                    ToolTip = 'Hide the turnover section on the summary page.';
                    ApplicationArea = NPRRetail;
                }
                field(HideDifferenceField; Rec.DisableDifferenceField)
                {
                    ToolTip = 'Specifies whether editing of the Difference field is allowed on the counting page.';
                    ApplicationArea = NPRRetail;
                }
                field("Bank Deposit Ref. Asgmt."; Rec."Bank Deposit Ref. Asgmt.")
                {
                    ToolTip = 'Specifies the method used for reference number assignment for "Bank Deposit" amounts posted in end-of-day transactions.';
                    ApplicationArea = NPRRetail;
                    Visible = BackendGeneratedBinReferences;
                }
                group(BankDep_Subgroup)
                {
                    ShowCaption = false;
                    Visible = Rec."Bank Deposit Ref. Asgmt." = Rec."Bank Deposit Ref. Asgmt."::NoSeries;
                    field("Bank Deposit Ref. Nos."; Rec."Bank Deposit Ref. Nos.")
                    {
                        ToolTip = 'Specifies the number series used for reference number assignment for "Bank Deposit" amounts posted in end-of-day transactions.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Move to Bin Ref. Asgmt."; Rec."Move to Bin Ref. Asgmt.")
                {
                    ToolTip = 'Specifies the method used for reference number assignment for "Move to Bin" amounts posted in end-of-day transactions.';
                    ApplicationArea = NPRRetail;
                    Visible = BackendGeneratedBinReferences;
                }
                group(MoveToBin_Subgroup)
                {
                    ShowCaption = false;
                    Visible = Rec."Move to Bin Ref. Asgmt." = Rec."Move to Bin Ref. Asgmt."::NoSeries;
                    field("Move to Bin Ref. Nos."; Rec."Move to Bin Ref. Nos.")
                    {
                        ToolTip = 'Specifies the number series used for reference number assignment for "Move to Bin" amounts posted in end-of-day transactions.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(RequireDenominations)
                {
                    Caption = 'Require Denominations';
                    field("Require Denomin.(Counted Amt.)"; Rec."Require Denomin.(Counted Amt.)")
                    {
                        Caption = 'Counted Amount';
                        ToolTip = 'Specifies whether system will require to specify denominations for the Counted Amount on the counting page. If disabled, system will allow both denominations and direct edit of the amount.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Require Denomin.(Bank Deposit)"; Rec."Require Denomin.(Bank Deposit)")
                    {
                        Caption = 'Bank Deposit Amount';
                        ToolTip = 'Specifies whether system will require to specify denominations for the Bank Deposit Amount on the counting page. If disabled, system will allow both denominations and direct edit of the amount.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Require Denomin. (Move to Bin)"; Rec."Require Denomin. (Move to Bin)")
                    {
                        Caption = 'Move to Bin Amount';
                        ToolTip = 'Specifies whether system will require to specify denominations for the Move to Bin Amount on the counting page. If disabled, system will allow both denominations and direct edit of the amount.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(BinTransfer)
            {
                Caption = 'Bin Transfer';
                Visible = BinTransferVisible;
                group(BinTransferOUT)
                {
                    Caption = 'Transfer OUT';
                    field("BT OUT: Bank Dep. Ref. Asgmt."; Rec."BT OUT: Bank Dep. Ref. Asgmt.")
                    {
                        Caption = 'Bank Deposit Ref. Asgmt. Method';
                        ToolTip = 'Specifies the method used for reference number assignment for "Bank Deposit" amounts posted in Bin TransferOUT transactions.';
                        ApplicationArea = NPRRetail;
                        Visible = BackendGeneratedBinReferences;
                    }
                    group(BTOUT_BankDep_Subgroup)
                    {
                        ShowCaption = false;
                        Visible = Rec."BT OUT: Bank Dep. Ref. Asgmt." = Rec."BT OUT: Bank Dep. Ref. Asgmt."::NoSeries;
                        field("BT OUT: Bank Deposit Ref. Nos."; Rec."BT OUT: Bank Deposit Ref. Nos.")
                        {
                            Caption = 'Bank Deposit Ref. Nos.';
                            ToolTip = 'Specifies the number series used for reference number assignment for "Bank Deposit" amounts posted in Bin TransferOUT transactions.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("BT OUT: Move to Bin Ref.Asgmt."; Rec."BT OUT: Move to Bin Ref.Asgmt.")
                    {
                        Caption = 'Move to Bin Ref. Asgmt. Method';
                        ToolTip = 'Specifies the method used for reference number assignment for "Move to Bin" amounts posted in Bin TransferOUT transactions.';
                        ApplicationArea = NPRRetail;
                        Visible = BackendGeneratedBinReferences;
                    }
                    group(BTOUT_MoveToBin_Subgroup)
                    {
                        ShowCaption = false;
                        Visible = Rec."BT OUT: Move to Bin Ref.Asgmt." = Rec."BT OUT: Move to Bin Ref.Asgmt."::NoSeries;
                        field("BT OUT: Move to Bin Ref. Nos."; Rec."BT OUT: Move to Bin Ref. Nos.")
                        {
                            Caption = 'Move to Bin Ref. Nos.';
                            ToolTip = 'Specifies the number series used for reference number assignment for "Move to Bin" amounts posted in Bin TransferOUT transactions.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(BinTransferIN)
                {
                    Caption = 'Transfer IN';
                    field("Bin Transfer: Require Journal"; Rec."Bin Transfer: Require Journal")
                    {
                        Caption = 'Require Journal for Trans. INs';
                        ToolTip = 'Specifies if system will require a prestaged bin transfer journal line for a POS user to select from when performing a Bin TransferIN transaction.';
                        ApplicationArea = NPRRetail;
                    }
                    field("BT IN: Tr.from Bank Ref.Asgmt."; Rec."BT IN: Tr.from Bank Ref.Asgmt.")
                    {
                        Caption = 'Tr. from Bank Ref. Asgmt. Method';
                        ToolTip = 'Specifies the method used for reference number assignment for "Transfer from Bank" amounts posted in Bin TransferIN transactions.';
                        ApplicationArea = NPRRetail;
                        Visible = BackendGeneratedBinReferences;
                    }
                    group(BTIN_TrFromBank_Subgroup)
                    {
                        ShowCaption = false;
                        Visible = Rec."BT IN: Tr.from Bank Ref.Asgmt." = Rec."BT IN: Tr.from Bank Ref.Asgmt."::NoSeries;
                        field("BT IN: Tr.from Bank Ref. Nos."; Rec."BT IN: Tr.from Bank Ref. Nos.")
                        {
                            Caption = 'Transf. from Bank Ref. Nos.';
                            ToolTip = 'Specifies the number series used for reference number assignment for "Transfer from Bank" amounts posted in Bin TransferIN transactions.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("BT IN: Move fr. Bin Ref.Asgmt."; Rec."BT IN: Move fr. Bin Ref.Asgmt.")
                    {
                        Caption = 'Move from Bin Ref. Asgmt. Method';
                        ToolTip = 'Specifies the method used for reference number assignment for "Move from Bin" amounts posted in Bin TransferIN transactions.';
                        ApplicationArea = NPRRetail;
                        Visible = BackendGeneratedBinReferences;
                    }
                    group(BTIN_MoveFromBin_Subgroup)
                    {
                        ShowCaption = false;
                        Visible = Rec."BT IN: Move fr. Bin Ref.Asgmt." = Rec."BT IN: Move fr. Bin Ref.Asgmt."::NoSeries;
                        field("BT IN: Move fr. Bin Ref. Nos."; Rec."BT IN: Move fr. Bin Ref. Nos.")
                        {
                            Caption = 'Move from Bin Ref. Nos.';
                            ToolTip = 'Specifies the number series used for reference number assignment for "Move from Bin" amounts posted in Bin TransferIN transactions.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
    begin
        BinTransferVisible := FeatureFlagsManagement.IsEnabled(POSActionBinTransferB.NewBinTransferFeatureFlag());
        BackendGeneratedBinReferences := FeatureFlagsManagement.IsEnabled('backendGeneratedBinReferences');
    end;

    var
        BinTransferVisible: Boolean;
        BackendGeneratedBinReferences: Boolean;
}
