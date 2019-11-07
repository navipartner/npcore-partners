table 6151186 "MM Sponsorship Ticket Entry"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            TableRelation = "MM Membership Setup";
        }
        field(2;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Registered,Finalized';
            OptionMembers = REGISTERED,FINALIZED;
        }
        field(5;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
            TableRelation = "MM Membership";
        }
        field(7;"Setup Line No.";Integer)
        {
            Caption = 'Setup Line No.';
        }
        field(10;"Ticket Token";Text[100])
        {
            Caption = 'Ticket Token';
        }
        field(11;"Ticket No.";Code[20])
        {
            Caption = 'Ticket No.';
        }
        field(12;"Event Type";Option)
        {
            Caption = 'Event Type';
            OptionCaption = ' ,On New,On Renew,On Demand';
            OptionMembers = NA,ONNEW,ONRENEW,ONDEMAND;
        }
        field(20;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(30;"Notification Send Status";Option)
        {
            Caption = 'Notification Send Status';
            OptionCaption = 'Pending,Delivered,Canceled,Failed,Not Delivered,Pick-Up';
            OptionMembers = PENDING,DELIVERED,CANCELED,FAILED,NOT_DELIVERED,"PICK-UP";
        }
        field(31;"Notification Sent At";DateTime)
        {
            Caption = 'Notification Sent At';
        }
        field(32;"Notification Sent By User";Text[30])
        {
            Caption = 'Notification Sent By User';
        }
        field(40;"Notification Address";Text[80])
        {
            Caption = 'Notification Address';
        }
        field(45;"Picked Up At";DateTime)
        {
            Caption = 'Picked Up At';
        }
        field(100;"External Member No.";Code[20])
        {
            Caption = 'External Member No.';
        }
        field(110;"E-Mail Address";Text[80])
        {
            Caption = 'E-Mail Address';
        }
        field(111;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
        }
        field(120;"First Name";Text[50])
        {
            Caption = 'First Name';
        }
        field(121;"Middle Name";Text[50])
        {
            Caption = 'Middle Name';
        }
        field(122;"Last Name";Text[50])
        {
            Caption = 'Last Name';
        }
        field(123;"Display Name";Text[100])
        {
            Caption = 'Display Name';
            Editable = false;
        }
        field(130;Address;Text[100])
        {
            Caption = 'Address';
        }
        field(131;"Post Code Code";Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(132;City;Text[50])
        {
            Caption = 'City';
        }
        field(133;"Country Code";Code[10])
        {
            Caption = 'Country Code';
        }
        field(134;Country;Text[50])
        {
            Caption = 'Country';
        }
        field(140;Birthday;Date)
        {
            Caption = 'Birthday';
        }
        field(150;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(151;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(153;"Membership Valid From";Date)
        {
            Caption = 'Membership Valid From';
        }
        field(154;"Membership Valid Until";Date)
        {
            Caption = 'Membership Valid Until';
        }
        field(160;"External Membership No.";Code[20])
        {
            Caption = 'External Membership No.';
            TableRelation = "MM Membership"."External Membership No.";
        }
        field(200;"Failed With Message";Text[250])
        {
            Caption = 'Failed With Message';
        }
        field(405;"Ticket URL";Text[200])
        {
            Caption = 'Ticket URL';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Membership Entry No.","Event Type")
        {
        }
        key(Key3;"Membership Entry No.",Status)
        {
        }
    }

    fieldgroups
    {
    }
}

