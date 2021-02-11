table 6151138 "NPR TM Ticket Wait. List"
{
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Ticket Waiting List';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "External Schedule Entry No."; Integer)
        {
            Caption = 'External Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(11; "Schedule Entry Description"; Text[30])
        {
            Caption = 'Schedule Entry Description';
            DataClassification = CustomerContent;
        }
        field(15; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(20; "Notification Address"; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(25; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(30; Token; Text[100])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(35; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(36; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(37; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(40; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Redeemed,Cancelled';
            OptionMembers = ACTIVE,REDEEMED,CANCELLED;
        }
        field(50; "Temp Count"; Integer)
        {
            Caption = 'Tmp Count';
            DataClassification = CustomerContent;
        }
        field(51; "Temp Notified At"; DateTime)
        {
            Caption = 'Temp Notified At';
            DataClassification = CustomerContent;
        }
        field(1000; "Notification Count"; Integer)
        {
            CalcFormula = Count ("NPR TM Waiting List Entry" WHERE("Ticket Waiting List Entry No." = FIELD("Entry No.")));
            Caption = 'Notification Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Notified At"; DateTime)
        {
            CalcFormula = Max ("NPR TM Waiting List Entry"."Created At" WHERE("Ticket Waiting List Entry No." = FIELD("Entry No.")));
            Caption = 'Notified At';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Notification Expires At"; DateTime)
        {
            CalcFormula = Max ("NPR TM Waiting List Entry"."Expires At" WHERE("Ticket Waiting List Entry No." = FIELD("Entry No.")));
            Caption = 'Notification Expires At';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "External Schedule Entry No.", Status)
        {
        }
        key(Key3; "Temp Notified At")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WaitingListEntry: Record "NPR TM Waiting List Entry";
    begin

        WaitingListEntry.SetFilter("Ticket Waiting List Entry No.", '=%1', "Entry No.");
        WaitingListEntry.DeleteAll();
    end;
}

