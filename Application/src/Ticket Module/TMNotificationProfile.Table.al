table 6014591 "NPR TM Notification Profile"
{
    Caption = 'Ticket Notification Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR TM Notif. Profile List";
    DrillDownPageId = "NPR TM Notif. Profile List";

    fields
    {
        field(1; "Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Profile Code")
        {
            Clustered = true;
        }
    }

    var
        IN_USE: Label '%1 %2 is in use on %3. Please remove references to %2 before deleting.';

    trigger OnDelete()
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        ProfileLine: Record "NPR TM Notif. Profile Line";
    begin
        TicketBOM.SetFilter("Notification Profile Code", '=%1', Rec."Profile Code");
        if (not TicketBOM.IsEmpty()) then
            Error(IN_USE, FieldCaption(Rec."Profile Code"), "Profile Code", TicketBOM.TableCaption());

        ProfileLine.SetFilter("Profile Code", '=%1', Rec."Profile Code");
        ProfileLine.DeleteAll();
    end;
}