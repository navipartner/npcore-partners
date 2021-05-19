page 6150627 "NPR POS Workshift Checkp. Card"
{
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
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Direct Sales Count"; Rec."Direct Sales Count")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Direct Sales Count field';
                }
                field("Direct Item Returns Line Count"; Rec."Direct Item Returns Line Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Returns Line Count field';
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
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Direct Item Sales (LCY) field';
                    }
                    field("Direct Item Returns (LCY)"; Rec."Direct Item Returns (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Direct Item Returns (LCY) field';
                    }
                }
                group("Cash Movement")
                {
                    Caption = 'Cash Movement';
                    field("Local Currency (LCY)"; Rec."Local Currency (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Local Currency (LCY) field';
                    }
                    field("Foreign Currency (LCY)"; Rec."Foreign Currency (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Foreign Currency (LCY) field';
                    }
                }
                group("Other Payments")
                {
                    Caption = 'Other Payments';
                    field("Debtor Payment (LCY)"; Rec."Debtor Payment (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Debtor Payment (LCY) field';
                    }
                    field("EFT (LCY)"; Rec."EFT (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EFT (LCY) field';
                    }
                    field("GL Payment (LCY)"; Rec."GL Payment (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GL Payment (LCY) field which groups all payments that are handled via an GL Account, such as Payin/Payout transactions.';
                    }
                }
                group(Voucher)
                {
                    field("Redeemed Vouchers (LCY)"; Rec."Redeemed Vouchers (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Redeemed Vouchers (LCY) field';
                    }
                    field("Issued Vouchers (LCY)"; Rec."Issued Vouchers (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issued Vouchers (LCY) field';
                    }
                }
                group(Other)
                {
                    Caption = 'Other';
                    field("Rounding (LCY)"; Rec."Rounding (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Rounding (LCY) field';
                    }
                    field("Bin Transfer Out Amount (LCY)"; Rec."Bin Transfer Out Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bin Transfer Out Amount (LCY) field';
                    }
                    field("Bin Transfer In Amount (LCY)"; Rec."Bin Transfer In Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bin Transfer In Amount (LCY) field';
                    }
                }
                group("Credit Sales")
                {
                    Caption = 'Credit Sales';
                    field("Credit Sales Count"; Rec."Credit Sales Count")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credit Sales Count field';
                    }
                    field("Credit Sales Amount (LCY)"; Rec."Credit Sales Amount (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credit Sales Amount (LCY) field';
                    }
                    field("Credit Net Sales Amount (LCY)"; Rec."Credit Net Sales Amount (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credit Net Sales Amount (LCY) field';
                    }
                    group(Details)
                    {
                        Caption = 'Details';
                        field("Credit Unreal. Sale Amt. (LCY)"; Rec."Credit Unreal. Sale Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Unreal. Sale Amt. (LCY) field';
                        }
                        field("Credit Unreal. Ret. Amt. (LCY)"; Rec."Credit Unreal. Ret. Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Unreal. Ret. Amt. (LCY) field';
                        }
                        field("Credit Real. Sale Amt. (LCY)"; Rec."Credit Real. Sale Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Real. Sale Amt. (LCY) field';
                        }
                        field("Credit Real. Return Amt. (LCY)"; Rec."Credit Real. Return Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Credit Real. Return Amt. (LCY) field';
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
                ApplicationArea = All;
            }
            group(Turnover)
            {
                Caption = 'Turnover';
                field("Turnover (LCY)"; Rec."Turnover (LCY)")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Turnover (LCY) field';
                }
                field("Net Turnover (LCY)"; Rec."Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Turnover (LCY) field';
                }
                field("Net Cost (LCY)"; Rec."Net Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Cost (LCY) field';
                }
                group(Profit)
                {
                    Caption = 'Profit';
                    field("Profit Amount (LCY)"; Rec."Profit Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Profit Amount (LCY) field';
                    }
                    field("Profit %"; Rec."Profit %")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Profit % field';
                    }
                }
                group(Direct)
                {
                    Caption = 'Direct';
                    field("Direct Turnover (LCY)"; Rec."Direct Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Direct Turnover (LCY) field';
                    }
                    field("Direct Net Turnover (LCY)"; Rec."Direct Net Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Direct Net Turnover (LCY) field';
                    }
                }
                group(Credit)
                {
                    Caption = 'Credit';
                    field("Credit Turnover (LCY)"; Rec."Credit Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Credit Turnover (LCY) field';
                    }
                    field("Credit Net Turnover (LCY)"; Rec."Credit Net Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Credit Net Turnover (LCY) field';
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
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Campaign Discount (LCY) field';
                    }
                    field("Mix Discount (LCY)"; Rec."Mix Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Mix Discount (LCY) field';
                    }
                    field("Quantity Discount (LCY)"; Rec."Quantity Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Quantity Discount (LCY) field';
                    }
                    field("Custom Discount (LCY)"; Rec."Custom Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Custom Discount (LCY) field';
                    }
                    field("BOM Discount (LCY)"; Rec."BOM Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the BOM Discount (LCY) field';
                    }
                    field("Customer Discount (LCY)"; Rec."Customer Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Customer Discount (LCY) field';
                    }
                    field("Line Discount (LCY)"; Rec."Line Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Line Discount (LCY) field';
                    }
                }
                group("Dicount Percent")
                {
                    Caption = 'Dicount Percent';
                    field("Campaign Discount %"; Rec."Campaign Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Campaign Discount % field';
                    }
                    field("Mix Discount %"; Rec."Mix Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Mix Discount % field';
                    }
                    field("Quantity Discount %"; Rec."Quantity Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Quantity Discount % field';
                    }
                    field("Custom Discount %"; Rec."Custom Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Custom Discount % field';
                    }
                    field("BOM Discount %"; Rec."BOM Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the BOM Discount % field';
                    }
                    field("Customer Discount %"; Rec."Customer Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Customer Discount % field';
                    }
                    field("Line Discount %"; Rec."Line Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Line Discount % field';
                    }
                }
                group("Discount Total")
                {
                    field("Total Discount (LCY)"; Rec."Total Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Total Discount (LCY) field';
                    }
                    field("Total Discount %"; Rec."Total Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Total Discount % field';
                    }
                }
            }
            part(POSPaymentBins; "NPR POS Unit to Bin Relation")
            {
                Caption = 'Attached Payment Bins';
                Editable = false;
                ShowFilter = false;
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Balance Payment Bin action';

                trigger OnAction()
                begin

                    CreateBinCheckpoint(Rec."POS Unit No.");
                end;
            }
            action("Create X-Report")
            {
                Caption = 'Create X-Report';
                Image = StatisticsDocument;
                ApplicationArea = All;
                ToolTip = 'Executes the Create X-Report action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Tax & VAT Summary action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the X-Report action';

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

    trigger OnAfterGetRecord()
    var
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin

        POSUnittoBinRelation.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        CurrPage.POSPaymentBins.PAGE.SetTableView(POSUnittoBinRelation);
    end;

    trigger OnInit()
    begin
        PageMode := PageMode::VIEW;
    end;

    trigger OnOpenPage()
    begin

        CurrPage.POSPaymentBins.PAGE.SetShowBin();
    end;

    var
        PageMode: Option PRELIMINARY,FINAL,VIEW;
        IsBlindCount: Boolean;

    local procedure CreateBinCheckpoint(POSUnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        POSWorkshiftCheckpoint.CreateBinCheckpoint(Rec."Entry No.");
        Commit();

        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', Rec."Entry No.");
        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.SetCheckpointMode(PageMode);

        PaymentBinCheckpointPage.SetBlindCount(IsBlindCount);

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

