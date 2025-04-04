page 6184905 "NPR APIV1 - Ext. POS EFT Line"
{
    Extensible = False;
    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1ExternalPOSSaleEftLine';
    DelayedInsert = true;
    EntityName = 'externalPosEftLine';
    EntitySetName = 'externalPosEftLines';
    PageType = API;
    SourceTable = "NPR External POS Sale Eft Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(externalPosSaleEntry; Rec."External POS Sale Entry No.")
                {
                    Caption = 'externalPosSaleEntry';
                    Editable = false;
                }
                field(externalPosSaleLineNo; Rec."External Pos SaleLine No")
                {
                    Caption = 'externalPosSaleLineNo';
                    Editable = false;
                }
                field(eftType; Rec."EFT Type")
                {
                    Caption = 'eftType';
                }
                field(eftBase64Data; EftBase64Data)
                {
                    Caption = 'eftBase64Data';
                }
                field(processingType; Rec."Processing Type")
                {
                    Caption = 'processingType';
                }
                field(eftReference; Rec."EFT Reference")
                {
                    Caption = 'eftReference';
                }
            }
        }
    }

    var
        EftBase64Data: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        outS: OutStream;
    begin
        if (EftBase64Data <> '') then begin
            Rec.Base64Data.CreateOutStream(outS, TextEncoding::UTF8);
            outS.WriteText(EftBase64Data);
        end;
    end;

    trigger OnAfterGetRecord()
    var
        InStr: InStream;
        buffer: Text;
    begin
        Clear(EftBase64Data);
        if Rec.Base64Data.HasValue() then begin
            Rec.CalcFields(Rec.Base64Data);
            Rec.Base64Data.CreateInStream(InStr);
            while not InStr.EOS do begin
                if (InStr.ReadText(buffer) > 0) then
                    EftBase64Data += buffer;
            end;
        end;
    end;
}