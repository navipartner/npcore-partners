report 6060105 "Terminal Sales Ticket IV"
{
    // //NPR7.000.000  LS, 05-12-12, CASE150656
    // NPR5.36/TJ /20170927 CASE 286283 Renamed variables with danish specific letters into english letters
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Terminal Sales Ticket IV.rdlc';

    Caption = 'Terminal Sales Ticket IV';
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem("EFT Receipt";"EFT Receipt")
        {
            RequestFilterFields = "Sales Ticket No.";
            column(EjCut;EjCut)
            {
            }
            column(EjForste;NotFirst)
            {
            }
            column(ForsteLinieText;FirstLineText)
            {
            }
            column(Text_CreditCardTransaction;DelChr("EFT Receipt".Text,'=',' '))
            {
            }
            column(NoPrinted_CreditCardTransaction;"EFT Receipt"."No. Printed")
            {
            }
            column(txtCopy;TxtCopy)
            {
            }
            column(Body2;Body2)
            {
            }
            column(Body3;Body3)
            {
            }
            column(Body1;Body1)
            {
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR7
                Body2 := false;
                Body3 := false;
                Body1 := false;
                FirstLineText := '';
                //MESSAGE('F�rste=%1, EjF�rste=%2 ,F�rsteLinieText=%3 ,EjCut=%4',F�rste,EjF�rste,F�rsteLinieText,EjCut);

                //+NPR7

                if IsFirst then begin
                  NotFirst := true;
                  exit;
                end;

                IsFirst := true;
                FirstLineText := "EFT Receipt".Text;
                if FirstLineText = '' then
                  EjCut := true
                else
                  EjCut := false;

                //-NPR7
                Body1 := ((not EjCut) and NotFirst and (FirstLineText = "EFT Receipt".Text));

                Body2 := ((not EjCut) and NotFirst and (FirstLineText = "EFT Receipt".Text) and
                                      ("EFT Receipt"."No. Printed" > 0));

                if Body3Cnt = 0 then
                  Body3 := false
                else
                  Body3 := (not NotFirst and ("EFT Receipt"."No. Printed" > 0) );

                Body3Cnt += 1;
                //+NPR7
            end;

            trigger OnPostDataItem()
            begin
                if FindFirst then repeat
                  "No. Printed" += 1;
                  Modify;
                until Next = 0;
            end;

            trigger OnPreDataItem()
            var
                RetailFormCode: Codeunit "Retail Form Code";
            begin
                Register.Get( RetailFormCode.FetchRegisterNumber );
                Body2 := false;
                Body3 := false;
                Body1 := false;
                Body3Cnt := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        IsFirst: Boolean;
        NotFirst: Boolean;
        FirstLineText: Text[100];
        EjCut: Boolean;
        Register: Record Register;
        TxtCopy: Label '*** COPY ***';
        Body2: Boolean;
        Body3: Boolean;
        Body1: Boolean;
        Body3Cnt: Integer;
}

