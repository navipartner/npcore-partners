table 6150984 "NPR SG TicketProfileLine"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "NPR SG TicketProfile";
        }
        field(2; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(20; ItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item where("NPR Ticket Type" = filter(<> ''));
        }

        field(30; AdmissionCode; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Admission Code';

            TableRelation = if (ItemNo = const('')) "NPR TM Admission" else
            "NPR TM Ticket Admission BOM"."Admission Code" where("Item No." = field(ItemNo));
        }

        field(40; CalendarCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Calendar Code';
            TableRelation = "Base Calendar";
        }

        field(45; PermitFromTime; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'From Time';
        }
        field(46; PermitUntilTime; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Until Time';
        }
        field(100; RuleType; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Rule Type';
            OptionMembers = ALLOW,REJECT;
            OptionCaption = 'Allow,Reject';
            InitValue = ALLOW;
        }
    }

    keys
    {
        key(Key1; Code, LineNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Main; Code, Description)
        {
            Caption = 'Ticket Profiles for Speedgate';
        }
    }

    trigger OnInsert()
    var
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        if (Rec.LineNo = 0) then begin
            TicketProfileLine.SetCurrentKey(Code, LineNo);
            TicketProfileLine.SetFilter(Code, '=%1', Rec.Code);

            Rec.LineNo := 10000;
            if (TicketProfileLine.FindLast()) then
                Rec.LineNo := TicketProfileLine.LineNo + 10000;
        end;
    end;
}