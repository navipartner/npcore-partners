table 6150709 "NPR POS Ticket Rcpt. Text"
{
    DataClassification = CustomerContent;
    Caption = 'POS Sales Ticket Receipt Text';

    fields
    {
        field(1; "Rcpt. Txt. Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'POS Unit Rcpt. Txt. Profile Code';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }

        field(3; "Receipt Text"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
    }

    keys
    {
        key(PK; "Rcpt. Txt. Profile Code", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure DeleteAllForCurrProfile(ProfileCode: Code[20])
    begin
        Rec.SetRange("Rcpt. Txt. Profile Code", ProfileCode);
        if not Rec.IsEmpty() then
            Rec.DeleteAll();
    end;

    procedure FindLastLineForCurrProfile(ProfileCode: Code[20]): Integer
    begin
        Rec.SetRange("Rcpt. Txt. Profile Code", ProfileCode);
        if Rec.FindLast() then
            exit(Rec."Line No.");
    end;

    procedure Add(ProfileCode: Code[20]; LineNo: Integer; ReceiptText: Text)
    begin
        Rec."Rcpt. Txt. Profile Code" := ProfileCode;
        Rec."Line No." := LineNo;
        Rec.Init();
        Rec."Receipt Text" := ReceiptText;
        Rec.Insert();
    end;
}