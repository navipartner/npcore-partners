page 6150627 "NPR POS Workshift Checkp. Card"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.37/TSA /20171026 CASE 282251 Removing some old debug code that is interfering
    // NPR5.38/TSA /20171110 CASE 295549 Removing more old debug code that is interfering
    // NPR5.40/TSA /20180228 CASE 282251 Add Tax Checkpoint button
    // NPR5.40/TSA /20180228 CASE 306581 Add X-Report Printing
    // NPR5.40/TSA /20180228 CASE 306581 Add NP Retail Setup check for new old source for bin entries
    // NPR5.40/TSA /20180308 CASE 306581 Added function for Checkpoint mode (Preliminart | Final)
    // NPR5.45/TSA /20180720 CASE 322769 Refactoring
    // NPR5.46/TSA /20180913 CASE 328326 Adding a view mode (non editable) of the counting
    // NPR5.48/TSA /20190111 CASE 339571 Changed layout due to new fields being added
    // NPR5.49/TSA /20190314 CASE 348458 Forced blind count
    // NPR5.50/TSA /20190424 CASE 352319 Removed "Delete" option

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
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Direct Sales Count"; "Direct Sales Count")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Direct Item Returns Line Count"; "Direct Item Returns Line Count")
                {
                    ApplicationArea = All;
                }
            }
            group(Overview)
            {
                Caption = 'Overview';
                group(Sales)
                {
                    Caption = 'Sales';
                    field("Direct Item Sales (LCY)"; "Direct Item Sales (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Direct Item Returns (LCY)"; "Direct Item Returns (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }
                group("Cash Movement")
                {
                    Caption = 'Cash Movement';
                    field("Local Currency (LCY)"; "Local Currency (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("Foreign Currency (LCY)"; "Foreign Currency (LCY)")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Other Payments")
                {
                    Caption = 'Other Payments';
                    field("Debtor Payment (LCY)"; "Debtor Payment (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("EFT (LCY)"; "EFT (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("GL Payment (LCY)"; "GL Payment (LCY)")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Voucher)
                {
                    field("Redeemed Vouchers (LCY)"; "Redeemed Vouchers (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("Issued Vouchers (LCY)"; "Issued Vouchers (LCY)")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Other)
                {
                    Caption = 'Other';
                    field("Rounding (LCY)"; "Rounding (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Bin Transfer Out Amount (LCY)"; "Bin Transfer Out Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Bin Transfer In Amount (LCY)"; "Bin Transfer In Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group("Credit Sales")
                {
                    Caption = 'Credit Sales';
                    field("Credit Sales Count"; "Credit Sales Count")
                    {
                        ApplicationArea = All;
                    }
                    field("Credit Sales Amount (LCY)"; "Credit Sales Amount (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("Credit Net Sales Amount (LCY)"; "Credit Net Sales Amount (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    group(Details)
                    {
                        Caption = 'Details';
                        field("Credit Unreal. Sale Amt. (LCY)"; "Credit Unreal. Sale Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                        field("Credit Unreal. Ret. Amt. (LCY)"; "Credit Unreal. Ret. Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                        field("Credit Real. Sale Amt. (LCY)"; "Credit Real. Sale Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                        field("Credit Real. Return Amt. (LCY)"; "Credit Real. Return Amt. (LCY)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
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
                ApplicationArea=All;
            }
            group(Turnover)
            {
                Caption = 'Turnover';
                field("Turnover (LCY)"; "Turnover (LCY)")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Net Turnover (LCY)"; "Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Net Cost (LCY)"; "Net Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                group(Profit)
                {
                    Caption = 'Profit';
                    field("Profit Amount (LCY)"; "Profit Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Profit %"; "Profit %")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }
                group(Direct)
                {
                    Caption = 'Direct';
                    field("Direct Turnover (LCY)"; "Direct Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Direct Net Turnover (LCY)"; "Direct Net Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Credit)
                {
                    Caption = 'Credit';
                    field("Credit Turnover (LCY)"; "Credit Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Credit Net Turnover (LCY)"; "Credit Net Turnover (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
            }
            group(Discount)
            {
                Caption = 'Discount';
                group("Discount Amounts")
                {
                    Caption = 'Discount Amounts';
                    field("Campaign Discount (LCY)"; "Campaign Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Mix Discount (LCY)"; "Mix Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Quantity Discount (LCY)"; "Quantity Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Custom Discount (LCY)"; "Custom Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("BOM Discount (LCY)"; "BOM Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Customer Discount (LCY)"; "Customer Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Line Discount (LCY)"; "Line Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group("Dicount Percent")
                {
                    Caption = 'Dicount Percent';
                    field("Campaign Discount %"; "Campaign Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Mix Discount %"; "Mix Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Quantity Discount %"; "Quantity Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Custom Discount %"; "Custom Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("BOM Discount %"; "BOM Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Customer Discount %"; "Customer Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Line Discount %"; "Line Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group("Discount Total")
                {
                    field("Total Discount (LCY)"; "Total Discount (LCY)")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Total Discount %"; "Total Discount %")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }
            }
            part(POSPaymentBins; "NPR POS Unit to Bin Relation")
            {
                Caption = 'Attached Payment Bins';
                Editable = false;
                ShowFilter = false;
                ApplicationArea=All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin

                    CreateBinCheckpoint("POS Unit No.");
                end;
            }
            action("Create X-Report")
            {
                Caption = 'Create X-Report';
                Image = StatisticsDocument;
                ApplicationArea=All;

                trigger OnAction()
                var
                    POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
                    POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                    POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
                    POSCreateEntry: Codeunit "NPR POS Create Entry";
                    CheckpointEntryNo: Integer;
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
                PromotedCategory = Process;
                ApplicationArea=All;

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
                PromotedCategory = "Report";
                ApplicationArea=All;

                trigger OnAction()
                var
                    PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
                    POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                begin

                    POSWorkshiftCheckpoint.Get("Entry No.");
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
        //-NPR5.46 [328326]
        PageMode := PageMode::VIEW;
        //+NPR5.46 [328326]
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
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin

        //-NPR5.45 [306157]
        POSWorkshiftCheckpoint.CreateBinCheckpoint(Rec."Entry No.");
        //+NPR5.45 [306157]
        Commit;

        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', Rec."Entry No.");
        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.SetCheckpointMode(PageMode);

        //-NPR5.49 [348458]
        PaymentBinCheckpointPage.SetBlindCount(IsBlindCount);
        //+NPR5.49 [348458]

        PaymentBinCheckpointPage.RunModal();
    end;

    procedure SetCheckpointMode(Mode: Option PRELIMINARY,FINAL,VIEW)
    begin

        PageMode := PageMode::PRELIMINARY;
        if (Mode = Mode::FINAL) then
            PageMode := PageMode::FINAL;

        //-NPR5.46 [328326]
        if (Mode = Mode::VIEW) then
            PageMode := PageMode::VIEW;
        //+NPR5.46 [328326]
    end;

    procedure SetBlindCount(HideFields: Boolean)
    begin

        //-NPR5.49 [348458]
        IsBlindCount := HideFields;
        //+NPR5.49 [348458]
    end;
}

