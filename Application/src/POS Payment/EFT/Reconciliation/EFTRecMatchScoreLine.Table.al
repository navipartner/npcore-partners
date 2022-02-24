table 6014630 "NPR EFT Rec. Match/Score Line"
{
    Access = Internal;
    Caption = 'EFT Recon. Match/Score Line';

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
        field(4; LineType; Option)
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Filter,AdditionalScore';
            OptionMembers = "Filter",AdditionalScore;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Transaction Field No."; Integer)
        {
            Caption = 'Transaction Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." where(TableNo = const(6184495));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, Database::"NPR EFT Transaction Request");
                if Page.RunModal(Page::"Fields Lookup", Field) = Action::LookupOK then
                    "Transaction Field No." := Field."No.";

                CalcFields("Transaction Field Name");
                TestLine();
            end;

            trigger OnValidate()
            begin
                CalcFields("Transaction Field Name");
                TestLine();
            end;
        }
        field(11; "Transaction Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = const(6184495),
                                                        "No." = field("Transaction Field No.")));
            Caption = 'Transaction Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." where(TableNo = const(6014617));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, Database::"NPR EFT Recon. Line");
                if Page.RunModal(Page::"Fields Lookup", Field) = Action::LookupOK then
                    "Field No." := Field."No.";
                CalcFields("Field Name");

                TestLine();
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
                TestLine();
            end;
        }
        field(21; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = const(6014617),
                                                        "No." = field("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Filter Type"; Option)
        {
            Caption = 'Filter Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Field,Const,Filter';
            OptionMembers = "Field","Const","Filter";

            trigger OnValidate()
            begin
                TestLine();
            end;
        }
        field(60; "Filter Value"; Text[250])
        {
            Caption = 'Filter Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestLine();
            end;
        }
        field(100; "Additional Score"; Decimal)
        {
            Caption = 'Additional Score';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Provider Code", ID, LineType, "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    local procedure TestLine()
    var
        EFTReconMatchingMgt: Codeunit "NPR EFT Rec. Match/Score Mgt.";
    begin
        if "Transaction Field No." = 0 then
            exit;
        EFTReconMatchingMgt.TestFilterLine(Rec);
    end;
}

