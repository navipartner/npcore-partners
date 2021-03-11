table 6060116 "NPR TM Ticket Reservation Req."
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
    // TM1.43/TSA /20190910 CASE 368043 Added Item No. and Variant Code to make a separation from "External Item Code".
    // TM1.45/TSA /20191204 CASE 380754 Added Waiting List Reference Code, and request status option "Waiting List"
    // TM1.45/TSA /20191216 CASE 382535 Added "Admission Inclusion", "Notification Format"
    // TM1.47/TSA /20200526 CASE 382535 Added "Admission Inclusion Status"

    Caption = 'Ticket Reservation Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Session Token ID"; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }
        field(11; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            DataClassification = CustomerContent;
        }
        field(12; "Request Status"; Option)
        {
            Caption = 'Request Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Registered,Confirmed,Expired,Canceled,Work In Progress,Reserved,Waiting List';
            OptionMembers = REGISTERED,CONFIRMED,EXPIRED,CANCELED,WIP,RESERVED,WAITINGLIST;
        }
        field(13; "Request Status Date Time"; DateTime)
        {
            Caption = 'Request Status Date Time';
            DataClassification = CustomerContent;
        }
        field(14; "Revoke Ticket Request"; Boolean)
        {
            Caption = 'Revoke Ticket Request';
            DataClassification = CustomerContent;
        }
        field(15; "Revoke Access Entry No."; Integer)
        {
            Caption = 'Revoke Access Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Access Entry";
        }
        field(20; "External Item Code"; Code[50])
        {
            Caption = 'External Item Code';
            DataClassification = CustomerContent;
        }
        field(21; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; "External Adm. Sch. Entry No."; Integer)
        {
            Caption = 'External Adm. Sch. Entry No.';
            DataClassification = CustomerContent;
        }
        field(23; "Ext. Line Reference No."; Integer)
        {
            Caption = 'Line Reference No.';
            DataClassification = CustomerContent;
        }
        field(24; "External Member No."; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member";
            ValidateTableRelation = false;
        }
        field(25; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(26; "Admission Inclusion"; Option)
        {
            Caption = 'Admission Inclusion';
            DataClassification = CustomerContent;
            OptionCaption = 'Required,Optional and Selected,Optional and not Selected';
            OptionMembers = REQUIRED,SELECTED,NOT_SELECTED;
        }
        field(27; "Admission Inclusion Status"; Option)
        {
            Caption = 'Admission Inclusion Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Add,Remove';
            OptionMembers = NO_CHANGE,ADD,REMOVE;
        }
        field(30; "Expires Date Time"; DateTime)
        {
            Caption = 'Expires Date Time';
            DataClassification = CustomerContent;
        }
        field(40; "External Ticket Number"; Text[30])
        {
            Caption = 'External Ticket Number';
            DataClassification = CustomerContent;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(51; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(60; "Admission Description"; Text[50])
        {
            Caption = 'Admission Description';
            DataClassification = CustomerContent;
        }
        field(61; "Scheduled Time Description"; Text[30])
        {
            Caption = 'Scheduled Time Description';
            DataClassification = CustomerContent;
        }
        field(70; "Waiting List Reference Code"; Code[10])
        {
            Caption = 'Waiting List Reference Code';
            DataClassification = CustomerContent;
        }
        field(80; "Notification Method"; Option)
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81; "Notification Address"; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(82; "Notification Format"; Option)
        {
            Caption = 'Notification Format';
            DataClassification = CustomerContent;
            OptionCaption = 'Plain,HTML,Attachment,Wallet';
            OptionMembers = PLAIN,HTML,ATTACHMENT,WALLET;
        }
        field(90; "DIY Print Order Requested"; Boolean)
        {
            Caption = 'DIY Print Order Requested';
            DataClassification = CustomerContent;
        }
        field(91; "DIY Print Order At"; DateTime)
        {
            Caption = 'DIY Print Order At';
            DataClassification = CustomerContent;
        }
        field(95; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
        }
        field(98; "Primary Request Line"; Boolean)
        {
            Caption = 'Primary Request Line';
            DataClassification = CustomerContent;
        }
        field(99; "Admission Created"; Boolean)
        {
            Caption = 'Admission Created';
            DataClassification = CustomerContent;
        }
        field(100; "Payment Option"; Option)
        {
            Caption = 'Payment Option';
            DataClassification = CustomerContent;
            OptionCaption = 'Direct,Prepaid,Postpaid,Not Paid';
            OptionMembers = DIRECT,PREPAID,POSTPAID,UNPAID;
        }
        field(110; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(120; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = PRIMARY,CHANGE;
            OptionCaption = 'Primary,Change';
            DataClassification = CustomerContent;
        }
        field(123; "Superseeds Entry No."; Integer)
        {
            Caption = 'Superseeds Entry No.';
            DataClassification = CustomerContent;
        }
        field(126; "Is Superseeded"; Boolean)
        {
            Caption = 'Is Superseeded';
            FieldClass = FlowField;
            CalcFormula = Exist ("NPR TM Ticket Reservation Req." WHERE("Superseeds Entry No." = FIELD("Entry No.")));
            Editable = false;
        }
        field(129; "Authorization Code"; Code[10])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(1000; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            Description = 'External Relations';
        }
        field(1001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Session Token ID", "Ext. Line Reference No.")
        {
        }
        key(Key3; "Receipt No.", "Line No.")
        {
        }
        key(Key4; "Request Status", "Expires Date Time")
        {
        }
        key(Key5; "Superseeds Entry No.")
        {

        }
    }

    fieldgroups
    {
    }
}

