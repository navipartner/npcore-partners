table 6151493 "Raptor Action"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Action';
    DrillDownPageID = "Raptor Action List";
    LookupPageID = "Raptor Action List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Data Type Description";Text[50])
        {
            Caption = 'Data Type Description';
        }
        field(3;"Raptor Module Code";Text[50])
        {
            Caption = 'Raptor Module Code';

            trigger OnValidate()
            begin
                if ("Raptor Module API Req. String" <> '') and ("Raptor Module API Req. String" = xRec."Raptor Module Code") then
                  "Raptor Module API Req. String" := "Raptor Module Code";
            end;
        }
        field(4;"Number of Entries to Return";Integer)
        {
            Caption = 'Number of Entries to Return';
        }
        field(5;Comment;Text[140])
        {
            Caption = 'Comment';
        }
        field(6;"Raptor Module API Req. String";Text[50])
        {
            Caption = 'Raptor Module API Req. String';
        }
        field(51;"Show Date-Time Created";Boolean)
        {
            Caption = 'Show Date-Time Created';
        }
        field(52;"Show Priority";Boolean)
        {
            Caption = 'Show Priority';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure RaptorActionAPIReqString(): Text
    begin
        if "Raptor Module API Req. String" <> '' then
          exit("Raptor Module API Req. String");
        exit("Raptor Module Code");
    end;
}

