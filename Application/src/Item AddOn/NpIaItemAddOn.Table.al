table 6151125 "NPR NpIa Item AddOn"
{
    Caption = 'Item AddOn';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpIa Item AddOns";
    LookupPageID = "NPR NpIa Item AddOns";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(15; "Comment POS Info Code"; Code[20])
        {
            Caption = 'Comment POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        NpIaItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
    begin
        NpIaItemAddOnLineOption.SetRange("AddOn No.", "No.");
        if NpIaItemAddOnLineOption.FindFirst then
            NpIaItemAddOnLineOption.DeleteAll();

        NpIaItemAddOnLine.SetRange("AddOn No.", "No.");
        if NpIaItemAddOnLine.FindFirst then
            NpIaItemAddOnLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        NpIaItemAddOn: Record "NPR NpIa Item AddOn";
        IntBuffer: Integer;
    begin
        if "No." = '' then begin
            if not NpIaItemAddOn.FindLast then
                "No." := '000001'
            else
                if Evaluate(IntBuffer, CopyStr(NpIaItemAddOn."No.", StrLen(NpIaItemAddOn."No."), 1)) then
                    "No." := IncStr(NpIaItemAddOn."No.");
        end;
        TestField("No.");
    end;
}

