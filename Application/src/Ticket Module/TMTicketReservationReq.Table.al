﻿table 6060116 "NPR TM Ticket Reservation Req."
{
    Access = Internal;
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
            OptionCaption = 'Registered,Confirmed,Expired,Canceled,Work In Progress,Reserved,Waiting List,Optional';
            OptionMembers = REGISTERED,CONFIRMED,EXPIRED,CANCELED,WIP,RESERVED,WAITINGLIST,OPTIONAL;
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
        field(45; PreAssignedTicketNumber; Text[30])
        {
            Caption = 'Pre-Assigned Ticket Number';
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
        field(52; Amount; Decimal)
        {
            Caption = 'Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(53; AmountInclVat; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(54; UnitAmount; Decimal)
        {
            Caption = 'Unit Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(55; UnitAmountInclVat; Decimal)
        {
            Caption = 'Unit Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(56; AmountSource; Option)
        {
            Caption = 'Amount Source';
            DataClassification = CustomerContent;
            OptionMembers = BC,API;
            OptionCaption = 'From BC,From API';
        }
        field(57; TicketUnitAmountExclVat; Decimal)
        {
            Caption = 'Ticket Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(58; TicketUnitAmountInclVat; Decimal)
        {
            Caption = 'Ticket Amount Incl. VAT';
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
        field(85; TicketHolderName; Text[100])
        {
            Caption = 'Ticket Holder Name';
            DataClassification = CustomerContent;
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
            OptionMembers = PRIMARY,CHANGE,REVOKE;
            OptionCaption = 'Primary,Change,Revoke';
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
            CalcFormula = Exist("NPR TM Ticket Reservation Req." WHERE("Superseeds Entry No." = FIELD("Entry No.")));
            Editable = false;
        }
        field(129; "Authorization Code"; Code[10])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(130; Default; Boolean)
        {
            Caption = 'Default';
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
        key(Key2; "Session Token ID", "Ext. Line Reference No.", "Admission Inclusion")
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
        key(Key6; "External Ticket Number")
        {
        }
        key(Key7; "Session Token ID", "Admission Inclusion")
        {
        }
        key(Key8; "External Order No.")
        {
        }
    }

    fieldgroups
    {
    }



}

