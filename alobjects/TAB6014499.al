table 6014499 "Print Tags"
{
    // NPR4.18/MMV/20151222 CASE 225584 Created table

    Caption = 'Print Tags';

    fields
    {
        field(1;"Print Tag";Text[100])
        {
            Caption = 'Print Tag';

            trigger OnValidate()
            var
                PrintTags: Record "Print Tags";
                Err0001: Label 'A tag must not be part of, or contain another tag. Conflict with: %1';
                Err0002: Label 'Tag must not contain comma';
            begin
                if StrPos("Print Tag", ',') > 0 then
                  Error(Err0002);

                if PrintTags.FindSet then repeat
                  if (StrPos("Print Tag", PrintTags."Print Tag") > 0)  or (StrPos(PrintTags."Print Tag", "Print Tag") > 0) then
                    Error(Err0001,PrintTags."Print Tag");
                until PrintTags.Next = 0;
            end;
        }
    }

    keys
    {
        key(Key1;"Print Tag")
        {
        }
    }

    fieldgroups
    {
    }
}

