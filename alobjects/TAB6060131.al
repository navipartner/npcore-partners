table 6060131 "MM Member Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.02/TSA/20151228  CASE 229684 Touch-up and enchancements
    // MM1.07/TSA/20160203  CASE 233438 Added flowfields
    // MM1.10/TSA/20130321  CASE 237176 Added flowfield company name
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.15/TSA/20160718  CASE 242519 Bug fix - checking for duplicate external member card no on manual input
    // MM1.15/TSA/20160725  CASE 238445 Added flowfield for membership code
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.17/TSA/20161214 CASE 243075 Added page 6060130 as the default lookup/drilldown page
    // MM1.22/TSA /20170911 CASE 284560 Added field Card Is Temporary
    // MM1.25/TSA /20180117 CASE 300256 Card Expire and Renew functionality
    // MM1.29/TSA /20180503 CASE 313795 Added block option "ANONYMIZED"
    // MM1.29/TSA /20180522 CASE 316251 Added index on field "External Card No."

    Caption = 'Member Card';
    DrillDownPageID = "MM Member Card List";
    LookupPageID = "MM Member Card List";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"External Card No.";Text[50])
        {
            Caption = 'External Card No.';

            trigger OnValidate()
            var
                MembershipManagement: Codeunit "MM Membership Management";
                NotFoundReasonText: Text;
            begin

                if (MembershipManagement.GetMembershipFromExtCardNo ("External Card No.", Today, NotFoundReasonText) <> 0) then
                  Error (TEXT6060000, FieldCaption ("External Card No."), "External Card No.");
            end;
        }
        field(11;"External Card No. Last 4";Code[4])
        {
            Caption = 'External Card No. Last 4';
        }
        field(12;"Pin Code";Text[50])
        {
            Caption = 'Pin Code';
        }
        field(13;"Valid Until";Date)
        {
            Caption = 'Valid Until';
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
        field(18;"Block Reason";Option)
        {
            Caption = 'Block Reason';
            OptionCaption = ' ,Expired,User Request,Internal,Anonymized';
            OptionMembers = UNKNOWN,EXPIRED,USER_REQUEST,INTERNAL,ANONYMIZED;
        }
        field(20;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
        }
        field(21;"Member Entry No.";Integer)
        {
            Caption = 'Member Entry No.';
        }
        field(30;"Card Is Temporary";Boolean)
        {
            Caption = 'Card Is Temporary';
        }
        field(40;"Card Type";Option)
        {
            Caption = 'Card Type';
            OptionCaption = 'Internal,External';
            OptionMembers = INTERNAL,EXTERNAL;
        }
        field(100;"External Member No.";Code[20])
        {
            CalcFormula = Lookup("MM Member"."External Member No." WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101;"Member Blocked";Boolean)
        {
            CalcFormula = Lookup("MM Member".Blocked WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'Member Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102;"Display Name";Text[100])
        {
            CalcFormula = Lookup("MM Member"."Display Name" WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'Display Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103;"E-Mail Address";Text[80])
        {
            CalcFormula = Lookup("MM Member"."E-Mail Address" WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'E-Mail Address';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"External Membership No.";Code[20])
        {
            CalcFormula = Lookup("MM Membership"."External Membership No." WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111;"Membership Blocked";Boolean)
        {
            CalcFormula = Lookup("MM Membership".Blocked WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Membership Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(112;"Company Name";Text[50])
        {
            CalcFormula = Lookup("MM Membership"."Company Name" WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Company Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(113;"Membership Code";Code[20])
        {
            CalcFormula = Lookup("MM Membership"."Membership Code" WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Membership Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(199;"Document ID";Text[100])
        {
            Caption = 'Document ID';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Card No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

