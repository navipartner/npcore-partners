page 6060030 "GIM - Document Type Versions"
{
    Caption = 'GIM - Document Type Versions';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Document Type Version";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Version No.";"Version No.")
                {
                    Editable = false;
                }
                field(Base;Base)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Mapping)
            {
                Caption = 'Mapping';
                Image = SetupColumns;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "GIM - Mapping 2";
                RunPageLink = "Document No."=CONST(''),
                              "Doc. Type Code"=FIELD(Code),
                              "Sender ID"=FIELD("Sender ID"),
                              "Version No."=FIELD("Version No.");
            }
        }
    }
}

