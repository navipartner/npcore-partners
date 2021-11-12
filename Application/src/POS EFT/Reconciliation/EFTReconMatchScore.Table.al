table 6014619 "NPR EFT Recon. Match/Score"
{
    Caption = 'EFT Recon. Match/Score';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Match,Score';
            OptionMembers = Match,Score;
        }
        field(2; "Provider Code"; Code[20])
        {
            Caption = 'Provider Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Recon. Provider";
        }
        field(3; ID; Code[20])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(60; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(100; Score; Decimal)
        {
            Caption = 'Score';
            DataClassification = CustomerContent;
        }
        field(110; "Max. Additional Score"; Decimal)
        {
            CalcFormula = sum("NPR EFT Rec. Match/Score Line"."Additional Score" where(Type = field(Type),
                                                                                      "Provider Code" = field("Provider Code"),
                                                                                      ID = field(ID)));
            Caption = 'Max. Additional Score';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "Provider Code", ID)
        {
            Clustered = true;
        }
        key(Key2; Type, "Provider Code", Enabled, "Sequence No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EFTReconMatchLine: Record "NPR EFT Rec. Match/Score Line";
    begin
        EFTReconMatchLine.SetRange(Type, Type);
        EFTReconMatchLine.SetRange("Provider Code", "Provider Code");
        EFTReconMatchLine.SetRange(ID, ID);
        EFTReconMatchLine.DeleteAll(true);
    end;
}

