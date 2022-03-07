table 6060129 "NPR MM Membership Entry"
{
    Caption = 'Membership Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(10; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(11; "Valid Until Date"; Date)
        {
            Caption = 'Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(12; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(13; Context; Option)
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew,Foreign Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW,FOREIGN;
        }
        field(14; "Original Context"; Option)
        {
            Caption = 'Original Context';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew,Foreign Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW,FOREIGN;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec."Blocked At" := CreateDateTime(0D, 0T);
                Rec."Blocked By" := '';
                if (Rec.Blocked) then begin
                    Rec."Blocked At" := CurrentDateTime();
                    Rec."Blocked By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Blocked By"));
                end;
            end;
        }
        field(16; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Blocked By"; Code[30])
        {
            Caption = 'Blocked By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(22; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(25; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(30; "Closed By Entry No."; Integer)
        {
            Caption = 'Closed By Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Entry";
        }
        field(35; "Activate On First Use"; Boolean)
        {
            Caption = 'Activate On First Use';
            DataClassification = CustomerContent;
        }
        field(40; "Duration Dateformula"; DateFormula)
        {
            Caption = 'Duration Dateformula';
            DataClassification = CustomerContent;
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(51; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(52; "Amount Incl VAT"; Decimal)
        {
            Caption = 'Amount Incl VAT';
            DataClassification = CustomerContent;
        }
        field(53; "Unit Price (Base)"; Decimal)
        {
            Caption = 'Unit Price (Base)';
            DataClassification = CustomerContent;
        }
        field(60; "Member Card Entry No."; Integer)
        {
            Caption = 'Member Card Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Card";
        }
        field(1000; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(1001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(1010; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Sales Header';
            OptionMembers = NA,SALESHEADER;
        }
        field(1011; "Document Type"; Enum "NPR MM Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(1012; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(1013; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(1015; "Auto-Renew Entry No."; Integer)
        {
            Caption = 'Auto-Renew Entry No.';
            DataClassification = CustomerContent;
        }
        field(1020; "Import Entry Document ID"; Text[100])
        {
            Caption = 'Import Entry Document ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Membership Entry No.")
        {
        }
        key(Key3; "Receipt No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure CalculateRemainingAmount(var OriginalAmountLCY: Decimal; var RemainingAmountLCY: Decimal; var DueDate: Date): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        exit(MembershipManagement.CalculateRemainingAmount(Rec, OriginalAmountLCY, RemainingAmountLCY, DueDate));
    end;
}

