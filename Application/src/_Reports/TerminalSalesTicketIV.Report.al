report 6060105 "NPR Terminal Sales Ticket IV"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Terminal Sales Ticket IV.rdlc';
    Caption = 'Terminal Sales Ticket IV';
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem("EFT Receipt"; "NPR EFT Receipt")
        {
            RequestFilterFields = "Sales Ticket No.";
            column(EjCut; EjCut)
            {
            }
            column(EjForste; NotFirst)
            {
            }
            column(ForsteLinieText; FirstLineText)
            {
            }
            column(Text_CreditCardTransaction; DelChr("EFT Receipt".Text, '=', ' '))
            {
            }
            column(NoPrinted_CreditCardTransaction; "EFT Receipt"."No. Printed")
            {
            }
            column(txtCopy; TxtCopy)
            {
            }
            column(Body2; Body2)
            {
            }
            column(Body3; Body3)
            {
            }
            column(Body1; Body1)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Body2 := false;
                Body3 := false;
                Body1 := false;
                FirstLineText := '';
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

                Body1 := ((not EjCut) and NotFirst and (FirstLineText = "EFT Receipt".Text));

                Body2 := ((not EjCut) and NotFirst and (FirstLineText = "EFT Receipt".Text) and
                                      ("EFT Receipt"."No. Printed" > 0));

                if Body3Cnt = 0 then
                    Body3 := false
                else
                    Body3 := (not NotFirst and ("EFT Receipt"."No. Printed" > 0));

                Body3Cnt += 1;
            end;

            trigger OnPostDataItem()
            begin
                if FindFirst then
                    repeat
                        "No. Printed" += 1;
                        Modify;
                    until Next = 0;
            end;

            trigger OnPreDataItem()
            var
                RetailFormCode: Codeunit "NPR Retail Form Code";
            begin
                Register.Get(RetailFormCode.FetchRegisterNumber);
                Body2 := false;
                Body3 := false;
                Body1 := false;
                Body3Cnt := 0;
            end;
        }
    }

    var
        Register: Record "NPR Register";
        Body1: Boolean;
        Body2: Boolean;
        Body3: Boolean;
        EjCut: Boolean;
        IsFirst: Boolean;
        NotFirst: Boolean;
        Body3Cnt: Integer;
        TxtCopy: Label '*** COPY ***';
        FirstLineText: Text[100];
}

