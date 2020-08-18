page 6014430 "Credit Voucher List"
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
    CardPageID = "Credit Voucher";
    Editable = false;
    PageType = List;
    SourceTable = "Credit Voucher";
    SourceTableView = SORTING("Primary Key Length");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Issue Date";"Issue Date")
                {
                }
                field("Issuing POS Entry No";"Issuing POS Entry No")
                {
                }
                field("Issuing POS Sale Line No.";"Issuing POS Sale Line No.")
                {
                }
                field("Issuing POS Unit No.";"Issuing POS Unit No.")
                {
                }
                field(Salesperson;Salesperson)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Amount;Amount)
                {
                }
                field(Status;Status)
                {
                }
                field("Cashed Date";"Cashed Date")
                {
                }
                field("Cashed on Sales Ticket No.";"Cashed on Sales Ticket No.")
                {
                }
                field("Cashed Salesperson";"Cashed Salesperson")
                {
                }
                field("Cashed POS Entry No.";"Cashed POS Entry No.")
                {
                }
                field("Cashed POS Payment Line No.";"Cashed POS Payment Line No.")
                {
                }
                field("Cashed POS Unit No.";"Cashed POS Unit No.")
                {
                }
                field(Reference;Reference)
                {
                }
                field("External Credit Voucher";"External Credit Voucher")
                {
                }
            }
            grid(Control6150629)
            {
                ShowCaption = false;
                field(find;FindNo)
                {

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

                    trigger OnAction()
                    var
                        CreditVoucher: Record "Credit Voucher";
                    begin
                        //-NPR5.29
                        TestField( Status, Status::Open );
                        CreditVoucher.FilterGroup(2);
                        CreditVoucher.SetRange("No.","No.");
                        CreditVoucher.FilterGroup(0);
                        CreditVoucher.PrintCreditVoucher(false,true);
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

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"Credit Voucher A5");
                    //+NPR5.33
                end;
            }
            action("Credit Voucher Report")
            {
                Caption = 'Magento Credit Voucher';
                Image = "Report";
                RunObject = Report "Magento Credit Voucher";
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";

                trigger OnAction()
                begin
                    //-NPR5.33
                    REPORT.Run(REPORT::"Gift Voucher/Credit Voucher");
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

