page 6184902 "NPR External POS Sale Pay Sub"
{
    Extensible = False;
    Caption = 'External POS Sale Subform';
    PageType = ListPart;
    SourceTable = "NPR External POS Sale Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(LineNo; Rec."Line No.")
                {
                    Caption = 'Line Number';
                    ToolTip = 'Specifies the Line Number';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(no; Rec."No.")
                {
                    Caption = 'POS Payment Method Code';
                    ToolTip = 'Specifies the POS Payment Method code';
                    ApplicationArea = NPRRetail;
                    Editable = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    Caption = 'Payment Type';
                    ToolTip = 'Specifies the Payment Type used in the external POS.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadRawEft)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Download Terminal Response';
                ToolTip = 'Download the raw payment data.';
                Image = Download;

                trigger OnAction()
                var
                    ExternalPOSSaleEftLine: Record "NPR External POS Sale Eft Line";
                    Base64Convert: Codeunit "Base64 Convert";
                    InS: InStream;
                    fileName: Text;
                    buffer: Text;
                    base64: Text;
                    OutS: OutStream;
                    TempBlob: Codeunit "Temp Blob";
                begin
                    if (Rec."Payment Type" <> Rec."Payment Type"::EFT) then begin
                        Message('Payment lines of type EFT can have EFT data.');
                        exit;
                    end;

                    if (not ExternalPOSSaleEftLine.Get(Rec."External POS Sale Entry No.", Rec."Line No.")) then begin
                        Message('No EFT Data was found for this payment line.');
                        exit;
                    end;
                    ExternalPOSSaleEftLine.CalcFields(Base64Data);
                    ExternalPOSSaleEftLine.Base64Data.CreateInStream(InS);
                    while not InS.EOS do begin
                        if (InS.ReadText(buffer) > 0) then
                            base64 += buffer;
                    end;
                    TempBlob.CreateOutStream(OutS);
                    OutS.WriteText(Base64Convert.FromBase64(base64));
                    TempBlob.CreateInStream(InS);
                    fileName := 'ExternalPosEft-' + Format(ExternalPOSSaleEftLine."External POS Sale Entry No.") + '-' + Format(ExternalPOSSaleEftLine."External Pos SaleLine No");
                    File.DownloadFromStream(InS, '', '', '', fileName);
                end;
            }
        }
    }
}