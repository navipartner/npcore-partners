page 6060013 "GIM - Import Buffer Overview"
{
    Caption = 'GIM - Import Buffer Overview';
    PageType = List;
    SourceTable = "GIM - Import Buffer Detail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Row No.";"Row No.")
                {
                    Editable = false;
                }
                field("Column No.";"Column No.")
                {
                    Editable = false;
                }
                field("Parsed Text";"Parsed Text")
                {
                    Editable = false;
                }
                field("Skip Column";"Skip Column")
                {
                }
                field("Table ID";"Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Field Type";"Field Type")
                {
                    Editable = false;
                }
                field("Fail Reason";"Fail Reason")
                {
                    Editable = false;
                }
                field("Field Additional Info";"Field Additional Info")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        DocNoFilter := GetFilter("Document No.");
        if DocNoFilter <> '' then begin
          FilterGroup := 2;
          SetFilter("Document No.",DocNoFilter);
          FilterGroup := 0;
        end;
    end;

    var
        DocNoFilter: Text[30];
}

