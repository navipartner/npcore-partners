page 6014430 "NPR Credit Voucher List"
{
    // 
    // 001 - Henrik Ohm
    // udenReserveret(true/false) tilf¢jet, så ikke bruger reserv tilg.beviser
    // 
    // //-NPR3.0b ved Nikolai Pedersen
    //   find tilf¢jet
    // NPR5.29/TS/20161220  CASE 255679 Added COPY of Credit Voucher
    // NPR5.33/TS  /20170619  CASE 281210 Adding Report Credit Voucher
    // NPR5.33/JLK /20170620  CASE 281210 Added Credit Voucher Reports
    // NPR5.35/TJ  /20170809 CASE 286283 Renamed variables/function into english and into proper naming terminology
    // NPR5.38/BR  /20180119  CASE 302766 Added fields related to POS Entry

    Caption = 'Credit Voucher List';
    CardPageID = "NPR Credit Voucher";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Credit Voucher";
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
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
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed Date field';
                }
                field("Cashed on Sales Ticket No."; "Cashed on Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed on Sales Ticket No. field';
                }
                field("Cashed Salesperson"; "Cashed Salesperson")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed Salesperson field';
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
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("External Credit Voucher"; "External Credit Voucher")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Gift Voucher field';
                }
            }
            grid(Control6150629)
            {
                ShowCaption = false;
                field("find"; FindNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FindNo field';

                    trigger OnValidate()
                    begin
                        AfterValidate;
                    end;
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
                action("<Action33>")
                {
                    Caption = 'Copy';
                    Image = PrintVoucher;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy action';

                    trigger OnAction()
                    var
                        CreditVoucher: Record "NPR Credit Voucher";
                    begin
                        //-NPR5.29
                        TestField(Status, Status::Open);
                        CreditVoucher.FilterGroup(2);
                        CreditVoucher.SetRange("No.", "No.");
                        CreditVoucher.FilterGroup(0);
                        CreditVoucher.PrintCreditVoucher(false, true);
                        //+NPR5.29
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Credit Voucher A5")
            {
                Caption = 'Credit Voucher A5';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Credit Voucher A5 action';

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"NPR Credit Voucher A5");
                    //+NPR5.33
                end;
            }
            action("Credit Voucher Report")
            {
                Caption = 'Magento Credit Voucher';
                Image = "Report";
                RunObject = Report "NPR Magento Credit Voucher";
                ApplicationArea = All;
                ToolTip = 'Executes the Magento Credit Voucher action';
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
        }
    }

    trigger OnOpenPage()
    begin

        //-NPR3.0b
        //CurrPage.find.ACTIVATE;
        //+NPR3.0b
    end;

    var
        FindNo: Code[20];
        TxtFind: Label 'Number %1 is not found';

    procedure AfterValidate()
    begin
        //-NPR3.0b
        if FindNo <> '' then begin
            SetFilter("No.", '=%1', FindNo);
            if not Find('-') then begin
                Error(TxtFind, FindNo);
            end;
            CurrPage.Update(false);
        end;
        //+NPR3.0b
    end;
}

