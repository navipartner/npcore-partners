table 6060116 "TM Ticket Reservation Request"
{
    // NPR4.16/TSA/20150803 TM1.00 Ticket Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160115  CASE 231834 General Issues
    // TM1.05/TSA/20160119  CASE 232250 Added Ext. Line Reference No.
    // TM1.08/TSA/20160222  CASE 235208 Added new Field Ext. Member No. for referencing a reservation made by members
    // TM1.08/TSA/20160222  CASE 235208 Added new Admission Code to identify ticket specifics
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160513  CASE 240864 Cancel Ticket Request
    // TM1.16/TSA/20160622  CASE 245004 Added field email and external order no.
    // TM1.17/TSA/20160913  CASE 251883 Added SMS as Notification Method
    // TM1.17/TSA/20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.22/TSA/20170526  CASE 278142 Added field Payment Option, Customer No.
    // TM1.23/TSA /20170717 CASE 284248 Added Request Option "Reserved"
    // TM1.23/TSA /20170718 CASE 284248 Added Field Primary Request Line Boolean
    // TM1.26/TSA /20171102 CASE 285601 Added Field "DIY Print Order Requested", "DIY Print Order At"
    // TM1.31/TSA /20180524 CASE 316500 Added key "Request Status", "Expires Date Time", IsEmpty dropped from 650 reads to 4 according to profiler for ExpireReservationRequests()

    Caption = 'Ticket Reservation Request';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Session Token ID";Text[100])
        {
            Caption = 'Session Token ID';
        }
        field(11;"Created Date Time";DateTime)
        {
            Caption = 'Created Date Time';
        }
        field(12;"Request Status";Option)
        {
            Caption = 'Request Status';
            OptionCaption = 'Registered,Confirmed,Expired,Canceled,Work In Progress,Reserved';
            OptionMembers = REGISTERED,CONFIRMED,EXPIRED,CANCELED,WIP,RESERVED;
        }
        field(13;"Request Status Date Time";DateTime)
        {
            Caption = 'Request Status Date Time';
        }
        field(14;"Revoke Ticket Request";Boolean)
        {
            Caption = 'Revoke Ticket Request';
        }
        field(15;"Revoke Access Entry No.";Integer)
        {
            Caption = 'Revoke Access Entry No.';
            TableRelation = "TM Ticket Access Entry";
        }
        field(20;"External Item Code";Code[20])
        {
            Caption = 'External Item Code';
        }
        field(21;Quantity;Integer)
        {
            Caption = 'Quantity';
        }
        field(22;"External Adm. Sch. Entry No.";Integer)
        {
            Caption = 'External Adm. Sch. Entry No.';
        }
        field(23;"Ext. Line Reference No.";Integer)
        {
            Caption = 'Line Reference No.';
        }
        field(24;"External Member No.";Code[20])
        {
            Caption = 'External Member No.';
            TableRelation = "MM Member";
            ValidateTableRelation = false;
        }
        field(25;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
        }
        field(30;"Expires Date Time";DateTime)
        {
            Caption = 'Expires Date Time';
        }
        field(40;"External Ticket Number";Text[30])
        {
            Caption = 'External Ticket Number';
        }
        field(60;"Admission Description";Text[50])
        {
            Caption = 'Admission Description';
        }
        field(61;"Scheduled Time Description";Text[30])
        {
            Caption = 'Scheduled Time Description';
        }
        field(80;"Notification Method";Option)
        {
            Caption = 'Notification Method';
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81;"Notification Address";Text[80])
        {
            Caption = 'Notification Address';
        }
        field(90;"DIY Print Order Requested";Boolean)
        {
            Caption = 'DIY Print Order Requested';
        }
        field(91;"DIY Print Order At";DateTime)
        {
            Caption = 'DIY Print Order At';
        }
        field(95;"External Order No.";Code[20])
        {
            Caption = 'External Order No.';
        }
        field(98;"Primary Request Line";Boolean)
        {
            Caption = 'Primary Request Line';
        }
        field(99;"Admission Created";Boolean)
        {
            Caption = 'Admission Created';
        }
        field(100;"Payment Option";Option)
        {
            Caption = 'Payment Option';
            OptionCaption = 'Direct,Prepaid,Postpaid,Not Paid';
            OptionMembers = DIRECT,PREPAID,POSTPAID,UNPAID;
        }
        field(110;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(1000;"Receipt No.";Code[20])
        {
            Caption = 'Receipt No.';
            Description = 'External Relations';
        }
        field(1001;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Session Token ID","Ext. Line Reference No.")
        {
        }
        key(Key3;"Receipt No.","Line No.")
        {
        }
        key(Key4;"Request Status","Expires Date Time")
        {
        }
    }

    fieldgroups
    {
    }
}

