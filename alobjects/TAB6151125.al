table 6151125 "NpIa Item AddOn"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181109  CASE 334922 Removed TableRelation on field 1 "No."

    Caption = 'Item AddOn';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpIa Item AddOns";
    LookupPageID = "NpIa Item AddOns";

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
            TableRelation = "POS Info";
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
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
    begin
        //-NPR5.48 [334922]
        NpIaItemAddOnLineOption.SetRange("AddOn No.", "No.");
        if NpIaItemAddOnLineOption.FindFirst then
            NpIaItemAddOnLineOption.DeleteAll;

        NpIaItemAddOnLine.SetRange("AddOn No.", "No.");
        if NpIaItemAddOnLine.FindFirst then
            NpIaItemAddOnLine.DeleteAll;
        //+NPR5.48 [334922]
    end;

    trigger OnInsert()
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
        IntBuffer: Integer;
    begin
        //-NPR5.48 [334922]
        // IF Description = '' THEN BEGIN
        //  Item.GET("No.");
        //  Description := Item.Description;
        // END;
        if "No." = '' then begin
            if not NpIaItemAddOn.FindLast then
                "No." := '000001'
            else
                if Evaluate(IntBuffer, CopyStr(NpIaItemAddOn."No.", StrLen(NpIaItemAddOn."No."), 1)) then
                    "No." := IncStr(NpIaItemAddOn."No.");
        end;
        TestField("No.");
        //+NPR5.48 [334922]
    end;
}

