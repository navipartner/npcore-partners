page 6060000 "GIM - Document Types"
{
    Caption = 'GIM - Document Types';
    CardPageID = "GIM - Document Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "GIM - Document Type";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Sender ID";"Sender ID")
                {
                }
                field("Base Version No.";"Base Version No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Versions)
            {
                Caption = 'Versions';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "GIM - Document Type Versions";
                RunPageLink = Code=FIELD(Code),
                              "Sender ID"=FIELD("Sender ID");
            }
        }
    }
}

