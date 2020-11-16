table 6014434 "NPR TM Adm. Dependency"
{
    DataClassification = CustomerContent;
    Caption = 'Admission Dependency';
    LookupPageId = "NPR TM Adm. Dependency";

    fields
    {
        field(1; "Dependency Code"; Code[20])
        {
            Caption = 'Dependency Code';
            DataClassification = CustomerContent;
            NotBlank = true;

        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Dependency Code")
        {
            Clustered = true;
        }
    }


    var
        IN_USE: Label '%1 %2 is in use on %3. Please remove references to %2 before deleting.';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        Admission: Record "NPR TM Admission";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionDependencyLine: Record "NPR TM Adm. Dependency Line";
    begin

        Admission.SetFilter("Dependency Code", '=%1', "Dependency Code");
        if (not Admission.IsEmpty()) then
            Error(IN_USE, FieldCaption("Dependency Code"), "Dependency Code", Admission.TableCaption());

        TicketBOM.SetFilter("Admission Dependency Code", '=%1', "Dependency Code");
        if (not TicketBOM.IsEmpty()) then
            Error(IN_USE, FieldCaption("Dependency Code"), "Dependency Code", TicketBOM.TableCaption());

        AdmissionDependencyLine.SetFilter("Dependency Code", '=%1', "Dependency Code");
        AdmissionDependencyLine.DeleteAll();

    end;

}