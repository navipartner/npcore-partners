table 6150754 "NPR Vipps Mp Unit Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR Vipps Mp Unit Setup";
    DrillDownPageId = "NPR Vipps Mp Unit Setup";
    Caption = 'Vipps Mobilepay Unit Configuration';
    Extensible = false;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(2; "POS Unit Name"; Text[50])
        {
            Caption = 'POS Unit Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR POS Unit".Name where("No." = field("POS Unit No.")));
        }
        field(4; "Merchant Serial Number"; Text[10])
        {
            Caption = 'Merchant Serial Number';
            DataClassification = CustomerContent;
            TableRelation = "NPR Vipps Mp Store";

            trigger OnLookup()
            var
                VippsStore: Record "NPR Vipps Mp Store";
            begin
                if (PAGE.RunModal(Page::"NPR Vipps Mp Store List", VippsStore) = ACTION::LookupOK) then
                    Rec."Merchant Serial Number" := VippsStore."Merchant Serial Number";
            end;

        }
        field(5; "Merchant Store Name"; Text[100])
        {
            Caption = 'Merchant Store Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR Vipps Mp Store"."Store Name" where("Merchant Serial Number" = field("Merchant Serial Number")));
        }
        field(6; "Merchant Qr Id"; Text[250])
        {
            Caption = 'Static Qr Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR Vipps Mp QrCallback";

            trigger OnLookup()
            var
                QrRec: Record "NPR Vipps Mp QrCallback";
                VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
                State: Codeunit "NPR Vipps Mp SetupState";
                LblMsn: Label 'Please Select a merchant serial number first.';
                LblExistingQr: Label 'This Merchant Qr Id is already in use, please select another one.';
            begin
                if (Rec."Merchant Serial Number" = '') then begin
                    Message(LblMsn);
                    exit;
                end;
                State.SetCurrentMsn(Rec."Merchant Serial Number");
                if PAGE.RunModal(Page::"NPR Vipps Mp QrCallback List", QrRec) = ACTION::LookupOK then begin
                    VippsMpUnitSetup.SetFilter("Merchant Qr Id", QrRec."Merchant Qr Id");
                    if (VippsMpUnitSetup.FindFirst()) then begin
                        Message(LblExistingQr);
                    end else begin
                        Rec."Merchant Qr Id" := QrRec."Merchant Qr Id";
                    end;
                end;
            end;
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
        Key(Key2; "Merchant Qr Id")
        {

        }
    }
}
