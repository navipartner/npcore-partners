page 6014431 "NPR Gift Voucher List"
{
    // //-NPR3.0c ved Nikolai Pedersen
    //   tilf¢jet find, active ved start
    // NPR4.14/TSA /20150731  CASE 219602 - Cleaned CRLF from NOR Caption on "Offline - No." field
    // NPR4.14/TSA /20150731  CASE 219602 - Changes to Comply to Critical Guidelines
    // NPR5.29/TS  /20161220  CASE 255679 Added COPY of Gift Voucher
    // MAG2.01/TR  /20160811  CASE 247244 Added action SendAsPDF
    // NPR5.33/JLK /20170620  CASE 281211 Added Gift Voucher Reports
    // NPR5.35/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    // NPR5.38/BR  /20180119  CASE 302766 Added fields related to POS Entry
    // NPR5.45/MHA /20180828  CASE 326089 Changed page to be Non-Editable

    Caption = 'Gift Voucher List';
    CardPageID = "NPR Gift Voucher";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Gift Voucher";
    SourceTableView = SORTING("Primary Key Length");
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Offline - No."; "Offline - No.")
                {
                    ApplicationArea = All;
                    Caption = 'Offline-No.';
                    ToolTip = 'Specifies the value of the Offline-No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field("Issuing POS Entry No"; "Issuing POS Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issuing POS Entry No field';
                }
                field("Issuing POS Sale Line No."; "Issuing POS Sale Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issuing POS Sale Line No. field';
                }
                field("Issuing POS Unit No."; "Issuing POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issuing POS Unit No. field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cashed Date field';
                }
                field("Cashed Salesperson"; "Cashed Salesperson")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cashed Salesperson field';
                }
                field("Cashed on Sales Ticket No."; "Cashed on Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cashed on Sales Ticket No. field';
                }
                field("Cashed in Store"; "Cashed in Store")
                {
                    ApplicationArea = All;
                    Caption = '<Cashed in Store';
                    Editable = false;
                    ToolTip = 'Specifies the value of the <Cashed in Store field';
                }
                field("Cashed POS Entry No."; "Cashed POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed POS Entry No. field';
                }
                field("Cashed POS Payment Line No."; "Cashed POS Payment Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed POS Payment Line No. field';
                }
                field("Cashed POS Unit No."; "Cashed POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed POS Unit No. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Cash In")
            {
                Caption = 'Cash In';
                Image = CashFlow;
                ApplicationArea = All;
                ToolTip = 'Executes the Cash In action';

                trigger OnAction()
                begin
                    RedeemF4;
                end;
            }
            group("&Print")
            {
                Caption = '&Print';
                action(Copy)
                {
                    Caption = 'Copy';
                    Image = PrintVoucher;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy action';

                    trigger OnAction()
                    var
                        GiftVoucher: Record "NPR Gift Voucher";
                    begin
                        //-NPR5.29
                        TestField(Status, Status::Open);
                        GiftVoucher.FilterGroup(2);
                        GiftVoucher.SetRange("No.", "No.");
                        GiftVoucher.FilterGroup(0);
                        GiftVoucher.PrintGiftVoucher(false, true);
                        //+NPR5.29
                    end;
                }
            }
            action(SendAsPDF)
            {
                Caption = 'Send as PDF';
                Image = SendEmailPDF;
                ApplicationArea = All;
                ToolTip = 'Executes the Send as PDF action';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    MagentoGiftVoucherMgt: Codeunit "NPR Magento Gift Voucher Mgt.";
                begin
                    //-MAG2.01
                    if not Customer.Get("Customer No.") then
                        exit;
                    if Customer."E-Mail" <> '' then
                        MagentoGiftVoucherMgt.EmailGiftVoucher(Rec, Customer."E-Mail");
                    //+MAG2.01
                end;
            }
        }
        area(reporting)
        {
            action("Gift Voucher A5")
            {
                Caption = 'Gift Voucher A5';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Voucher A5 action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Gift Voucher A5");
                    //+NPR5.33
                end;
            }
            action("Gift Voucher A5 Right")
            {
                Caption = 'Gift Voucher A5 Right';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Voucher A5 Right action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Gift Voucher A5 Right");
                    //+NPR5.33
                end;
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Voucher/Credit Voucher action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Gift/Credit Voucher");
                    //+NPR5.33
                end;
            }
            action("Cashed Gift Vouchers")
            {
                Caption = 'Cashed Gift Vouchers';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Cashed Gift Vouchers action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Cashed Gift Vouchers", true, true, Rec);
                    //+NPR5.33
                end;
            }
            action("Magento Gift Voucher")
            {
                Caption = 'Magento Gift Voucher';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Magento Gift Voucher action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Magento Gift Voucher");
                    //+NPR5.33
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-NPR3.Oc
        //CurrPage.Find.ACTIVATE;
        //+NPR3.0c
    end;

    var
        FindNo: Code[20];
        RetailSetup: Record "NPR Retail Setup";
        txtfind: Label 'Number %1 is not found';

    procedure AfterValidate()
    var
        GiftVoucher: Record "NPR Gift Voucher";
        RecIComm: Record "NPR I-Comm";
        GiftVoucher2: Record "NPR Gift Voucher";
    begin

        //-NPR3.0c
        RetailSetup.Get;

        if FindNo <> '' then begin
            SetFilter("No.", '=%1', FindNo);
            if not Find('-') then begin
                if RetailSetup."Use I-Comm" then begin
                    RecIComm.Get;
                    if RecIComm."Company - Clearing" <> '' then begin
                        GiftVoucher.ChangeCompany(RecIComm."Company - Clearing");
                        GiftVoucher.SetFilter("No.", '=%1', FindNo);
                        if not GiftVoucher.Find('-') then
                            Error(txtfind, FindNo)
                        else begin
                            GiftVoucher2.Init;
                            GiftVoucher2.Copy(GiftVoucher);
                            GiftVoucher2."External Gift Voucher" := true;
                            GiftVoucher2."Issuing Register No." := GiftVoucher."Register No.";
                            GiftVoucher2."Issuing Sales Ticket No." := GiftVoucher."Sales Ticket No.";
                            GiftVoucher2.Insert;
                        end;
                    end;
                end else
                    Error(txtfind, FindNo);
            end;
            CurrPage.Update(false);
        end;
        //+NPR3.0c
    end;
}

