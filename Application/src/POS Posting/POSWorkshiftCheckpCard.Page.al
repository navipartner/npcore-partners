page 6150627 "NPR POS Workshift Checkp. Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Workshift Details';
    DataCaptionFields = "POS Unit No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "NPR POS Workshift Checkpoint";

    layout
    {
        area(content)
        {
            group(Balancing)
            {
                Caption = 'Balancing';
                field("Created At"; Rec."Created At")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Sales Count"; Rec."Direct Sales Count")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Direct Sales Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Returns Line Count"; Rec."Direct Item Returns Line Count")
                {
                    ToolTip = 'Specifies the value of the Direct Item Returns Line Count field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Overview)
            {
                Caption = 'Overview';
                group(Sales)
                {
                    Caption = 'Sales';
                    field("Direct Item Sales (LCY)"; Rec."Direct Item Sales (LCY)")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Direct Item Sales (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Direct Item Returns (LCY)"; Rec."Direct Item Returns (LCY)")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Direct Item Returns (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Cash Movement")
                {
                    Caption = 'Cash Movement';
                    field("Local Currency (LCY)"; Rec."Local Currency (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Local Currency (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Foreign Currency (LCY)"; Rec."Foreign Currency (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Foreign Currency (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Other Payments")
                {
                    Caption = 'Other Payments';
                    field("Debtor Payment (LCY)"; Rec."Debtor Payment (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Debtor Payment (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EFT (LCY)"; Rec."EFT (LCY)")
                    {
                        ToolTip = 'Specifies the value of the EFT (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("GL Payment (LCY)"; Rec."GL Payment (LCY)")
                    {
                        ToolTip = 'Specifies the value of the GL Payment (LCY) field which groups all payments that are handled via an GL Account, such as Payin/Payout transactions.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Voucher)
                {
                    field("Redeemed Vouchers (LCY)"; Rec."Redeemed Vouchers (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Redeemed Vouchers (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issued Vouchers (LCY)"; Rec."Issued Vouchers (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Issued Vouchers (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Other)
                {
                    Caption = 'Other';
                    field("Rounding (LCY)"; Rec."Rounding (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Rounding (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bin Transfer Out Amount (LCY)"; Rec."Bin Transfer Out Amount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bin Transfer Out Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bin Transfer In Amount (LCY)"; Rec."Bin Transfer In Amount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bin Transfer In Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Credit Sales")
                {
                    Caption = 'Credit Sales';
                    field("Credit Sales Count"; Rec."Credit Sales Count")
                    {
                        ToolTip = 'Specifies the value of the Credit Sales Count field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Credit Sales Amount (LCY)"; Rec."Credit Sales Amount (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Credit Sales Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Credit Net Sales Amount (LCY)"; Rec."Credit Net Sales Amount (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Credit Net Sales Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Details)
                    {
                        Caption = 'Details';
                        field("Credit Unreal. Sale Amt. (LCY)"; Rec."Credit Unreal. Sale Amt. (LCY)")
                        {
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Unreal. Sale Amt. (LCY) field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Credit Unreal. Ret. Amt. (LCY)"; Rec."Credit Unreal. Ret. Amt. (LCY)")
                        {
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Unreal. Ret. Amt. (LCY) field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Credit Real. Sale Amt. (LCY)"; Rec."Credit Real. Sale Amt. (LCY)")
                        {
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Real. Sale Amt. (LCY) field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Credit Real. Return Amt. (LCY)"; Rec."Credit Real. Return Amt. (LCY)")
                        {
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Real. Return Amt. (LCY) field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
            part("Payment Details"; "NPR POS Paym. Checkp. Subpage")
            {
                Caption = 'Payment Details';
                Editable = false;
                ShowFilter = false;
                SubPageLink = "Workshift Checkpoint Entry No." = FIELD("Entry No.");
                Visible = NOT IsBlindCount;
                ApplicationArea = NPRRetail;
            }
            group(Turnover)
            {
                Caption = 'Turnover';
                Visible = IsTurnoverSectionVisible;
                field("Turnover (LCY)"; Rec."Turnover (LCY)")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Turnover (LCY)"; Rec."Net Turnover (LCY)")
                {
                    ToolTip = 'Specifies the value of the Net Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Cost (LCY)"; Rec."Net Cost (LCY)")
                {
                    ToolTip = 'Specifies the value of the Net Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                group(Profit)
                {
                    Caption = 'Profit';
                    field("Profit Amount (LCY)"; Rec."Profit Amount (LCY)")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Profit Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Profit %"; Rec."Profit %")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Profit % field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Direct)
                {
                    Caption = 'Direct';
                    field("Direct Turnover (LCY)"; Rec."Direct Turnover (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Direct Turnover (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Direct Net Turnover (LCY)"; Rec."Direct Net Turnover (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Direct Net Turnover (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Credit)
                {
                    Caption = 'Credit';
                    field("Credit Turnover (LCY)"; Rec."Credit Turnover (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Credit Turnover (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Credit Net Turnover (LCY)"; Rec."Credit Net Turnover (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Credit Net Turnover (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Discount)
            {
                Caption = 'Discount';
                group("Discount Amounts")
                {
                    Caption = 'Discount Amounts';
                    field("Campaign Discount (LCY)"; Rec."Campaign Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Campaign Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Mix Discount (LCY)"; Rec."Mix Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Mix Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Quantity Discount (LCY)"; Rec."Quantity Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Quantity Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Custom Discount (LCY)"; Rec."Custom Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Custom Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("BOM Discount (LCY)"; Rec."BOM Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the BOM Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Discount (LCY)"; Rec."Customer Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Customer Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Line Discount (LCY)"; Rec."Line Discount (LCY)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Line Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Dicount Percent")
                {
                    Caption = 'Dicount Percent';
                    field("Campaign Discount %"; Rec."Campaign Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Campaign Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Mix Discount %"; Rec."Mix Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Mix Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Quantity Discount %"; Rec."Quantity Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Quantity Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Custom Discount %"; Rec."Custom Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Custom Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("BOM Discount %"; Rec."BOM Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the BOM Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Discount %"; Rec."Customer Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Customer Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Line Discount %"; Rec."Line Discount %")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Line Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Discount Total")
                {
                    field("Total Discount (LCY)"; Rec."Total Discount (LCY)")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Total Discount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Total Discount %"; Rec."Total Discount %")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Total Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(POSPaymentBins; "NPR POS Unit to Bin Relation")
            {
                Caption = 'Attached Payment Bins';
                Editable = false;
                ShowFilter = false;
                SubPageLink = "POS Unit No." = field("POS Unit No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Bin Checkpoint")
            {
                Caption = 'Balance Payment Bin';
                Ellipsis = true;
                Image = Balance;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Balance Payment Bin action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    if PageMode <> PageMode::FINAL then
                        CreateBinCheckpoint();
                    ShowBinCheckpoint();
                end;
            }
            action("Create X-Report")
            {
                Caption = 'Create X-Report';
                Image = StatisticsDocument;

                ToolTip = 'Executes the Create X-Report action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    //POSCheckpointMgr.CreateEndWorkshiftCheckpoint_AuditRoll ("POS Unit No.");
                    //FINDLAST();
                end;
            }
        }
        area(navigation)
        {
            action(TaxVATSummary)
            {
                Caption = 'Tax & VAT Summary';
                Image = VATLedger;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Tax & VAT Summary action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
                    POSTaxCheckpointPage: Page "NPR POS Tax Checkpoint";
                begin
                    POSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', Rec."Entry No.");
                    POSTaxCheckpointPage.SetTableView(POSWorkshiftTaxCheckpoint);
                    POSTaxCheckpointPage.RunModal();
                end;
            }
        }
        area(reporting)
        {
            action("X-Report")
            {
                Caption = 'X-Report';
                Image = PrintVAT;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'Executes the X-Report action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
                    POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                begin

                    POSWorkshiftCheckpoint.Get(Rec."Entry No.");
                    POSWorkshiftCheckpoint.SetRecFilter();

                    ReportSelectionRetail.SetFilter("Report Type", '=%1', ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
                    if (ReportSelectionRetail.FindSet()) then begin
                        repeat
                            ReportSelectionRetail.TestField("Print Template");
                            PrintTemplateMgt.PrintTemplate(ReportSelectionRetail."Print Template", POSWorkshiftCheckpoint, 0);
                        until (ReportSelectionRetail.Next() = 0);
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        POSEoDProfile: Record "NPR POS End of Day Profile";
        POSUnit: Record "NPR POS Unit";
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin
        POSUnittoBinRelation.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        CurrPage.POSPaymentBins.PAGE.SetTableView(POSUnittoBinRelation);
        if not POSUnit.Get(Rec."POS Unit No.") then
            Clear(POSUnit);
        POSUnit.GetProfile(POSEoDProfile);
        IsTurnoverSectionVisible := not POSEoDProfile."Hide Turnover Section";
    end;

    trigger OnInit()
    begin
        PageMode := PageMode::VIEW;
    end;

    trigger OnOpenPage()
    begin
        CurrPage.POSPaymentBins.PAGE.SetShowBin();
        if PageMode = PageMode::FINAL then
            CreateBinCheckpoint();
    end;

    var
        PageMode: Option PRELIMINARY,FINAL,VIEW;
        AutoCountCompleted: Boolean;
        IsBlindCount: Boolean;
        IsTurnoverSectionVisible: Boolean;

    local procedure CreateBinCheckpoint()
    var
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        POSWorkshiftCheckpoint.CreateBinCheckpoint(Rec."Entry No.");
        if PageMode = PageMode::FINAL then begin
            POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", Rec."Entry No.");
            POSPaymentBinCheckpoint.SetRange("Include In Counting", POSPaymentBinCheckpoint."Include In Counting"::YES);
            if POSPaymentBinCheckpoint.IsEmpty then begin
                POSPaymentBinCheckpoint.SetRange("Include In Counting");
                POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::ZREPORT);
                PaymentBinCheckpointPage.AutoCount(POSPaymentBinCheckpoint);
                AutoCountCompleted := true;
            end;
        end;
        Commit();
    end;

    local procedure ShowBinCheckpoint()
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
    begin
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', Rec."Entry No.");
        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.SetCheckpointMode(PageMode);
        PaymentBinCheckpointPage.SetBlindCount(IsBlindCount);
        PaymentBinCheckpointPage.SetAutoCountCompleted(AutoCountCompleted);
        PaymentBinCheckpointPage.RunModal();
    end;

    procedure SetCheckpointMode(Mode: Option PRELIMINARY,FINAL,VIEW)
    begin
        PageMode := PageMode::PRELIMINARY;
        if (Mode = Mode::FINAL) then
            PageMode := PageMode::FINAL;

        if (Mode = Mode::VIEW) then
            PageMode := PageMode::VIEW;
    end;

    procedure SetBlindCount(HideFields: Boolean)
    begin
        IsBlindCount := HideFields;
    end;
}
