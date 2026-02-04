table 6151291 "NPR NPRE Print Template"
{
    Access = Internal;
    Caption = 'NPRE Print Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Print Template SubP.";
    LookupPageID = "NPR NPRE Print Template SubP.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Print Type"; Option)
        {
            Caption = 'Print Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Kitchen Order,Serving Request,Pre Receipt';
            OptionMembers = "Kitchen Order","Serving Request","Pre Receipt";
        }
        field(20; "Seating Location"; Code[20])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location";
        }
        field(30; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(40; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(50; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(60; "Split Print Jobs By"; Option)
        {
            Caption = 'Split Print Jobs By';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Print Category,Serving Step,Both';
            OptionMembers = "None","Print Category","Serving Step",Both;
        }
        field(70; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit));
        }
        field(80; "Codeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Print Type", "Restaurant Code", "Seating Location", "Serving Step", "Print Category Code", "Codeunit ID")
        {
        }
    }

    trigger OnInsert()
    begin
        CheckDuplicateEntry();
    end;

    trigger OnModify()
    begin
        CheckDuplicateEntry();
    end;

    local procedure CheckDuplicateEntry()
    var
        NPREPrintTemplate: Record "NPR NPRE Print Template";
        DuplicateEntryErr: Label 'A record with the same Print Type, Restaurant Code, Seating Location, Serving Step, Print Category Code, and Codeunit ID already exists.';
    begin
        NPREPrintTemplate.SetRange("Print Type", Rec."Print Type");
        NPREPrintTemplate.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREPrintTemplate.SetRange("Seating Location", Rec."Seating Location");
        NPREPrintTemplate.SetRange("Serving Step", Rec."Serving Step");
        NPREPrintTemplate.SetRange("Print Category Code", Rec."Print Category Code");
        NPREPrintTemplate.SetRange("Codeunit ID", Rec."Codeunit ID");
        NPREPrintTemplate.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if not NPREPrintTemplate.IsEmpty() then
            Error(DuplicateEntryErr);
    end;
}
