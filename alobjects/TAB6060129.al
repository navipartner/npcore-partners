table 6060129 "MM Membership Entry"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160321  CASE Cancel Membership
    // MM1.11/TSA/20160425  CASE 233824 Added Close By Entry No.
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160518  CASE 240870 Added Membership Code to be able to rollback on cancel upgrade
    // MM1.17/TSA/20161208  CASE 259671 Added Activate On First Use boolean field
    // MM1.19/TSA/20170324  CASE 270309 Added field "Member Card Entry No." a link to a the created membercard generated in this transaction.
    // MM1.22/TSA /20170829 CASE 286922 Added Context AUTORENEW, and field "Auto Renew Entry No."
    // MM1.23/TSA /20171003 CASE 257011 Added Context FOREIGN "Foreign Membership" for timeframes created as a result of a foreign membership import
    // MM1.25/TSA /20180116 CASE 300685 Keeping original context when regretting
    // MM1.29/TSA /20180522 CASE 316141 Added field "Unit Price (Base)"
    // MM1.34/TSA /20180907 CASE 327605 Added function CalculateRemainingAmount()

    Caption = 'Membership Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
            TableRelation = "MM Membership";
        }
        field(10;"Valid From Date";Date)
        {
            Caption = 'Valid From Date';
        }
        field(11;"Valid Until Date";Date)
        {
            Caption = 'Valid Until Date';
        }
        field(12;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(13;Context;Option)
        {
            Caption = 'Context';
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew,Foreign Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW,FOREIGN;
        }
        field(14;"Original Context";Option)
        {
            Caption = 'Original Context';
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew,Foreign Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW,FOREIGN;
        }
        field(15;Blocked;Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                "Blocked At" := CreateDateTime (0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                  "Blocked At" := CurrentDateTime ();
                  "Blocked By" := UserId;
                end;
            end;
        }
        field(16;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
            Editable = false;
        }
        field(17;"Blocked By";Code[30])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(20;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(22;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(25;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(30;"Closed By Entry No.";Integer)
        {
            Caption = 'Closed By Entry No.';
            TableRelation = "MM Membership Entry";
        }
        field(35;"Activate On First Use";Boolean)
        {
            Caption = 'Activate On First Use';
        }
        field(40;"Duration Dateformula";DateFormula)
        {
            Caption = 'Duration Dateformula';
        }
        field(50;"Unit Price";Decimal)
        {
            Caption = 'Unit Price';
        }
        field(51;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(52;"Amount Incl VAT";Decimal)
        {
            Caption = 'Amount Incl VAT';
        }
        field(53;"Unit Price (Base)";Decimal)
        {
            Caption = 'Unit Price (Base)';
        }
        field(60;"Member Card Entry No.";Integer)
        {
            Caption = 'Member Card Entry No.';
            TableRelation = "MM Member Card";
        }
        field(1000;"Receipt No.";Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(1001;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(1010;"Source Type";Option)
        {
            Caption = 'Source Type';
            OptionCaption = ' ,Sales Header';
            OptionMembers = NA,SALESHEADER;
        }
        field(1011;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,1,2,3,4,5';
            OptionMembers = "0","1","2","3","4","5";
        }
        field(1012;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(1013;"Document Line No.";Integer)
        {
            Caption = 'Document Line No.';
        }
        field(1015;"Auto-Renew Entry No.";Integer)
        {
            Caption = 'Auto-Renew Entry No.';
        }
        field(1020;"Import Entry Document ID";Text[100])
        {
            Caption = 'Import Entry Document ID';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure CalculateRemainingAmount(var OriginalAmountLCY: Decimal;var RemainingAmountLCY: Decimal;var DueDate: Date): Boolean
    var
        MembershipManagement: Codeunit "MM Membership Management";
    begin

        exit (MembershipManagement.CalculateRemainingAmount (Rec, OriginalAmountLCY, RemainingAmountLCY, DueDate));
    end;
}

