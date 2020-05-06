table 6060111 "TM Ticket Setup"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20171218 CASE 300395 Added field Timeout (ms)
    // TM1.38/TSA /20181012 CASE 332109 Adding NP-Pass for tickets
    // TM1.38/TSA /20181026 CASE 308962 Added some boolean fields to control prepaid / postpaid ticket creation flow
    // TM90.1.46/TSA /20200320 CASE 397084 Added needed setup field in ordet to create tickets from a simple wizard

    Caption = 'Ticket Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(100;"Print Server Generator URL";Text[200])
        {
            Caption = 'Print Server Generator URL';
        }
        field(105;"Timeout (ms)";Integer)
        {
            Caption = 'Timeout (ms)';
            InitValue = 30000;
        }
        field(110;"Print Server Gen. Username";Text[30])
        {
            Caption = 'Print Server Gen. Username';
        }
        field(111;"Print Server Gen. Password";Text[50])
        {
            Caption = 'Print Server Gen. Password';
        }
        field(120;"Print Server Ticket URL";Text[200])
        {
            Caption = 'Print Server Ticket URL';
        }
        field(121;"Print Server Order URL";Text[200])
        {
            Caption = 'Print Server Order URL';
        }
        field(125;"Default Ticket Language";Text[30])
        {
            Caption = 'Default Ticket Language';
        }
        field(130;"Prepaid Excel Export Prompt";Option)
        {
            Caption = 'Prepaid Excel Export Prompt';
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(131;"Prepaid Offline Valid. Prompt";Option)
        {
            Caption = 'Prepaid Offline Valid. Prompt';
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAUL,SHOW,HIDE;
        }
        field(132;"Prepaid Ticket Result List";Option)
        {
            Caption = 'Prepaid Ticket Result List';
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(133;"Prepaid Default Quantity";Integer)
        {
            Caption = 'Prepaid Default Quantity';
        }
        field(134;"Prepaid Ticket Server Export";Option)
        {
            Caption = 'Prepaid Ticket Server Export';
            OptionCaption = ' ,Yes,No';
            OptionMembers = DEFAULT,YES,NO;
        }
        field(137;"Postpaid Excel Export Prompt";Option)
        {
            Caption = 'Postpaid Excel Export Prompt';
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(138;"Postpaid Ticket Result List";Option)
        {
            Caption = 'Postpaid Ticket Result List';
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(139;"Postpaid Default Quantity";Integer)
        {
            Caption = 'Postpaid Default Quantity';
        }
        field(140;"Postpaid Ticket Server Export";Option)
        {
            Caption = 'Postpaid Ticket Server Export';
            OptionCaption = ' ,Yes,No';
            OptionMembers = DEFAULT,YES,NO;
        }
        field(200;"NP-Pass Server Base URL";Text[200])
        {
            Caption = 'NP-Pass Server Base URL';
            Description = '//-TM1.38 [332109]';
            InitValue = 'https://passes.npecommerce.dk/api/v1';
        }
        field(210;"NP-Pass Notification Method";Option)
        {
            Caption = 'NP-Pass Notification Method';
            Description = '//-TM1.38 [332109]';
            OptionCaption = 'Asynchronous,Synchronous';
            OptionMembers = ASYNCHRONOUS,SYNCHRONOUS;
        }
        field(220;"NP-Pass API";Text[50])
        {
            Caption = 'NP-Pass API';
            Description = '//-TM1.38 [332109]';
            InitValue = '/passes/%1/%2';
        }
        field(230;"Show Send Fail Message In POS";Boolean)
        {
            Caption = 'Show Send Fail Message In POS';
        }
        field(231;"Show Message Body (Debug)";Boolean)
        {
            Caption = 'Show Message Body (Debug)';
        }
        field(235;"Suppress Print When eTicket";Boolean)
        {
            Caption = 'Suppress Print When eTicket';
        }
        field(240;"NP-Pass Token";Text[150])
        {
            Caption = 'NP-Pass Token';
            Description = '//-TM1.38 [332109]';
        }
        field(300;"Wizard Ticket Type No. Series";Code[10])
        {
            Caption = 'Wizard Ticket Type No. Series';
            TableRelation = "No. Series";
        }
        field(301;"Wizard Ticket Type Template";Code[10])
        {
            Caption = 'Wizard Ticket Type Template';
            TableRelation = "Config. Template Header";
        }
        field(306;"Wizard Ticket Bom Template";Code[10])
        {
            Caption = 'Wizard Ticket Bom Template';
            TableRelation = "Config. Template Header";
        }
        field(310;"Wizard Adm. Code No. Series";Code[10])
        {
            Caption = 'Wizard Adm. Code No. Series';
            TableRelation = "No. Series";
        }
        field(311;"Wizard Admission Template";Code[10])
        {
            Caption = 'Wizard Admission Template';
            TableRelation = "Config. Template Header";
        }
        field(315;"Wizard Sch. Code No. Series";Code[10])
        {
            Caption = 'Wizard Sch. Code No. Series';
            TableRelation = "No. Series";
        }
        field(320;"Wizard Item No. Series";Code[10])
        {
            Caption = 'Wizard Item No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

