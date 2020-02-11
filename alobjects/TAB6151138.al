table 6151138 "TM Ticket Waiting List"
{
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Ticket Waiting List';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"External Schedule Entry No.";Integer)
        {
            Caption = 'External Schedule Entry No.';
        }
        field(11;"Schedule Entry Description";Text[30])
        {
            Caption = 'Schedule Entry Description';
        }
        field(15;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";
        }
        field(20;"Notification Address";Text[100])
        {
            Caption = 'Notification Address';
        }
        field(25;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(30;Token;Text[50])
        {
            Caption = 'Token';
        }
        field(35;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(36;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(37;Quantity;Integer)
        {
            Caption = 'Quantity';
        }
        field(40;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Redeemed,Cancelled';
            OptionMembers = ACTIVE,REDEEMED,CANCELLED;
        }
        field(50;"Temp Count";Integer)
        {
            Caption = 'Tmp Count';
        }
        field(51;"Temp Notified At";DateTime)
        {
            Caption = 'Temp Notified At';
        }
        field(1000;"Notification Count";Integer)
        {
            CalcFormula = Count("TM Waiting List Entry" WHERE ("Ticket Waiting List Entry No."=FIELD("Entry No.")));
            Caption = 'Notification Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"Notified At";DateTime)
        {
            CalcFormula = Max("TM Waiting List Entry"."Created At" WHERE ("Ticket Waiting List Entry No."=FIELD("Entry No.")));
            Caption = 'Notified At';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020;"Notification Expires At";DateTime)
        {
            CalcFormula = Max("TM Waiting List Entry"."Expires At" WHERE ("Ticket Waiting List Entry No."=FIELD("Entry No.")));
            Caption = 'Notification Expires At';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Schedule Entry No.",Status)
        {
        }
        key(Key3;"Temp Notified At")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WaitingListEntry: Record "TM Waiting List Entry";
    begin

        WaitingListEntry.SetFilter ("Ticket Waiting List Entry No.", '=%1', "Entry No.");
        WaitingListEntry.DeleteAll ();
    end;
}

